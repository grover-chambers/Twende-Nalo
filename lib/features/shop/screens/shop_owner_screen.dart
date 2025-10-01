import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import '../models/shop.dart';
import '../models/product.dart';
import '../providers/shop_provider.dart';
import 'add_item_screen.dart';

class ShopOwnerScreen extends StatefulWidget {
  final String userId;

  const ShopOwnerScreen({super.key, required this.userId});

  @override
  State<ShopOwnerScreen> createState() => _ShopOwnerScreenState();
}

class _ShopOwnerScreenState extends State<ShopOwnerScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Shop> _shops = [];
  List<Product> _products = [];
  bool _isLoading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _loadOwnerData();
  }

  Future<void> _loadOwnerData() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      // Load shops owned by this user
      final shopsSnapshot = await _firestore
          .collection('shops')
          .where('ownerId', isEqualTo: widget.userId)
          .get();

      _shops = shopsSnapshot.docs.map((doc) => Shop.fromFirestore(doc)).toList();

      // Load products for the first shop if available
      if (_shops.isNotEmpty) {
        await _loadProducts(_shops.first.id);
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = 'Failed to load data: $e';
      });
    }
  }

  Future<void> _loadProducts(String shopId) async {
    try {
      final productsSnapshot = await _firestore
          .collection('products')
          .where('shopId', isEqualTo: shopId)
          .get();

      _products = productsSnapshot.docs
          .map((doc) => Product.fromMap(doc.data(), doc.id))
          .toList();

      setState(() {});
    } catch (e) {
      setState(() {
        _error = 'Failed to load products: $e';
      });
    }
  }

  Future<void> _addNewShop() async {
    // Navigate to shop creation screen or show dialog
    // This would be implemented based on your navigation structure
    FirebaseCrashlytics.instance.recordError('Navigate to shop creation screen', null);
  }

  void _navigateToAddItem(String shopId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddItemScreen(),
      ),
    );
  }

  void _viewShopDetails(Shop shop) {
    // Navigate to shop details screen
    FirebaseCrashlytics.instance.recordError('Navigate to shop details: ${shop.id}', null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shop Owner Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadOwnerData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error.isNotEmpty
              ? Center(child: Text('Error: $_error'))
              : _buildDashboard(),
      floatingActionButton: _shops.isNotEmpty
          ? FloatingActionButton(
              onPressed: () => _navigateToAddItem(_shops.first.id),
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Widget _buildDashboard() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildShopSection(),
          const SizedBox(height: 24),
          _buildProductsSection(),
          const SizedBox(height: 24),
          _buildQuickActions(),
        ],
      ),
    );
  }

  Widget _buildShopSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'My Shops',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        _shops.isEmpty
            ? _buildEmptyState(
                icon: Icons.store,
                message: 'No shops yet',
                actionText: 'Add Your First Shop',
                onAction: _addNewShop,
              )
            : Column(
                children: _shops.map((shop) => _buildShopCard(shop)).toList(),
              ),
      ],
    );
  }

  Widget _buildShopCard(Shop shop) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: const Icon(Icons.store, size: 40),
        title: Text(shop.name),
        subtitle: Text('${shop.category} • ${shop.city}'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => _viewShopDetails(shop),
      ),
    );
  }

  Widget _buildProductsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Products',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        _products.isEmpty
            ? _buildEmptyState(
                icon: Icons.inventory,
                message: 'No products yet',
                actionText: 'Add Your First Product',
                onAction: () => _navigateToAddItem(_shops.first.id),
              )
            : Column(
                children:
                    _products.map((product) => _buildProductCard(product)).toList(),
              ),
      ],
    );
  }

  Widget _buildProductCard(Product product) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: product.imageUrls.isNotEmpty
            ? Image.network(product.imageUrls.first, width: 40, height: 40)
            : const Icon(Icons.shopping_bag, size: 40),
        title: Text(product.name),
        subtitle: Text('KES ${product.finalPrice.toStringAsFixed(2)}'),
        trailing: Chip(
          label: Text(
            product.statusString.toUpperCase(),
            style: const TextStyle(fontSize: 12),
          ),
          backgroundColor: product.status == ProductStatus.active
              ? Colors.green[100]
              : Colors.grey[300],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        GridView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 2,
          ),
          children: [
            _buildActionCard(
              icon: Icons.add,
              title: 'Add Product',
              onTap: _shops.isNotEmpty
                  ? () => _navigateToAddItem(_shops.first.id)
                  : null,
            ),
            _buildActionCard(
              icon: Icons.store,
              title: 'Add Shop',
              onTap: _addNewShop,
            ),
            _buildActionCard(
              icon: Icons.analytics,
              title: 'View Analytics',
              onTap: _shops.isNotEmpty ? () {} : null,
            ),
            _buildActionCard(
              icon: Icons.settings,
              title: 'Settings',
              onTap: () {},
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    VoidCallback? onTap,
  }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 24),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String message,
    required String actionText,
    required VoidCallback onAction,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, size: 48, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onAction,
            child: Text(actionText),
          ),
        ],
      ),
    );
  }
}
