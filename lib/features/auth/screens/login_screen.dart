// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:cloud_firestore/cloud_firestore.dart';

import '../providers/auth_provider.dart';
import '../../../core/navigation/router.dart' as app_router;

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isEmailLogin = true;
  bool _loading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _toggleLoginMethod() {
    setState(() {
      _isEmailLogin = !_isEmailLogin;
    });
  }

  Future<void> _loginWithEmail(AuthProvider auth) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    try {
      final success = await auth.signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      
      setState(() => _loading = false);
      if (success) {
        _navigateBasedOnRole();
      } else {
        _showError(auth.errorMessage ?? "Login failed");
      }
    } catch (e) {
      setState(() => _loading = false);
      _showError("Login failed: ${e.toString()}");
    }
  }

  Future<void> _loginWithPhone(AuthProvider auth) async {
    if (!_formKey.currentState!.validate()) return;

    final phone = _phoneController.text.trim();
    if (!phone.startsWith('+')) {
      _showError("Please include country code, e.g. +254712345678");
      return;
    }

    setState(() => _loading = true);
    try {
      // For now, we'll use Firebase Auth directly for phone auth
      final authInstance = FirebaseAuth.instance;
      await authInstance.verifyPhoneNumber(
        phoneNumber: phone,
        verificationCompleted: (credential) async {
          setState(() => _loading = false);
          await authInstance.signInWithCredential(credential);
          _navigateBasedOnRole();
        },
        verificationFailed: (error) {
          setState(() => _loading = false);
          _showError("Failed to send OTP: ${error.message}");
        },
        codeSent: (verificationId, forceResendingToken) {
          setState(() => _loading = false);
          // Navigate to a simple OTP screen or handle it differently
          _showOtpDialog(verificationId);
        },
        codeAutoRetrievalTimeout: (verificationId) {},
      );
    } catch (e) {
      setState(() => _loading = false);
      _showError("Failed to send OTP: ${e.toString()}");
    }
  }

  void _showOtpDialog(String verificationId) {
    final otpController = TextEditingController();
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Enter OTP'),
        content: TextField(
          controller: otpController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            hintText: 'Enter 6-digit OTP',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final credential = PhoneAuthProvider.credential(
                verificationId: verificationId,
                smsCode: otpController.text.trim(),
              );
              
              try {
                await FirebaseAuth.instance.signInWithCredential(credential);
                Navigator.pop(context);
                _navigateBasedOnRole();
              } catch (e) {
                Navigator.pop(context);
                _showError("Invalid OTP: ${e.toString()}");
              }
            },
            child: const Text('Verify'),
          ),
        ],
      ),
    );
  }

  Future<void> _navigateBasedOnRole() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _showError("No logged-in user found");
      return;
    }

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (doc.exists && doc.data() != null && doc.data()!.containsKey('role')) {
        final role = doc['role'].toString().toLowerCase();
        switch (role) {
          case 'customer':
            app_router.AppRouter.goToHome();
            break;
          case 'shop owner':
            app_router.AppRouter.goToHome();
            break;
          case 'rider':
            app_router.AppRouter.goToDeliveryDashboard();
            break;
          default:
            app_router.AppRouter.goToHome();
        }
      } else {
        app_router.AppRouter.goToHome();
      }
    } catch (e) {
      app_router.AppRouter.goToHome();
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Login"),
        actions: [
          TextButton(
            onPressed: () => app_router.AppRouter.goToRegister(),
            child: const Text("Register", style: TextStyle(color: Colors.white)),
          )
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                SwitchListTile(
                  title: Text(_isEmailLogin ? "Email Login" : "Phone Login"),
                  subtitle: Text(_isEmailLogin 
                    ? "Login with email and password" 
                    : "Login with phone and OTP"),
                  value: _isEmailLogin,
                  onChanged: (_) => _toggleLoginMethod(),
                ),
                const SizedBox(height: 30),
                if (_isEmailLogin) ...[
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: "Email",
                      prefixIcon: Icon(Icons.email_outlined),
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: "Password",
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility : Icons.visibility_off,
                        ),
                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                      ),
                      border: const OutlineInputBorder(),
                    ),
                    obscureText: _obscurePassword,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        app_router.AppRouter.pushNamed('forgot-password');
                      },
                      child: const Text("Forgot Password?"),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _loading ? null : () => _loginWithEmail(auth),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: _loading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text("Login", style: TextStyle(fontSize: 16)),
                    ),
                  ),
                ] else ...[
                  TextFormField(
                    controller: _phoneController,
                    decoration: const InputDecoration(
                      labelText: "Phone Number",
                      prefixIcon: Icon(Icons.phone_outlined),
                      border: OutlineInputBorder(),
                      hintText: "+254712345678",
                    ),
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your phone number';
                      }
                      if (!value.startsWith('+')) {
                        return 'Please include country code (e.g., +254712345678)';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _loading ? null : () => _loginWithPhone(auth),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: _loading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text("Send OTP", style: TextStyle(fontSize: 16)),
                    ),
                  ),
                ]
              ],
            ),
          ),
        ),
      ),
    );
  }
}
