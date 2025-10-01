import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/delivery_task.dart';

class DeliveryProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Current delivery tasks
  List<DeliveryTask> _availableTasks = [];
  List<DeliveryTask> _myTasks = [];
  DeliveryTask? _currentTask;

  // Loading states
  bool _isLoading = false;
  String? _error;

  // Getters
  List<DeliveryTask> get availableTasks => _availableTasks;
  List<DeliveryTask> get myTasks => _myTasks;
  DeliveryTask? get currentTask => _currentTask;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Constructor
  DeliveryProvider() {
    _initializeProvider();
  }

  // Initialize provider
  Future<void> _initializeProvider() async {
    _startListeningToTasks();
  }

  // Stream listeners
  void _startListeningToTasks() {
    final user = _auth.currentUser;
    if (user == null) return;

    // Listen to available tasks (for riders)
    _firestore
        .collection('delivery_tasks')
        .where('status', isEqualTo: 'pending')
        .where('riderId', isEqualTo: '')
        .snapshots()
        .listen((snapshot) {
      _availableTasks = snapshot.docs
          .map((doc) => DeliveryTask.fromJson({
                ...doc.data(),
                'id': doc.id,
              }))
          .toList();
      notifyListeners();
    }, onError: (error) {
      _error = 'Error loading available tasks: ${error.toString()}';
      notifyListeners();
    });

    // Listen to my tasks (for riders)
    _firestore
        .collection('delivery_tasks')
        .where('riderId', isEqualTo: user.uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen((snapshot) {
      _myTasks = snapshot.docs
          .map((doc) => DeliveryTask.fromJson({
                ...doc.data(),
                'id': doc.id,
              }))
          .toList();
      notifyListeners();
    }, onError: (error) {
      _error = 'Error loading my tasks: ${error.toString()}';
      notifyListeners();
    });

    // Listen to current active task
    _firestore
        .collection('delivery_tasks')
        .where('riderId', isEqualTo: user.uid)
        .where('status', whereIn: ['accepted', 'pickedUp'])
        .limit(1)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        _currentTask = DeliveryTask.fromJson({
          ...snapshot.docs.first.data(),
          'id': snapshot.docs.first.id,
        });
      } else {
        _currentTask = null;
      }
      notifyListeners();
    }, onError: (error) {
      _error = 'Error loading current task: ${error.toString()}';
      notifyListeners();
    });
  }

  // Task operations
  Future<bool> acceptTask(String taskId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      final taskRef = _firestore.collection('delivery_tasks').doc(taskId);
      final taskDoc = await taskRef.get();

      if (!taskDoc.exists) return false;

      final task = DeliveryTask.fromJson({
        ...taskDoc.data()!,
        'id': taskDoc.id,
      });

      if (task.status != 'pending') return false;

      await taskRef.update({
        'riderId': user.uid,
        'status': 'accepted',
        'acceptedAt': FieldValue.serverTimestamp(),
      });

      return true;
    } catch (e) {
      _error = 'Error accepting task: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateTaskStatus(String taskId, String status) async {
    try {
      final updateData = <String, dynamic>{
        'status': status,
      };

      switch (status) {
        case 'pickedUp':
          updateData['pickedUpAt'] = FieldValue.serverTimestamp();
          break;
        case 'delivered':
          updateData['deliveredAt'] = FieldValue.serverTimestamp();
          break;
        case 'cancelled':
          updateData['rejectionReason'] = 'Cancelled by rider';
          break;
      }

      await _firestore.collection('delivery_tasks').doc(taskId).update(updateData);
      return true;
    } catch (e) {
      _error = 'Error updating task status: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  Future<bool> getOrderDeliveryTask(String orderId) async {
    try {
      final querySnapshot = await _firestore
          .collection('delivery_tasks')
          .where('orderId', isEqualTo: orderId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) return false;

      return true;
    } catch (e) {
      _error = 'Error getting delivery task: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  Future<List<DeliveryTask>> getCustomerDeliveryHistory(String customerId) async {
    try {
      final querySnapshot = await _firestore
          .collection('delivery_tasks')
          .where('customerId', isEqualTo: customerId)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => DeliveryTask.fromJson({
                ...doc.data(),
                'id': doc.id,
              }))
          .toList();
    } catch (e) {
      _error = 'Error getting delivery history: ${e.toString()}';
      notifyListeners();
      return [];
    }
  }

  void refreshData() {
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
