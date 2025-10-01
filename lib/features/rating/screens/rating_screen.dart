import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/review.dart';
import '../providers/rating_provider.dart';
import '../widgets/rating_bar.dart';

class RatingScreen extends StatefulWidget {
  final String orderId;
  final String reviewedId;
  final ReviewType reviewType;

  const RatingScreen({
    super.key,
    required this.orderId,
    required this.reviewedId,
    required this.reviewType,
  });

  @override
  State<RatingScreen> createState() => _RatingScreenState();
}

class _RatingScreenState extends State<RatingScreen> {
  double _selectedRating = 0.0;
  final TextEditingController _commentController = TextEditingController();
  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Rate ${_getReviewTypeDescription()}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Rating selection
            Center(
              child: Column(
                children: [
                  const Text(
                    'How was your experience?',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  InteractiveRatingBar(
                    initialRating: _selectedRating,
                    onRatingChanged: (rating) {
                      setState(() {
                        _selectedRating = rating;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _getRatingDescription(_selectedRating),
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Comment section
            Text(
              'Add a comment (optional)',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _commentController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Share your experience...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
            ),

            const SizedBox(height: 32),

            // Submit button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _selectedRating > 0 ? _submitReview : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isSubmitting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Submit Review',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getReviewTypeDescription() {
    switch (widget.reviewType) {
      case ReviewType.userToShop:
        return 'Shop';
      case ReviewType.userToRider:
        return 'Rider';
      case ReviewType.shopToUser:
        return 'Customer';
      case ReviewType.riderToUser:
        return 'Customer';
    }
  }

  String _getRatingDescription(double rating) {
    if (rating == 0) return 'Tap stars to rate';
    if (rating <= 2) return 'Poor';
    if (rating <= 3) return 'Average';
    if (rating <= 4) return 'Good';
    return 'Excellent';
  }

  Future<void> _submitReview() async {
    if (_selectedRating == 0) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      final ratingProvider = Provider.of<RatingProvider>(context, listen: false);
      await ratingProvider.submitReview(
        orderId: widget.orderId,
        type: widget.reviewType,
        reviewedId: widget.reviewedId,
        rating: _selectedRating,
        comment: _commentController.text.isNotEmpty ? _commentController.text : null,
      );

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Review submitted successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      // Navigate back
      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to submit review: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }
}
