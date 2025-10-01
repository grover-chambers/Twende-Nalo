import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../provider/user_provider.dart';

class CustomerProfileScreen extends StatefulWidget {
  final String userId;

  const CustomerProfileScreen({
    super.key,
    required this.userId,
  });

  @override
  State<CustomerProfileScreen> createState() => _CustomerProfileScreenState();
}

class _CustomerProfileScreenState extends State<CustomerProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _addressController = TextEditingController();
  bool _saving = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Load the current user's address
    _loadUserAddress();
  }

  Future<void> _loadUserAddress() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    await userProvider.loadCurrentUser();
    if (userProvider.currentUser != null) {
      _addressController.text = userProvider.currentUser!['address'] ?? '';
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _saving = true;
      _errorMessage = null; // Reset error message
    });

    try {
      // Update the address directly using Firestore
      await FirebaseFirestore.instance.collection("users").doc(widget.userId).update({
        'address': _addressController.text.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      Navigator.pop(context); // Go back to previous screen

    } catch (e) {
      _setError('Profile save failed: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  void _setError(String message) {
    if (!mounted) return;
    setState(() {
      _errorMessage = message;
    });
  }

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Customer Profile')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Text("Update your Profile", style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 16),
              TextFormField(
                key: const ValueKey('addressField'),
                controller: _addressController,
                decoration: const InputDecoration(labelText: 'Delivery Address'),
                validator: (val) => val == null || val.isEmpty ? 'Enter your delivery address' : null,
              ),
              const SizedBox(height: 16),
              if (_errorMessage != null)
                Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 8),
              ElevatedButton(
                key: const ValueKey('saveButton'),
                onPressed: _saving ? null : _saveProfile,
                child: _saving 
                    ? const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(Colors.white)) 
                    : const Text('Save Profile'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
