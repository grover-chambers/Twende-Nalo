import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/promo.dart';

class PromoService {
  static final PromoService _instance = PromoService._internal();
  factory PromoService() => _instance;
  PromoService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get _userId => _auth.currentUser?.uid ?? '';

  // Get all active promos
  Future<List<Promo>> getPromos() async {
    try {
      final snapshot = await _firestore
          .collection('promos')
          .where('isActive', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return Promo(
          id: doc.id,
          title: data['title'] ?? '',
          description: data['description'] ?? '',
          imageUrl: data['imageUrl'] ?? '',
          discount: (data['discount'] ?? 0.0).toDouble(),
          promoCode: data['promoCode'] ?? '',
        );
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch promos: $e');
    }
  }

  // Get promos by category
  Future<List<Promo>> getPromosByCategory(String category) async {
    try {
      final snapshot = await _firestore
          .collection('promos')
          .where('isActive', isEqualTo: true)
          .where('category', isEqualTo: category)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return Promo(
          id: doc.id,
          title: data['title'] ?? '',
          description: data['description'] ?? '',
          imageUrl: data['imageUrl'] ?? '',
          discount: (data['discount'] ?? 0.0).toDouble(),
          promoCode: data['promoCode'] ?? '',
        );
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch promos by category: $e');
    }
  }

  // Get user-specific promos
  Future<List<Promo>> getUserPromos() async {
    if (_userId.isEmpty) return [];

    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(_userId)
          .collection('promos')
          .where('isActive', isEqualTo: true)
          .orderBy('expiresAt', descending: false)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return Promo(
          id: doc.id,
          title: data['title'] ?? '',
          description: data['description'] ?? '',
          imageUrl: data['imageUrl'] ?? '',
          discount: (data['discount'] ?? 0.0).toDouble(),
          promoCode: data['promoCode'] ?? '',
        );
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch user promos: $e');
    }
  }

  // Apply promo code
  Future<bool> applyPromoCode(String promoCode) async {
    if (_userId.isEmpty) return false;

    try {
      final snapshot = await _firestore
          .collection('promos')
          .where('code', isEqualTo: promoCode.toUpperCase())
          .where('isActive', isEqualTo: true)
          .get();

      if (snapshot.docs.isEmpty) {
        return false;
      }

      final promoDoc = snapshot.docs.first;
      final promoData = promoDoc.data();

      // Check if promo is valid
      final now = DateTime.now();
      final expiresAt = (promoData['expiresAt'] as Timestamp?)?.toDate();
      if (expiresAt != null && now.isAfter(expiresAt)) {
        return false;
      }

      // Add promo to user's collection
      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('applied_promos')
          .doc(promoDoc.id)
          .set({
        'appliedAt': FieldValue.serverTimestamp(),
        'expiresAt': expiresAt,
        'code': promoCode.toUpperCase(),
        'discount': promoData['discount'],
      });

      return true;
    } catch (e) {
      throw Exception('Failed to apply promo code: $e');
    }
  }

  // Check if promo is valid
  Future<bool> validatePromo(String promoId) async {
    try {
      final doc = await _firestore.collection('promos').doc(promoId).get();
      if (!doc.exists) return false;

      final data = doc.data()!;
      if (!(data['isActive'] ?? false)) return false;

      final expiresAt = (data['expiresAt'] as Timestamp?)?.toDate();
      if (expiresAt != null && DateTime.now().isAfter(expiresAt)) {
        return false;
      }

      return true;
    } catch (e) {
      throw Exception('Failed to validate promo: $e');
    }
  }
}
