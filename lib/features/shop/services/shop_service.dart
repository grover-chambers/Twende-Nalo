import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math' as math;
import '../models/shop.dart';

class ShopService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Shop>> getAllShops() async {
    try {
      final snapshot = await _firestore.collection('shops').get();
      return snapshot.docs.map((doc) => Shop.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Failed to load shops: $e');
    }
  }

  Future<List<Shop>> searchShops(String query) async {
    try {
      final snapshot = await _firestore
          .collection('shops')
          .where('name', isGreaterThanOrEqualTo: query)
          .where('name', isLessThanOrEqualTo: '$query\uf8ff')
          .get();
      return snapshot.docs.map((doc) => Shop.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Failed to search shops: $e');
    }
  }

  Future<List<Shop>> getShopsByCategory(String category) async {
    try {
      final snapshot = await _firestore
          .collection('shops')
          .where('category', isEqualTo: category)
          .get();
      return snapshot.docs.map((doc) => Shop.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Failed to load shops by category: $e');
    }
  }

  Future<Shop?> getShopById(String shopId) async {
    try {
      final doc = await _firestore.collection('shops').doc(shopId).get();
      if (doc.exists) {
        return Shop.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to load shop: $e');
    }
  }

  Future<List<Shop>> getNearbyShops(double latitude, double longitude, double radiusKm) async {
    try {
      // This is a simplified version. In production, you'd use geohashing
      final snapshot = await _firestore.collection('shops').get();
      final shops = snapshot.docs.map((doc) => Shop.fromFirestore(doc)).toList();
      
      // Filter by distance (simplified)
      return shops.where((shop) {
        final distance = _calculateDistance(
          latitude,
          longitude,
          shop.latitude,
          shop.longitude,
        );
        return distance <= radiusKm;
      }).toList();
    } catch (e) {
      throw Exception('Failed to load nearby shops: $e');
    }
  }

  double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const R = 6371; // Earth's radius in kilometers
    final dLat = _degreesToRadians(lat2 - lat1);
    final dLon = _degreesToRadians(lon2 - lon1);
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_degreesToRadians(lat1)) *
            math.cos(_degreesToRadians(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return R * c;
  }

  double _degreesToRadians(double degrees) => degrees * math.pi / 180;
}
