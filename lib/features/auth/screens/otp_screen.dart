// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class OTPScreen extends StatefulWidget {
  final String verificationId;
  final String email;
  final String name;

  const OTPScreen({
    super.key,
    required this.verificationId,
    required this.email,
    required this.name,
  });

  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  final _otpController = TextEditingController();
  bool _isLoading = false;

  void _verifyOTP() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    if (_otpController.text.length < 6) {
      _showError("Enter a valid 6-digit code");
      return;
    }

    setState(() => _isLoading = true);

    final success = await authProvider.verifySmsCode(
      widget.verificationId,
      _otpController.text,
    );

    if (success && authProvider.firebaseUser != null) {
      // Save basic profile info to Firestore (without role yet)
      await authProvider.updateProfile(
        firstName: widget.name.split(' ').first,
        lastName: widget.name.split(' ').length > 1 ? widget.name.split(' ').last : '',
        phoneNumber: authProvider.firebaseUser!.phoneNumber ?? '',
      );

      // Navigate to role selection
      Navigator.pushReplacementNamed(
        context,
        '/role-selection',
        arguments: {
          'email': widget.email,
          'name': widget.name,
          'phone': authProvider.firebaseUser!.phoneNumber ?? '',
        },
      );
    } else {
      _showError(authProvider.errorMessage ?? "Failed to verify OTP");
    }

    setState(() => _isLoading = false);
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Verify OTP")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text("Enter the OTP sent to your phone"),
            const SizedBox(height: 20),
            TextField(
              controller: _otpController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "OTP Code",
                border: OutlineInputBorder(),
              ),
              maxLength: 6,
            ),
            const SizedBox(height: 20),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _verifyOTP,
                    child: const Text("Verify & Continue"),
                  ),
          ],
        ),
      ),
    );
  }
}
