import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../models/user.dart' as app_user;
import '../../../core/navigation/router.dart' as app_router;

class RoleSelectionScreen extends StatefulWidget {
  final String email;
  final String name;
  final String phone;

  const RoleSelectionScreen({
    super.key,
    required this.email,
    required this.name,
    required this.phone,
  });

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  String? _selectedRole;
  bool _isLoading = false;

  void _saveRoleAndContinue() async {
    if (_selectedRole == null) {
      _showError("Please select a role");
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    setState(() => _isLoading = true);

    // Map role selection to UserRole enum
    app_user.UserRole selectedUserRole;
    switch (_selectedRole) {
      case 'customer':
        selectedUserRole = app_user.UserRole.customer;
        break;
      case 'shop_owner':
        selectedUserRole = app_user.UserRole.shopOwner;
        break;
      case 'rider':
        selectedUserRole = app_user.UserRole.rider;
        break;
      default:
        selectedUserRole = app_user.UserRole.customer;
    }

    // Update profile with phone number and navigate
    final success = await authProvider.updateProfile(
      firstName: widget.name.split(' ')[0],
      lastName: widget.name.split(' ').length > 1 ? widget.name.split(' ')[1] : '',
      phoneNumber: widget.phone,
    );

    if (!success) {
      _showError(authProvider.errorMessage ?? "Failed to save profile");
    }

    // Navigate based on selected role
    _redirectToDashboard(selectedUserRole);

    setState(() => _isLoading = false);
  }

  void _redirectToDashboard(app_user.UserRole role) {
    switch (role) {
      case app_user.UserRole.customer:
        app_router.AppRouter.goToHome();
        break;
      case app_user.UserRole.shopOwner:
        app_router.AppRouter.goToHome();
        break;
      case app_user.UserRole.rider:
        app_router.AppRouter.goToDeliveryDashboard();
        break;
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Select Your Role"),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Choose how you'll use Twende Nalo",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              "This will help us personalize your experience",
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 30),

            // Customer option
            Card(
              elevation: 2,
              margin: const EdgeInsets.only(bottom: 12),
              child: RadioListTile<String>(
                title: const Text(
                  "Customer",
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: const Text("Browse and order from local shops"),
                value: "customer",
                groupValue: _selectedRole,
                onChanged: (value) => setState(() => _selectedRole = value),
              ),
            ),

            // Shop Owner option
            Card(
              elevation: 2,
              margin: const EdgeInsets.only(bottom: 12),
              child: RadioListTile<String>(
                title: const Text(
                  "Shop Owner",
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: const Text("Manage your shop and receive orders"),
                value: "shop_owner",
                groupValue: _selectedRole,
                onChanged: (value) => setState(() => _selectedRole = value),
              ),
            ),

            // Rider option
            Card(
              elevation: 2,
              margin: const EdgeInsets.only(bottom: 20),
              child: RadioListTile<String>(
                title: const Text(
                  "Rider",
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: const Text("Deliver orders and earn money"),
                value: "rider",
                groupValue: _selectedRole,
                onChanged: (value) => setState(() => _selectedRole = value),
              ),
            ),

            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveRoleAndContinue,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        "Continue",
                        style: TextStyle(fontSize: 16),
                      ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
