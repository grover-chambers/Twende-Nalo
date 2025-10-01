import 'package:flutter/material.dart';
import '../models/review.dart';
import '../services/rating_service.dart';

class RatingProvider extends ChangeNotifier {
  final RatingService _ratingService = RatingService();
  
  Stream<List<Review>>? _reviewsStream;
  bool _isLoading = false;
  String? _error;

  Stream<List<Review>>? get reviewsStream => _reviewsStream;
  bool get isLoading => _isLoading;
  String? get error => _error;

  RatingProvider() {
    _initialize();
  }

  Future<void> _initialize() async {
    await fetchReviews();
  }

  Future<void> fetchReviews() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      _reviewsStream = _ratingService.getReviewsForEntity('entityId', ReviewType.userToShop);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> submitReview({
    required String orderId,
    required ReviewType type,
    required String reviewedId,
    required double rating,
    String? comment,
  }) async {
    try {
      await _ratingService.submitReview(
        orderId: orderId,
        type: type,
        reviewedId: reviewedId,
        rating: rating,
        comment: comment,
      );
      await fetchReviews(); // Refresh the reviews after submitting
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
