import 'package:flutter/material.dart';

class ShopOwnerDashboard extends StatelessWidget {
  const ShopOwnerDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shop Owner Dashboard'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Shop Management',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: [
                  Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    child: ListTile(
                      title: const Text('Products'),
                      subtitle: const Text('Manage your products'),
                      trailing: ElevatedButton(
                        onPressed: () {
                          // Navigate to products management
                        },
                        child: const Text('Manage'),
                      ),
                    ),
                  ),
                  Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    child: ListTile(
                      title: const Text('Orders'),
                      subtitle: const Text('View and manage orders'),
                      trailing: ElevatedButton(
                        onPressed: () {
                          // Navigate to orders management
                        },
                        child: const Text('View'),
                      ),
                    ),
                  ),
                  Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    child: ListTile(
                      title: const Text('Analytics'),
                      subtitle: const Text('View shop analytics'),
                      trailing: ElevatedButton(
                        onPressed: () {
                          // Navigate to analytics
                        },
                        child: const Text('View'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () {
                // Implement logout functionality
              },
              child: const Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}
