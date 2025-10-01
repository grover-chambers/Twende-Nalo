import 'package:flutter/material.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_info_card.dart';
import '../widgets/profile_action_button.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  void _onEditProfile(BuildContext context) {
    // Navigate to edit profile screen (to be implemented)
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Edit Profile tapped')),
    );
  }

  void _onLogout(BuildContext context) {
    // Handle logout logic here
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Logged out')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ProfileHeader(
              userName: 'John Doe', // Replace with actual user data
              userEmail: 'johndoe@example.com', // Replace with actual user data
              userImageUrl: null, // Replace with actual user image URL
              onEditPressed: () => _onEditProfile(context),
            ),
            const SizedBox(height: 24),
            ProfileInfoCard(
              title: 'Phone Number',
              value: '+254 712 345 678', // Replace with actual user data
              icon: Icons.phone,
              onTap: () {
                // Handle phone number edit
              },
            ),
            ProfileInfoCard(
              title: 'Address',
              value: '123 Main Street, Nairobi', // Replace with actual user data
              icon: Icons.location_on,
              onTap: () {
                // Handle address edit
              },
            ),
            ProfileInfoCard(
              title: 'Role',
              value: 'Customer', // Replace with actual user data
              icon: Icons.person,
              onTap: null,
            ),
            const SizedBox(height: 24),
            ProfileActionButton(
              text: 'My Orders',
              icon: Icons.shopping_bag,
              onPressed: () {
                // Navigate to orders screen
              },
            ),
            const SizedBox(height: 12),
            ProfileActionButton(
              text: 'Settings',
              icon: Icons.settings,
              onPressed: () {
                // Navigate to settings screen
              },
            ),
            const SizedBox(height: 12),
            ProfileActionButton(
              text: 'Help & Support',
              icon: Icons.help_outline,
              onPressed: () {
                // Navigate to help screen
              },
            ),
            const SizedBox(height: 12),
            ProfileActionButton(
              text: 'Logout',
              icon: Icons.logout,
              onPressed: () => _onLogout(context),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          ],
        ),
      ),
    );
  }
}
