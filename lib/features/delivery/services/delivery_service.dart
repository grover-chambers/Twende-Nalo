import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/delivery_task.dart';

class DeliveryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Create a new delivery task
  Future<String> createDeliveryTask(DeliveryTask task) async {
    try {
      final docRef = await _firestore.collection('delivery_tasks').add(task.toJson());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create delivery task: $e');
    }
  }

  // Get delivery task by ID
  Future<DeliveryTask?> getDeliveryTask(String taskId) async {
    try {
      final doc = await _firestore.collection('delivery_tasks').doc(taskId).get();
      if (doc.exists) {
        return DeliveryTask.fromJson({
          ...doc.data()!,
          'id': doc.id,
        });
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get delivery task: $e');
    }
  }

  // Update delivery task status
  Future<void> updateDeliveryStatus(String taskId, String status, {String? notes}) async {
    try {
      final updateData = <String, dynamic>{
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      switch (status) {
        case 'pickedUp':
          updateData['pickedUpAt'] = FieldValue.serverTimestamp();
          break;
        case 'delivered':
          updateData['deliveredAt'] = FieldValue.serverTimestamp();
          break;
        case 'cancelled':
          updateData['rejectionReason'] = notes ?? 'Cancelled';
          break;
      }

      await _firestore.collection('delivery_tasks').doc(taskId).update(updateData);
    } catch (e) {
      throw Exception('Failed to update delivery status: $e');
    }
  }

  // Get all pending delivery tasks
  Stream<List<DeliveryTask>> getPendingDeliveries() {
    return _firestore
        .collection('delivery_tasks')
        .where('status', isEqualTo: 'pending')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => DeliveryTask.fromJson({
                  ...doc.data(),
                  'id': doc.id,
                }))
            .toList());
  }

  // Get deliveries for a specific rider
  Stream<List<DeliveryTask>> getRiderDeliveries(String riderId) {
    return _firestore
        .collection('delivery_tasks')
        .where('riderId', isEqualTo: riderId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => DeliveryTask.fromJson({
                  ...doc.data(),
                  'id': doc.id,
                }))
            .toList());
  }

  // Get deliveries for a specific customer
  Stream<List<DeliveryTask>> getCustomerDeliveries(String customerId) {
    return _firestore
        .collection('delivery_tasks')
        .where('customerId', isEqualTo: customerId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => DeliveryTask.fromJson({
                  ...doc.data(),
                  'id': doc.id,
                }))
            .toList());
  }

  // Assign delivery to rider
  Future<void> assignDeliveryToRider(String taskId, String riderId) async {
    try {
      await _firestore.collection('delivery_tasks').doc(taskId).update({
        'riderId': riderId,
        'status': 'accepted',
        'acceptedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to assign delivery to rider: $e');
    }
  }

  // Get active deliveries for rider
  Stream<List<DeliveryTask>> getActiveDeliveries(String riderId) {
    return _firestore
        .collection('delivery_tasks')
        .where('riderId', isEqualTo: riderId)
        .where('status', whereIn: ['accepted', 'pickedUp'])
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => DeliveryTask.fromJson({
                  ...doc.data(),
                  'id': doc.id,
                }))
            .toList());
  }
}
