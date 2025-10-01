// ignore_for_file: unused_import

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../navigation/router.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      // Show splash screen for minimum duration
      await Future.delayed(const Duration(seconds: 2));

      if (!mounted) return;

      final authProvider = context.read<AuthProvider>();

      // Wait for auth state to be determined with timeout
      const maxWaitTime = Duration(seconds: 10);
      final startTime = DateTime.now();

      while (authProvider.isLoading && mounted) {
        await Future.delayed(const Duration(milliseconds: 100));

        // Check for timeout
        if (DateTime.now().difference(startTime) > maxWaitTime) {
          debugPrint('Auth loading timeout, proceeding to login');
          break;
        }
      }

      if (!mounted) return;

      // Navigate based on authentication status
      if (authProvider.isAuthenticated && !authProvider.isLoading) {
        // Navigate to home (shop list)
        if (mounted) {
          context.goNamed('home');
        }
      } else {
        // Navigate to login
        if (mounted) {
          context.goNamed('login');
        }
      }
    } catch (e) {
      // Handle any errors during initialization
      debugPrint('Error during splash screen initialization: $e');

      if (mounted) {
        // Navigate to login as fallback
        context.goNamed('login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Use actual app logo instead of FlutterLogo
            Image.asset(
              'assets/images/logo.png',
              height: 120,
              width: 120,
              errorBuilder: (context, error, stackTrace) {
                return const FlutterLogo(size: 100);
              },
            ),
            const SizedBox(height: 30),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              strokeWidth: 3,
            ),
            const SizedBox(height: 20),
            Text(
              'Twende Nalo',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Your trusted delivery partner',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
