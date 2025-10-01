import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../models/user.dart' as app_user;
import '../../../core/navigation/router.dart' as app_router;
// For phone verification

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();

  bool _isPhoneRegister = false;
  bool _isLoading = false;

  void _handleRegister() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    if (_nameController.text.trim().isEmpty) {
      _showError("Please enter your full name");
      return;
    }

    if (_emailController.text.trim().isEmpty) {
      _showError("Please enter your email");
      return;
    }

    if (!_emailController.text.contains('@')) {
      _showError("Please enter a valid email address");
      return;
    }

    if (_isPhoneRegister) {
      if (_phoneController.text.trim().isEmpty) {
        _showError("Please enter your phone number");
        return;
      }
      if (_phoneController.text.length < 10) {
        _showError("Please enter a valid phone number");
        return;
      }
    } else {
      if (_passwordController.text.trim().isEmpty) {
        _showError("Please enter your password");
        return;
      }
      if (_passwordController.text.length < 6) {
        _showError("Password must be at least 6 characters");
        return;
      }
    }

    setState(() => _isLoading = true);

    try {
      if (_isPhoneRegister) {
        // Phone registration flow would need to be implemented based on your auth service
        _showError("Phone registration not yet implemented");
      } else {
        final success = await authProvider.register(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
          firstName: _nameController.text.trim(),
          lastName: _nameController.text.trim(),
          role: app_user.UserRole.customer,
          phoneNumber: _phoneController.text.trim(),
        );

        if (success && mounted) {
          app_router.AppRouter.pushNamed(
            'role-selection',
            extra: {
              'email': _emailController.text.trim(),
              'name': _nameController.text.trim(),
              'phone': _phoneController.text.trim(),
            },
          );
        } else if (mounted) {
          _showError(authProvider.errorMessage ?? "Registration failed");
        }
      }
    } catch (e) {
      if (mounted) {
        _showError("An error occurred during registration");
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Register")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            SwitchListTile(
              title: const Text("Register with phone"),
              value: _isPhoneRegister,
              onChanged: (val) {
                setState(() => _isPhoneRegister = val);
              },
            ),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: "Full Name",
                prefixIcon: Icon(Icons.person),
              ),
              textInputAction: TextInputAction.next,
            ),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: "Email",
                prefixIcon: Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
            ),
            if (_isPhoneRegister) ...[
              TextField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: "Phone Number",
                  prefixIcon: Icon(Icons.phone),
                  hintText: "+254712345678",
                ),
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.done,
              ),
            ] else ...[
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: "Password",
                  prefixIcon: Icon(Icons.lock),
                ),
                obscureText: true,
                textInputAction: TextInputAction.done,
              ),
            ],
            const SizedBox(height: 20),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: _handleRegister,
                    child: const Text("Register"),
                  ),
            TextButton(
              onPressed: () {
                app_router.AppRouter.goToLogin();
              },
              child: const Text(
                "Already have an account? Login",
                style: TextStyle(color: Colors.blue),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
