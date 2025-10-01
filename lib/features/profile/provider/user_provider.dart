import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Map<String, dynamic>? _currentUser;
  List<Map<String, dynamic>> _orders = [];
  bool _isLoading = false;
  String? _error;

  Map<String, dynamic>? get currentUser => _currentUser;
  List<Map<String, dynamic>> get orders => _orders;
  bool get isLoading => _isLoading;
  String? get error => _error;

  String? get userRole => _currentUser?['role'];
  String? get userName => _currentUser?['name'];
  String? get userPhone => _currentUser?['phone'];
  String? get userEmail => _currentUser?['email'];
  String? get referralCode => _currentUser?['referralCode'];

  Future<void> loadCurrentUser() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final doc = await _firestore
          .collection('users')
          .doc(user.uid)
          .get();

      if (doc.exists) {
        _currentUser = doc.data();
        _currentUser!['uid'] = user.uid;
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = 'Failed to load user data: $e';
      notifyListeners();
    }
  }

  Future<bool> updateUserProfile({
    String? name,
    String? phone,
    String? email,
    String? address,
    String? vehicleType,
    String? licenseNumber,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return false;

    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      Map<String, dynamic> updates = {
        'updatedAt': Timestamp.now(),
      };

      if (name != null) updates['name'] = name;
      if (phone != null) updates['phone'] = phone;
      if (email != null) updates['email'] = email;
      if (address != null) updates['address'] = address;
      if (vehicleType != null) updates['vehicleType'] = vehicleType;
      if (licenseNumber != null) updates['licenseNumber'] = licenseNumber;

      await _firestore
          .collection('users')
          .doc(user.uid)
          .update(updates);

      // Update local user data
      if (_currentUser != null) {
        _currentUser!.addAll(updates);
        _currentUser!['updatedAt'] = Timestamp.now();
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = 'Failed to update profile: $e';
      notifyListeners();
      return false;
    }
  }

  Future<void> loadUserOrders() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final querySnapshot = await _firestore
          .collection('orders')
          .where('userId', isEqualTo: user.uid)
          .orderBy('createdAt', descending: true)
          .get();

      _orders = querySnapshot.docs
          .map((doc) => {
                'id': doc.id,
                ...doc.data(),
              })
          .toList();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = 'Failed to load orders: $e';
      notifyListeners();
    }
  }

  Future<bool> createOrder(Map<String, dynamic> orderData) async {
    final user = _auth.currentUser;
    if (user == null) return false;

    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final order = {
        'userId': user.uid,
        'userEmail': user.email,
        'userName': _currentUser?['name'] ?? 'Unknown',
        'userPhone': _currentUser?['phone'] ?? '',
        'status': 'pending',
        'createdAt': Timestamp.now(),
        'updatedAt': Timestamp.now(),
        ...orderData,
      };

      await _firestore.collection('orders').add(order);

      // Reload orders to include the new one
      await loadUserOrders();

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = 'Failed to create order: $e';
      notifyListeners();
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> searchUsers(String query) async {
    if (query.isEmpty) return [];

    try {
      final querySnapshot = await _firestore
          .collection('users')
          .where('name', isGreaterThanOrEqualTo: query)
          .where('name', isLessThan: '${query}z')
          .limit(10)
          .get();

      return querySnapshot.docs
          .map((doc) => {
                'id': doc.id,
                ...doc.data(),
              })
          .toList();
    } catch (e) {
      _error = 'Failed to search users: $e';
      notifyListeners();
      return [];
    }
  }

  Future<Map<String, dynamic>?> getUserById(String userId) async {
    try {
      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .get();

      if (doc.exists) {
        return {
          'id': doc.id,
          ...doc.data()!,
        };
      }
      return null;
    } catch (e) {
      _error = 'Failed to get user: $e';
      notifyListeners();
      return null;
    }
  }

  Future<bool> updateUserRole(String newRole) async {
    final user = _auth.currentUser;
    if (user == null) return false;

    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _firestore
          .collection('users')
          .doc(user.uid)
          .update({
            'role': newRole,
            'updatedAt': Timestamp.now(),
          });

      if (_currentUser != null) {
        _currentUser!['role'] = newRole;
        // No need to set this again, it's in the updates map
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = 'Failed to update role: $e';
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void clearUser() {
    _currentUser = null;
    _orders.clear();
    _error = null;
    notifyListeners();
  }
}