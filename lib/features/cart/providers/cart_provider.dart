// Create this file at: lib/providers/cart_provider.dart

import 'package:flutter/foundation.dart';

class _CartItem {
  final String id;
  final String name;
  final double price;
  final String image;
  final String category;
  int quantity;

  _CartItem({
    required this.id,
    required this.name,
    required this.price,
    required this.image,
    required this.category,
    this.quantity = 1,
  });

  // Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'image': image,
      'category': category,
      'quantity': quantity,
    };
  }

  // Create from JSON
  factory _CartItem.fromJson(Map<String, dynamic> json) {
    return _CartItem(
      id: json['id'],
      name: json['name'],
      price: json['price'].toDouble(),
      image: json['image'],
      category: json['category'],
      quantity: json['quantity'],
    );
  }
}

class CartProvider extends ChangeNotifier {
  final List<_CartItem> _items = [];
  bool _isLoading = false;

  // Getters
  List<_CartItem> get items => [..._items];
  bool get isLoading => _isLoading;
  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);
  double get totalAmount => _items.fold(0.0, (sum, item) => sum + (item.price * item.quantity));
  bool get isEmpty => _items.isEmpty;

  // Add item to cart
  void addItem(Map<String, dynamic> product) {
    final existingIndex = _items.indexWhere((item) => item.id == product['id']);
    
    if (existingIndex >= 0) {
      // Item already exists, increase quantity
      _items[existingIndex].quantity += 1;
    } else {
      // Add new item
      _items.add(CartItem(
        id: product['id'],
        name: product['name'],
        price: product['price'].toDouble(),
        image: product['image'],
        category: product['category'] ?? 'Unknown',
      ));
    }
    notifyListeners();
  }

  // Remove item from cart
  void removeItem(String id) {
    _items.removeWhere((item) => item.id == id);
    notifyListeners();
  }

  // Update item quantity
  void updateQuantity(String id, int quantity) {
    final index = _items.indexWhere((item) => item.id == id);
    if (index >= 0) {
      if (quantity > 0) {
        _items[index].quantity = quantity;
      } else {
        _items.removeAt(index);
      }
      notifyListeners();
    }
  }

  // Increase quantity
  void increaseQuantity(String id) {
    final index = _items.indexWhere((item) => item.id == id);
    if (index >= 0) {
      _items[index].quantity += 1;
      notifyListeners();
    }
  }

  // Decrease quantity
  void decreaseQuantity(String id) {
    final index = _items.indexWhere((item) => item.id == id);
    if (index >= 0) {
      if (_items[index].quantity > 1) {
        _items[index].quantity -= 1;
      } else {
        _items.removeAt(index);
      }
      notifyListeners();
    }
  }

  // Clear cart
  void clearCart() {
    _items.clear();
    notifyListeners();
  }

  // Get item by ID
  CartItem? getItemById(String id) {
    try {
      return _items.firstWhere((item) => item.id == id);
    } catch (e) {
      return null;
    }
  }

  // Check if item exists in cart
  bool isInCart(String id) {
    return _items.any((item) => item.id == id);
  }

  // Get quantity of specific item
  int getQuantity(String id) {
    final item = getItemById(id);
    return item?.quantity ?? 0;
  }

  // Simulate checkout process
  Future<bool> checkout() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 2));
      
      // Here you would typically:
      // 1. Create order in backend
      // 2. Process payment
      // 3. Update inventory
      // 4. Send confirmation
      
      // For now, just clear the cart
      clearCart();
      
      return true;
    } catch (e) {
      // You might want to use a logger here instead of print
      // For example: logger.e('Checkout error: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load cart from local storage (if needed)
  Future<void> loadCart() async {
    // Implementation depends on your storage solution
    // For now, just simulate loading
    _isLoading = true;
    notifyListeners();
    
    await Future.delayed(const Duration(milliseconds: 500));
    
    _isLoading = false;
    notifyListeners();
  }

  // Save cart to local storage (if needed)
  Future<void> saveCart() async {
    // Implementation depends on your storage solution
    // This could use SharedPreferences, SQLite, etc.
  }
}