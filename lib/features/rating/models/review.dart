import 'package:cloud_firestore/cloud_firestore.dart';

enum ReviewType {
  userToShop,
  userToRider,
  shopToUser,
  riderToUser,
}

class Review {
  final String id;
  final String orderId;
  final ReviewType type;
  final String reviewerId;
  final String reviewedId;
  final double rating;
  final String? comment;
  final DateTime createdAt;

  Review({
    required this.id,
    required this.orderId,
    required this.type,
    required this.reviewerId,
    required this.reviewedId,
    required this.rating,
    this.comment,
    required this.createdAt,
  });

  factory Review.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Review(
      id: doc.id,
      orderId: data['orderId'] ?? '',
      type: _parseReviewType(data['type']),
      reviewerId: data['reviewerId'] ?? '',
      reviewedId: data['reviewedId'] ?? '',
      rating: (data['rating'] ?? 0.0).toDouble(),
      comment: data['comment'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'orderId': orderId,
      'type': type.name,
      'reviewerId': reviewerId,
      'reviewedId': reviewedId,
      'rating': rating,
      'comment': comment,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  static ReviewType _parseReviewType(String? type) {
    return ReviewType.values.firstWhere(
      (e) => e.name == type,
      orElse: () => ReviewType.userToShop,
    );
  }

  String get typeDescription {
    switch (type) {
      case ReviewType.userToShop:
        return 'User to Shop';
      case ReviewType.userToRider:
        return 'User to Rider';
      case ReviewType.shopToUser:
        return 'Shop to User';
      case ReviewType.riderToUser:
        return 'Rider to User';
    }
  }
}
