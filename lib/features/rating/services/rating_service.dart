import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/review.dart';

class RatingService {
  static final RatingService _instance = RatingService._internal();
  factory RatingService() => _instance;
  RatingService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get _userId => _auth.currentUser?.uid ?? '';

  // Submit a review
  Future<void> submitReview({
    required String orderId,
    required ReviewType type,
    required String reviewedId,
    required double rating,
    String? comment,
  }) async {
    if (_userId.isEmpty) throw Exception('User not authenticated');

    final review = Review(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      orderId: orderId,
      type: type,
      reviewerId: _userId,
      reviewedId: reviewedId,
      rating: rating,
      comment: comment,
      createdAt: DateTime.now(),
    );

    await _firestore
        .collection('reviews')
        .doc(review.id)
        .set(review.toFirestore());

    // Update average rating for the reviewed entity
    await _updateAverageRating(reviewedId, type);
  }

  // Get reviews for a specific entity
  Stream<List<Review>> getReviewsForEntity(String entityId, ReviewType type) {
    return _firestore
        .collection('reviews')
        .where('reviewedId', isEqualTo: entityId)
        .where('type', isEqualTo: type.name)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Review.fromFirestore(doc))
            .toList());
  }

  // Get reviews by a specific user
  Stream<List<Review>> getReviewsByUser(String userId) {
    return _firestore
        .collection('reviews')
        .where('reviewerId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Review.fromFirestore(doc))
            .toList());
  }

  // Get average rating for an entity
  Future<double> getAverageRating(String entityId, ReviewType type) async {
    final snapshot = await _firestore
        .collection('reviews')
        .where('reviewedId', isEqualTo: entityId)
        .where('type', isEqualTo: type.name)
        .get();

    if (snapshot.docs.isEmpty) return 0.0;

    final totalRating = snapshot.docs.fold<double>(
      0.0,
      (sum, doc) => sum + (doc.data()['rating'] as double),
    );

    return totalRating / snapshot.docs.length;
  }

  // Update average rating for an entity
  Future<void> _updateAverageRating(String entityId, ReviewType type) async {
    final averageRating = await getAverageRating(entityId, type);

    String collectionName;
    switch (type) {
      case ReviewType.userToShop:
      case ReviewType.shopToUser:
        collectionName = 'shops';
        break;
      case ReviewType.userToRider:
      case ReviewType.riderToUser:
        collectionName = 'riders';
        break;
    }

    await _firestore
        .collection(collectionName)
        .doc(entityId)
        .update({'averageRating': averageRating});
  }

  // Check if user has already reviewed this order
  Future<bool> hasUserReviewedOrder(String orderId, ReviewType type) async {
    if (_userId.isEmpty) return false;

    final snapshot = await _firestore
        .collection('reviews')
        .where('orderId', isEqualTo: orderId)
        .where('reviewerId', isEqualTo: _userId)
        .where('type', isEqualTo: type.name)
        .get();

    return snapshot.docs.isNotEmpty;
  }

  // Get reviews for an order
  Stream<List<Review>> getOrderReviews(String orderId) {
    return _firestore
        .collection('reviews')
        .where('orderId', isEqualTo: orderId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Review.fromFirestore(doc))
            .toList());
  }

  // Delete a review
  Future<void> deleteReview(String reviewId) async {
    await _firestore.collection('reviews').doc(reviewId).delete();
  }

  // Get review statistics
  Future<Map<String, dynamic>> getReviewStats(String entityId, ReviewType type) async {
    final snapshot = await _firestore
        .collection('reviews')
        .where('reviewedId', isEqualTo: entityId)
        .where('type', isEqualTo: type.name)
        .get();

    final reviews = snapshot.docs.map((doc) => Review.fromFirestore(doc)).toList();

    final ratingCounts = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0};
    for (final review in reviews) {
      final rating = review.rating.round();
      if (rating >= 1 && rating <= 5) {
        ratingCounts[rating] = (ratingCounts[rating] ?? 0) + 1;
      }
    }

    return {
      'totalReviews': reviews.length,
      'averageRating': reviews.isEmpty ? 0.0 : reviews.map((r) => r.rating).reduce((a, b) => a + b) / reviews.length,
      'ratingCounts': ratingCounts,
    };
  }
}
