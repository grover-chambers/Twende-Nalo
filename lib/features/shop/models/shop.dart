import 'package:cloud_firestore/cloud_firestore.dart';

class Shop {
  final String id;
  final String name;
  final String description;
  final String category;
  final String address;
  final String city;
  final double latitude;
  final double longitude;
  final String ownerId;
  final String phone;
  final String email;
  final String? imageUrl;
  final double rating;
  final int totalReviews;
  final bool isActive;
  final Map<String, dynamic> operatingHours;
  final DateTime createdAt;
  final DateTime updatedAt;

  Shop({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.address,
    required this.city,
    required this.latitude,
    required this.longitude,
    required this.ownerId,
    required this.phone,
    required this.email,
    this.imageUrl,
    this.rating = 0.0,
    this.totalReviews = 0,
    this.isActive = true,
    required this.operatingHours,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Shop.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Shop(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      category: data['category'] ?? '',
      address: data['address'] ?? '',
      city: data['city'] ?? '',
      latitude: (data['latitude'] ?? 0.0).toDouble(),
      longitude: (data['longitude'] ?? 0.0).toDouble(),
      ownerId: data['ownerId'] ?? '',
      phone: data['phone'] ?? '',
      email: data['email'] ?? '',
      imageUrl: data['imageUrl'],
      rating: (data['rating'] ?? 0.0).toDouble(),
      totalReviews: data['totalReviews'] ?? 0,
      isActive: data['isActive'] ?? true,
      operatingHours: Map<String, dynamic>.from(data['operatingHours'] ?? {}),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'category': category,
      'address': address,
      'city': city,
      'latitude': latitude,
      'longitude': longitude,
      'ownerId': ownerId,
      'phone': phone,
      'email': email,
      'imageUrl': imageUrl,
      'rating': rating,
      'totalReviews': totalReviews,
      'isActive': isActive,
      'operatingHours': operatingHours,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  double get distance {
    // This would be calculated based on current location
    return 0.0;
  }

  bool get isOpen {
    final now = DateTime.now();
    final day = _getDayName(now.weekday);
    final hours = operatingHours[day];
    
    if (hours == null) return false;
    
    final openTime = _parseTime(hours['open']);
    final closeTime = _parseTime(hours['close']);
    
    if (openTime == null || closeTime == null) return false;
    
    return now.isAfter(openTime) && now.isBefore(closeTime);
  }

  String _getDayName(int weekday) {
    const days = ['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday'];
    return days[weekday - 1];
  }

  DateTime? _parseTime(String timeStr) {
    try {
      final parts = timeStr.split(':');
      if (parts.length != 2) return null;
      
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);
      
      final now = DateTime.now();
      return DateTime(now.year, now.month, now.day, hour, minute);
    } catch (e) {
      return null;
    }
  }

  Shop copyWith({
    String? id,
    String? name,
    String? description,
    String? category,
    String? address,
    String? city,
    double? latitude,
    double? longitude,
    String? ownerId,
    String? phone,
    String? email,
    String? imageUrl,
    double? rating,
    int? totalReviews,
    bool? isActive,
    Map<String, dynamic>? operatingHours,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Shop(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      address: address ?? this.address,
      city: city ?? this.city,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      ownerId: ownerId ?? this.ownerId,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      imageUrl: imageUrl ?? this.imageUrl,
      rating: rating ?? this.rating,
      totalReviews: totalReviews ?? this.totalReviews,
      isActive: isActive ?? this.isActive,
      operatingHours: operatingHours ?? this.operatingHours,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

enum ShopCategory {
  restaurant,
  grocery,
  pharmacy,
  electronics,
  clothing,
  beauty,
  hardware,
  other;

  String get displayName {
    switch (this) {
      case ShopCategory.restaurant:
        return 'Restaurant';
      case ShopCategory.grocery:
        return 'Grocery';
      case ShopCategory.pharmacy:
        return 'Pharmacy';
      case ShopCategory.electronics:
        return 'Electronics';
      case ShopCategory.clothing:
        return 'Clothing';
      case ShopCategory.beauty:
        return 'Beauty';
      case ShopCategory.hardware:
        return 'Hardware';
      case ShopCategory.other:
        return 'Other';
    }
  }
}
