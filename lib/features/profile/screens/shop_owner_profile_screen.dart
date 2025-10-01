import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:twende_nalo/features/shop/screens/shop_owner_screen.dart';

class ShopOwnerProfileScreen extends StatefulWidget {
  final String userId;

  const ShopOwnerProfileScreen({
    super.key,
    required this.userId,
  });

  @override
  State<ShopOwnerProfileScreen> createState() => _ShopOwnerProfileScreenState();
}

class _ShopOwnerProfileScreenState extends State<ShopOwnerProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _shopNameController = TextEditingController();
  final _locationController = TextEditingController();
  bool _saving = false;
  String? _errorMessage;

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _saving = true;
      _errorMessage = null;
    });

    try {
      await FirebaseFirestore.instance.collection("users").doc(widget.userId).update({
        'role': 'shop_owner',
        'shopName': _shopNameController.text.trim(),
        'location': _locationController.text.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => ShopOwnerScreen(userId: widget.userId)),
      );

    } catch (e) {
      setState(() {
        _errorMessage = 'Profile save failed: ${e.toString()}';
      });
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Shop Owner Profile')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Text("Complete your Shop Profile", style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 16),
              TextFormField(
                controller: _shopNameController,
                decoration: const InputDecoration(labelText: 'Shop Name'),
                validator: (val) => val == null || val.isEmpty ? 'Enter shop name' : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(labelText: 'Shop Location (e.g., CBD, Westlands)'),
                validator: (val) => val == null || val.isEmpty ? 'Enter location' : null,
              ),
              const SizedBox(height: 16),
              if (_errorMessage != null)
                Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: _saving ? null : _saveProfile,
                child: _saving ? const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(Colors.white)) : const Text('Save & Continue'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
