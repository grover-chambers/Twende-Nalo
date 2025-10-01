import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _checkingAuth = true;

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        // Fetch user role from Firestore
        DocumentSnapshot snap = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (snap.exists) {
          String role = (snap.data() as Map<String, dynamic>)['role'] ?? '';

          if (role == 'customer') {
            Navigator.pushReplacementNamed(context, '/customer-dashboard');
            return;
          } else if (role == 'shop_owner') {
            Navigator.pushReplacementNamed(context, '/shop-owner-dashboard');
            return;
          } else if (role == 'rider') {
            Navigator.pushReplacementNamed(context, '/rider-dashboard');
            return;
          }
        }

        // No role → go to role selection
        Navigator.pushReplacementNamed(context, '/role-selection');
      } else {
        setState(() => _checkingAuth = false); // Show login/register
      }
    } catch (e) {
      debugPrint("Auth check error: $e");
      setState(() => _checkingAuth = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_checkingAuth) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const FlutterLogo(size: 100),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/login');
                },
                child: const Text("Login"),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/register');
                },
                child: const Text("Register"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
