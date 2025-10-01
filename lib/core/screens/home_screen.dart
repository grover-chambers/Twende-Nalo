import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  final String userId;

  const HomeScreen({super.key, required this.userId});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  final List<String> deals = [
    "Buy 1 Get 1 Free!",
    "10% off on all electronics",
    "Fresh veggies discount"
  ];
  final List<String> bestRiders = [
    "John K.",
    "Mary N.",
    "Sam T."
  ];
  final List<String> shops = [
    "Mkuu Electronics",
    "Fresh Grocery",
    "Urban Styles"
  ];
  final List<String> categories = [
    "Electronics",
    "Groceries",
    "Fashion",
    "Books"
  ];
  final List<String> cart = [];

  void addItemToCart(String item) {
    setState(() {
      cart.add(item);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$item added to cart!')),
    );
  }

  List<String> get filteredCategories {
    final query = _searchController.text.toLowerCase();
    return categories.where((category) => category.toLowerCase().contains(query)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const Key('scaffold'), // for testing if needed
      appBar: AppBar(
        title: const Text("Twende Nalo"),
      ),
      drawer: _buildDrawer(),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: TextField(
              key: const ValueKey('searchField'),
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: "Search for items...",
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {}); // Refresh the UI on search input
              },
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(8),
              children: [
                _buildDealsSection(),
                const SizedBox(height: 10),
                _buildPopularItemsSection(),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Drawer _buildDrawer() {
    return Drawer(
      child: Column(
        children: [
          const UserAccountsDrawerHeader(
            accountName: Text("Customer Name"),
            accountEmail: Text("customer@email.com"),
            currentAccountPicture: CircleAvatar(
              child: Icon(Icons.person),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.store),
            title: const Text("Browse Shops"),
            onTap: () {
              _showShopsModal();
            },
          ),
          ListTile(
            leading: const Icon(Icons.category),
            title: const Text("Browse Categories"),
            onTap: () {
              _showCategoriesModal();
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text("Settings"),
            onTap: () {
              Navigator.pushNamed(context, '/customer-profile', arguments: {'userId': widget.userId});
            },
          ),
          const Spacer(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text("Logout"),
            onTap: () {
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
    );
  }

  void _showShopsModal() {
    showModalBottomSheet(
      context: context,
      builder: (_) => ListView(
        shrinkWrap: true,
        children: shops
            .map((shop) => ListTile(
                  title: Text(shop),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ))
            .toList(),
      ),
    );
  }

  void _showCategoriesModal() {
    showModalBottomSheet(
      context: context,
      builder: (_) => ListView(
        shrinkWrap: true,
        children: categories
            .map((cat) => ListTile(
                  title: Text(cat),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ))
            .toList(),
      ),
    );
  }

  Widget _buildDealsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Today's Deals",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.orange),
        ),
        ...deals.map((deal) => ListTile(
              title: Text(deal),
              trailing: const Icon(Icons.local_offer, color: Colors.orange),
            )),
      ],
    );
  }

  Widget _buildPopularItemsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Popular Items",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.orange),
        ),
        ...filteredCategories.map((item) => ListTile(
              title: Text(item),
              trailing: IconButton(
                icon: const Icon(Icons.add_shopping_cart),
                onPressed: () => addItemToCart(item),
              ),
            )),
      ],
    );
  }

  Widget _buildBottomNavigationBar() {
    return SizedBox(
      height: 80,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        scrollDirection: Axis.horizontal,
        children: bestRiders
            .map((rider) => Container(
                  margin: const EdgeInsets.all(8),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                      color: Colors.orange.shade100,
                      borderRadius: BorderRadius.circular(8)),
                  child: Center(
                      child: Text(
                    rider,
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.orange),
                  )),
                ))
            .toList(),
      ),
    );
  }
}