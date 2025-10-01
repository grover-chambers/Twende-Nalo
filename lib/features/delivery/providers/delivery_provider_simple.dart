import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/delivery_task.dart';

class DeliveryProviderSimple extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<DeliveryTask?> getDeliveryTask(String orderId) {
    return _firestore
        .collection('delivery_tasks')
        .where('orderId', isEqualTo: orderId)
        .limit(1)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isEmpty) return null;
      return DeliveryTask.fromJson(
        snapshot.docs.first.data(),
      );
    });
  }

  Future<void> updateDeliveryStatus(String deliveryId, String status) async {
    try {
      await _firestore.collection('delivery_tasks').doc(deliveryId).update({
        'status': status,
        '${status}At': FieldValue.serverTimestamp(),
      });
      notifyListeners();
    } catch (e) {
      throw Exception('Failed to update delivery status: $e');
    }
  }

  Future<DeliveryTask?> getDeliveryTaskById(String deliveryId) async {
    try {
      final doc = await _firestore.collection('delivery_tasks').doc(deliveryId).get();
      if (doc.exists) {
        return DeliveryTask.fromJson(doc.data()!);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get delivery task: $e');
    }
  }
}
