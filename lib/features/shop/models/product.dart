import 'package:cloud_firestore/cloud_firestore.dart';

enum ProductStatus { active, inactive, outOfStock }

class ProductVariant {
  final String id;
  final String name;
  final double price;
  final int stock;
  final Map<String, dynamic>? attributes; // size, color, etc.

  ProductVariant({
    required this.id,
    required this.name,
    required this.price,
    this.stock = 0,
    this.attributes,
  });

  factory ProductVariant.fromMap(Map<String, dynamic> map) {
    return ProductVariant(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      price: map['price']?.toDouble() ?? 0.0,
      stock: map['stock']?.toInt() ?? 0,
      attributes: map['attributes'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'stock': stock,
      'attributes': attributes,
    };
  }
}

class Product {
  final String id;
  final String shopId;
  final String name;
  final String description;
  final double price;
  final double? discountPrice;
  final List<String> imageUrls;
  final String category;
  final List<String> tags;
  final ProductStatus status;
  final int stock;
  final bool hasVariants;
  final List<ProductVariant> variants;
  final double rating;
  final int totalReviews;
  final int totalSales;
  final Map<String, dynamic>? nutritionInfo; // for food items
  final List<String>? ingredients; // for food items
  final List<String>? allergens; // for food items
  final String? brand;
  final String? sku;
  final double? weight;
  final Map<String, String>? dimensions; // length, width, height
  final DateTime createdAt;
  final DateTime updatedAt;

  Product({
    required this.id,
    required this.shopId,
    required this.name,
    required this.description,
    required this.price,
    this.discountPrice,
    this.imageUrls = const [],
    required this.category,
    this.tags = const [],
    this.status = ProductStatus.active,
    this.stock = 0,
    this.hasVariants = false,
    this.variants = const [],
    this.rating = 0.0,
    this.totalReviews = 0,
    this.totalSales = 0,
    this.nutritionInfo,
    this.ingredients,
    this.allergens,
    this.brand,
    this.sku,
    this.weight,
    this.dimensions,
    required this.createdAt,
    required this.updatedAt,
  });

  String get statusString {
    switch (status) {
      case ProductStatus.active:
        return 'active';
      case ProductStatus.inactive:
        return 'inactive';
      case ProductStatus.outOfStock:
        return 'out_of_stock';
    }
  }

  bool get isAvailable => status == ProductStatus.active && (stock > 0 || hasVariants);
  
  bool get hasDiscount => discountPrice != null && discountPrice! < price;
  
  double get finalPrice => discountPrice ?? price;
  
  double get discountPercentage {
    if (!hasDiscount) return 0.0;
    return ((price - discountPrice!) / price) * 100;
  }

  String get formattedPrice => 'KES ${price.toStringAsFixed(2)}';
  
  String get formattedFinalPrice => 'KES ${finalPrice.toStringAsFixed(2)}';
  
  String get formattedRating => rating.toStringAsFixed(1);

  String get mainImageUrl => imageUrls.isNotEmpty ? imageUrls.first : '';

  int get totalStock {
    if (!hasVariants) return stock;
    return variants.fold(0, (total, variant) => total + variant.stock);
  }

  List<ProductVariant> get availableVariants {
    return variants.where((variant) => variant.stock > 0).toList();
  }

  // Factory constructor from Firestore
  factory Product.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Product.fromMap(data, doc.id);
  }

  factory Product.fromMap(Map<String, dynamic> map, String id) {
    return Product(
      id: id,
      shopId: map['shopId'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      price: map['price']?.toDouble() ?? 0.0,
      discountPrice: map['discountPrice']?.toDouble(),
      imageUrls: List<String>.from(map['imageUrls'] ?? []),
      category: map['category'] ?? '',
      tags: List<String>.from(map['tags'] ?? []),
      status: _parseStatus(map['status']),
      stock: map['stock']?.toInt() ?? 0,
      hasVariants: map['hasVariants'] ?? false,
      variants: (map['variants'] as List?)
          ?.map((v) => ProductVariant.fromMap(v as Map<String, dynamic>))
          .toList() ?? [],
      rating: map['rating']?.toDouble() ?? 0.0,
      totalReviews: map['totalReviews']?.toInt() ?? 0,
      totalSales: map['totalSales']?.toInt() ?? 0,
      nutritionInfo: map['nutritionInfo'],
      ingredients: List<String>.from(map['ingredients'] ?? []),
      allergens: List<String>.from(map['allergens'] ?? []),
      brand: map['brand'],
      sku: map['sku'],
      weight: map['weight']?.toDouble(),
      dimensions: Map<String, String>.from(map['dimensions'] ?? {}),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  // Convert to map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'shopId': shopId,
      'name': name,
      'description': description,
      'price': price,
      'discountPrice': discountPrice,
      'imageUrls': imageUrls,
      'category': category,
      'tags': tags,
      'status': statusString,
      'stock': stock,
      'hasVariants': hasVariants,
      'variants': variants.map((v) => v.toMap()).toList(),
      'rating': rating,
      'totalReviews': totalReviews,
      'totalSales': totalSales,
      'nutritionInfo': nutritionInfo,
      'ingredients': ingredients,
      'allergens': allergens,
      'brand': brand,
      'sku': sku,
      'weight': weight,
      'dimensions': dimensions,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  // Create a copy with updated fields
  Product copyWith({
    String? shopId,
    String? name,
    String? description,
    double? price,
    double? discountPrice,
    List<String>? imageUrls,
    String? category,
    List<String>? tags,
    ProductStatus? status,
    int? stock,
    bool? hasVariants,
    List<ProductVariant>? variants,
    double? rating,
    int? totalReviews,
    int? totalSales,
    Map<String, dynamic>? nutritionInfo,
    List<String>? ingredients,
    List<String>? allergens,
    String? brand,
    String? sku,
    double? weight,
    Map<String, String>? dimensions,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Product(
      id: id,
      shopId: shopId ?? this.shopId,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      discountPrice: discountPrice ?? this.discountPrice,
      imageUrls: imageUrls ?? this.imageUrls,
      category: category ?? this.category,
      tags: tags ?? this.tags,
      status: status ?? this.status,
      stock: stock ?? this.stock,
      hasVariants: hasVariants ?? this.hasVariants,
      variants: variants ?? this.variants,
      rating: rating ?? this.rating,
      totalReviews: totalReviews ?? this.totalReviews,
      totalSales: totalSales ?? this.totalSales,
      nutritionInfo: nutritionInfo ?? this.nutritionInfo,
      ingredients: ingredients ?? this.ingredients,
      allergens: allergens ?? this.allergens,
      brand: brand ?? this.brand,
      sku: sku ?? this.sku,
      weight: weight ?? this.weight,
      dimensions: dimensions ?? this.dimensions,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  // Helper method to parse status
  static ProductStatus _parseStatus(String? statusString) {
    switch (statusString?.toLowerCase()) {
      case 'active':
        return ProductStatus.active;
      case 'inactive':
        return ProductStatus.inactive;
      case 'out_of_stock':
        return ProductStatus.outOfStock;
      default:
        return ProductStatus.active;
    }
  }

  @override
  String toString() {
    return 'Product(id: $id, name: $name, price: $formattedFinalPrice, status: $statusString)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Product && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
