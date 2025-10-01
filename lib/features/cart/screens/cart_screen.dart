import 'package:flutter/material.dart';

/// Model class representing an item in the cart.
class CartItem {
  final String id;
  final String name;
  final int quantity;
  final double price;
  final String image;

  CartItem({
    required this.id,
    required this.name,
    this.quantity = 1,
    required this.price,
    required this.image,
  });

  /// Returns a copy of this CartItem with updated quantity.
  CartItem copyWith({int? quantity}) {
    return CartItem(
      id: id,
      name: name,
      quantity: quantity ?? this.quantity,
      price: price,
      image: image,
    );
  }
}

/// Screen displaying the user's shopping cart.
class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  bool _isLoading = true;
  List<CartItem> _cartItems = [];

  @override
  void initState() {
    super.initState();
    _fetchCartItems();
  }

  /// Simulates fetching cart items from a background service or API.
  Future<void> _fetchCartItems() async {
    await Future.delayed(const Duration(seconds: 2)); // Simulate network delay
    setState(() {
      _cartItems = [
        CartItem(
          id: '1',
          name: 'Ladies Dress',
          quantity: 1,
          price: 1500,
          image: 'assets/images/dress.jpg',
        ),
        CartItem(
          id: '3',
          name: 'Apples (1kg)',
          quantity: 2,
          price: 200,
          image: 'assets/images/apples.jpg',
        ),
      ];
      _isLoading = false;
    });
  }

  /// Calculates the total price of all items in the cart.
  double get _totalPrice {
    return _cartItems.fold(0, (sum, item) => sum + (item.price * item.quantity));
  }

  /// Removes an item from the cart by its ID.
  void _removeItem(String id) {
    setState(() {
      _cartItems.removeWhere((item) => item.id == id);
    });
  }

  /// Changes the quantity of a cart item by delta (positive or negative).
  void _changeQuantity(String id, int delta) {
    setState(() {
      final index = _cartItems.indexWhere((item) => item.id == id);
      if (index != -1) {
        final currentItem = _cartItems[index];
        final newQuantity = currentItem.quantity + delta;
        if (newQuantity > 0) {
          _cartItems[index] = currentItem.copyWith(quantity: newQuantity);
        }
      }
    });
  }

  /// Handles checkout action.
  void _proceedToCheckout() {
    // TODO: Integrate with backend or payment gateway here.
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Processing checkout...')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Cart'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _cartItems.isEmpty
              ? const Center(
                  child: Text(
                    'Your cart is empty.',
                    style: TextStyle(fontSize: 18),
                  ),
                )
              : Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: _cartItems.length,
                        itemBuilder: (context, index) {
                          final item = _cartItems[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            child: ListTile(
                              leading: Image.asset(
                                item.image,
                                width: 50,
                                fit: BoxFit.cover,
                              ),
                              title: Text(item.name),
                              subtitle: Text(
                                'KES ${item.price.toStringAsFixed(2)} x ${item.quantity}',
                                style: const TextStyle(fontSize: 16),
                              ),
                              trailing: SizedBox(
                                width: 130,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.remove_circle_outline),
                                      onPressed: () => _changeQuantity(item.id, -1),
                                    ),
                                    Text('${item.quantity}'),
                                    IconButton(
                                      icon: const Icon(Icons.add_circle_outline),
                                      onPressed: () => _changeQuantity(item.id, 1),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.red),
                                      onPressed: () => _removeItem(item.id),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(16),
                      // ignore: deprecated_member_use
                      color: Colors.orange.withOpacity(0.1),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Total: KES ${_totalPrice.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange,
                            ),
                          ),
                          const SizedBox(height: 10),
                          ElevatedButton(
                            onPressed: _proceedToCheckout,
                            child: const Text('Checkout with M-Pesa'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }
}
