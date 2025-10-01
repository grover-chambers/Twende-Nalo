import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CartService extends ChangeNotifier {
  static const String _cartKey = 'user_cart';
  
  List<CartItem> _items = [];
  double _totalAmount = 0.0;
  String? _currentShopId;
  String? _deliveryAddress;
  DateTime? _deliveryTime;
  String? _specialInstructions;

  // Getters
  List<CartItem> get items => _items;
  double get totalAmount => _totalAmount;
  int get itemCount => _items.length;
  String? get currentShopId => _currentShopId;
  String? get deliveryAddress => _deliveryAddress;
  DateTime? get deliveryTime => _deliveryTime;
  String? get specialInstructions => _specialInstructions;
  bool get isEmpty => _items.isEmpty;
  bool get hasItems => _items.isNotEmpty;

  CartService() {
    _loadCartFromStorage();
  }

  // Add item to cart
  Future<void> addItem({
    required String productId,
    required String productName,
    required String productImage,
    required double price,
    required int quantity,
    required String shopId,
    required String shopName,
    String? selectedOptions,
  }) async {
    if (_currentShopId != null && _currentShopId != shopId) {
      throw Exception('Cannot add items from different shops to the same cart');
    }

    final existingIndex = _items.indexWhere(
      (item) => item.productId == productId && item.selectedOptions == selectedOptions
    );

    if (existingIndex >= 0) {
      _items[existingIndex].quantity += quantity;
    } else {
      _items.add(CartItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        productId: productId,
        productName: productName,
        productImage: productImage,
        price: price,
        quantity: quantity,
        selectedOptions: selectedOptions,
        shopId: shopId,
        shopName: shopName,
      ));
    }

    if (_currentShopId == null) {
      _currentShopId = shopId;
    }

    _calculateTotal();
    await _saveCartToStorage();
    notifyListeners();
  }

  // Remove item from cart
  Future<void> removeItem(String itemId) async {
    _items.removeWhere((item) => item.id == itemId);
    
    if (_items.isEmpty) {
      _currentShopId = null;
    }
    
    _calculateTotal();
    await _saveCartToStorage();
    notifyListeners();
  }

  // Update item quantity
  Future<void> updateItemQuantity(String itemId, int newQuantity) async {
    if (newQuantity <= 0) {
      await removeItem(itemId);
      return;
    }

    final index = _items.indexWhere((item) => item.id == itemId);
    if (index >= 0) {
      _items[index].quantity = newQuantity;
      _calculateTotal();
      await _saveCartToStorage();
      notifyListeners();
    }
  }

  // Clear cart
  Future<void> clearCart() async {
    _items.clear();
    _totalAmount = 0.0;
    _currentShopId = null;
    _deliveryAddress = null;
    _deliveryTime = null;
    _specialInstructions = null;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cartKey);
    notifyListeners();
  }

  // Calculate total amount
  void _calculateTotal() {
    _totalAmount = _items.fold(0.0, (sum, item) => sum + (item.price * item.quantity));
  }

  // Set delivery details
  void setDeliveryDetails({
    required String address,
    required DateTime deliveryTime,
    String? instructions,
  }) {
    _deliveryAddress = address;
    _deliveryTime = deliveryTime;
    _specialInstructions = instructions;
    notifyListeners();
  }

  // Save cart to local storage
  Future<void> _saveCartToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartData = {
        'items': _items.map((item) => item.toJson()).toList(),
        'totalAmount': _totalAmount,
        'currentShopId': _currentShopId,
        'deliveryAddress': _deliveryAddress,
        'deliveryTime': _deliveryTime?.toIso8601String(),
        'specialInstructions': _specialInstructions,
      };
      await prefs.setString(_cartKey, json.encode(cartData));
    } catch (e) {
      debugPrint('Error saving cart to storage: $e');
    }
  }

  // Load cart from local storage
  Future<void> _loadCartFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartString = prefs.getString(_cartKey);
      
      if (cartString != null) {
        final cartData = json.decode(cartString);
        _items = (cartData['items'] as List)
            .map((item) => CartItem.fromJson(item))
            .toList();
        _totalAmount = cartData['totalAmount'] ?? 0.0;
        _currentShopId = cartData['currentShopId'];
        _deliveryAddress = cartData['deliveryAddress'];
        _deliveryTime = cartData['deliveryTime'] != null 
            ? DateTime.parse(cartData['deliveryTime']) 
            : null;
        _specialInstructions = cartData['specialInstructions'];
        
        _calculateTotal();
      }
    } catch (e) {
      debugPrint('Error loading cart from storage: $e');
    }
    notifyListeners();
  }

  // Sync cart with Firebase (placeholder - implement based on your FirebaseService)
  Future<void> syncCartWithFirebase(String userId) async {
    try {
      // Implement based on your FirebaseService structure
      debugPrint('Syncing cart for user: $userId');
    } catch (e) {
      debugPrint('Error syncing cart with Firebase: $e');
    }
  }

  // Load cart from Firebase (placeholder - implement based on your FirebaseService)
  Future<void> loadCartFromFirebase(String userId) async {
    try {
      // Implement based on your FirebaseService structure
      debugPrint('Loading cart for user: $userId');
    } catch (e) {
      debugPrint('Error loading cart from Firebase: $e');
    }
  }

  // Prepare checkout data
  Map<String, dynamic> prepareCheckoutData() {
    return {
      'items': _items.map((item) => item.toJson()).toList(),
      'totalAmount': _totalAmount,
      'shopId': _currentShopId,
      'deliveryAddress': _deliveryAddress,
      'deliveryTime': _deliveryTime?.toIso8601String(),
      'specialInstructions': _specialInstructions,
      'itemCount': _items.length,
    };
  }

  // Validate cart before checkout
  bool validateCartForCheckout() {
    if (_items.isEmpty) {
      throw Exception('Cart is empty');
    }
    
    if (_deliveryAddress == null || _deliveryTime == null) {
      throw Exception('Delivery details are required');
    }
    
    if (_totalAmount <= 0) {
      throw Exception('Invalid cart total');
    }
    
    return true;
  }

  // Get cart summary
  Map<String, dynamic> getCartSummary() {
    return {
      'itemCount': _items.length,
      'totalAmount': _totalAmount,
      'shopName': _items.isNotEmpty ? _items.first.shopName : null,
      'estimatedDeliveryTime': _deliveryTime,
    };
  }

  // Check if product is in cart
  bool isProductInCart(String productId) {
    return _items.any((item) => item.productId == productId);
  }

  // Get item quantity by product ID
  int getItemQuantity(String productId) {
    final item = _items.firstWhere(
      (item) => item.productId == productId,
      orElse: () => CartItem(
        id: '',
        productId: '',
        productName: '',
        productImage: '',
        price: 0,
        quantity: 0,
        shopId: '',
        shopName: '',
      ),
    );
    return item.quantity;
  }

  // Get items by shop
  List<CartItem> getItemsByShop(String shopId) {
    return _items.where((item) => item.shopId == shopId).toList();
  }

  // Calculate delivery fee
  double calculateDeliveryFee() {
    if (_totalAmount >= 1000) {
      return 0.0;
    }
    return 100.0;
  }

  // Calculate tax
  double calculateTax() {
    return _totalAmount * 0.16;
  }

  // Get final total including delivery and tax
  double getFinalTotal() {
    return _totalAmount + calculateDeliveryFee() + calculateTax();
  }
}

class CartItem {
  final String id;
  final String productId;
  final String productName;
  final String productImage;
  final double price;
  int quantity;
  final String? selectedOptions;
  final String shopId;
  final String shopName;

  CartItem({
    required this.id,
    required this.productId,
    required this.productName,
    required this.productImage,
    required this.price,
    required this.quantity,
    this.selectedOptions,
    required this.shopId,
    required this.shopName,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productId': productId,
      'productName': productName,
      'productImage': productImage,
      'price': price,
      'quantity': quantity,
      'selectedOptions': selectedOptions,
      'shopId': shopId,
      'shopName': shopName,
    };
  }

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'],
      productId: json['productId'],
      productName: json['productName'],
      productImage: json['productImage'],
      price: json['price'].toDouble(),
      quantity: json['quantity'],
      selectedOptions: json['selectedOptions'],
      shopId: json['shopId'],
      shopName: json['shopName'],
    );
  }

  double get totalPrice => price * quantity;
}
