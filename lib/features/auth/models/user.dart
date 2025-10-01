import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole { customer, shopOwner, rider }

enum UserStatus { active, inactive, suspended, pending }

class User {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String? phoneNumber;
  final String? profileImageUrl;
  final UserRole role;
  final UserStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic>? metadata;

  // Location data
  final double? latitude;
  final double? longitude;
  final String? address;
  final String? city;
  final String? country;

  // Role-specific data
  final String? shopId; // For shop owners
  final bool? isAvailable; // For riders
  final double? rating; // For riders and shop owners
  final int? totalDeliveries; // For riders
  final int? totalOrders; // For customers

  User({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.phoneNumber,
    this.profileImageUrl,
    required this.role,
    this.status = UserStatus.active,
    required this.createdAt,
    required this.updatedAt,
    this.metadata,
    this.latitude,
    this.longitude,
    this.address,
    this.city,
    this.country,
    this.shopId,
    this.isAvailable,
    this.rating,
    this.totalDeliveries,
    this.totalOrders,
  });

  String get fullName => '$firstName $lastName';

  String get initials {
    String firstInitial = firstName.isNotEmpty ? firstName[0].toUpperCase() : '';
    String lastInitial = lastName.isNotEmpty ? lastName[0].toUpperCase() : '';
    return firstInitial + lastInitial;
  }

  bool get hasLocation => latitude != null && longitude != null;

  String get roleString {
    switch (role) {
      case UserRole.customer:
        return 'customer';
      case UserRole.shopOwner:
        return 'shop_owner';
      case UserRole.rider:
        return 'rider';
    }
  }

  String get statusString {
    switch (status) {
      case UserStatus.active:
        return 'active';
      case UserStatus.inactive:
        return 'inactive';
      case UserStatus.suspended:
        return 'suspended';
      case UserStatus.pending:
        return 'pending';
    }
  }

  // Factory constructor from Firestore document
  factory User.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return User.fromMap(data, doc.id);
  }

  // Factory constructor from map
  factory User.fromMap(Map<String, dynamic> map, String id) {
    return User(
      id: id,
      email: map['email'] ?? '',
      firstName: map['firstName'] ?? '',
      lastName: map['lastName'] ?? '',
      phoneNumber: map['phoneNumber'],
      profileImageUrl: map['profileImageUrl'],
      role: _parseRole(map['role']),
      status: _parseStatus(map['status']),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      metadata: map['metadata'],
      latitude: map['latitude']?.toDouble(),
      longitude: map['longitude']?.toDouble(),
      address: map['address'],
      city: map['city'],
      country: map['country'],
      shopId: map['shopId'],
      isAvailable: map['isAvailable'],
      rating: map['rating']?.toDouble(),
      totalDeliveries: map['totalDeliveries']?.toInt(),
      totalOrders: map['totalOrders']?.toInt(),
    );
  }

  // Convert to map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'phoneNumber': phoneNumber,
      'profileImageUrl': profileImageUrl,
      'role': roleString,
      'status': statusString,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'metadata': metadata,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'city': city,
      'country': country,
      'shopId': shopId,
      'isAvailable': isAvailable,
      'rating': rating,
      'totalDeliveries': totalDeliveries,
      'totalOrders': totalOrders,
    };
  }

  // Create a copy with updated fields
  User copyWith({
    String? email,
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? profileImageUrl,
    UserRole? role,
    UserStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? metadata,
    double? latitude,
    double? longitude,
    String? address,
    String? city,
    String? country,
    String? shopId,
    bool? isAvailable,
    double? rating,
    int? totalDeliveries,
    int? totalOrders,
  }) {
    return User(
      id: id,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      role: role ?? this.role,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      metadata: metadata ?? this.metadata,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      address: address ?? this.address,
      city: city ?? this.city,
      country: country ?? this.country,
      shopId: shopId ?? this.shopId,
      isAvailable: isAvailable ?? this.isAvailable,
      rating: rating ?? this.rating,
      totalDeliveries: totalDeliveries ?? this.totalDeliveries,
      totalOrders: totalOrders ?? this.totalOrders,
    );
  }

  // Helper method to parse role from string
  static UserRole _parseRole(String? roleString) {
    switch (roleString?.toLowerCase()) {
      case 'customer':
        return UserRole.customer;
      case 'shop_owner':
        return UserRole.shopOwner;
      case 'rider':
        return UserRole.rider;
      default:
        return UserRole.customer;
    }
  }

  // Helper method to parse status from string
  static UserStatus _parseStatus(String? statusString) {
    switch (statusString?.toLowerCase()) {
      case 'active':
        return UserStatus.active;
      case 'inactive':
        return UserStatus.inactive;
      case 'suspended':
        return UserStatus.suspended;
      case 'pending':
        return UserStatus.pending;
      default:
        return UserStatus.active;
    }
  }

  @override
  String toString() {
    return 'User(id: $id, email: $email, fullName: $fullName, role: $roleString, status: $statusString)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
