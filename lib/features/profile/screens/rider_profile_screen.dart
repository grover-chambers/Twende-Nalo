import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/user_provider.dart';
import 'package:twende_nalo/features/delivery/screens/rider_tracking_screen.dart';

class RiderProfileScreen extends StatefulWidget {
  final String userId;

  const RiderProfileScreen({
    super.key,
    required this.userId,
  });

  @override
  State<RiderProfileScreen> createState() => _RiderProfileScreenState();
}

class _RiderProfileScreenState extends State<RiderProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _vehicleTypeController = TextEditingController();
  final _licenseNumberController = TextEditingController();
  bool _saving = false;
  String? _errorMessage;

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() {
      _saving = true;
      _errorMessage = null;
    });

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      await userProvider.updateUserProfile(
        vehicleType: _vehicleTypeController.text.trim(),
        licenseNumber: _licenseNumberController.text.trim(),
      );

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => RiderTrackingScreen(
          userId: widget.userId,
          riderName: _vehicleTypeController.text.trim(),
        )),
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
      appBar: AppBar(title: const Text('Rider Profile')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Text("Complete your Rider Profile", style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 16),
              TextFormField(
                controller: _vehicleTypeController,
                decoration: const InputDecoration(labelText: 'Vehicle Type (e.g., Motorbike, Van)'),
                validator: (val) => val == null || val.isEmpty ? 'Enter vehicle type' : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _licenseNumberController,
                decoration: const InputDecoration(labelText: 'License Plate Number'),
                validator: (val) => val == null || val.isEmpty ? 'Enter license plate number' : null,
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
