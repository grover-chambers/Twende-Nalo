import 'package:cloud_firestore/cloud_firestore.dart';

class Promo {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final double discount;
  final String promoCode;
  final DateTime? expiresAt;

  Promo({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.discount,
    required this.promoCode,
    this.expiresAt,
  });

  factory Promo.fromFirestore(Map<String, dynamic> data, String id) {
    return Promo(
      id: id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      discount: (data['discount'] ?? 0.0).toDouble(),
      promoCode: data['promoCode'] ?? '',
      expiresAt: (data['expiresAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'discount': discount,
      'promoCode': promoCode,
      'expiresAt': expiresAt != null ? Timestamp.fromDate(expiresAt!) : null,
    };
  }
}
