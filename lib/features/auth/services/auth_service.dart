import 'dart:math' as math;
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/user.dart';
import '../../../core/constants/app_constants.dart';

class AuthService {
  final firebase_auth.FirebaseAuth _firebaseAuth = firebase_auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  firebase_auth.User? get currentFirebaseUser => _firebaseAuth.currentUser;

  // Get current user data from Firestore
  Future<User?> getCurrentUser(String userId) async {
    try {
      final doc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .get();

      if (doc.exists && doc.data() != null) {
        return User.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get current user: $e');
    }
  }

  // Register with email and password
  Future<User?> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required UserRole role,
    String? phoneNumber,
  }) async {
    try {
      // Create user with Firebase Auth
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        throw Exception('Failed to create user account');
      }

      // Create user document in Firestore
      final user = User(
        id: credential.user!.uid,
        email: email,
        firstName: firstName,
        lastName: lastName,
        phoneNumber: phoneNumber,
        role: role,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(user.id)
          .set(user.toMap());

      // Update Firebase Auth display name
      await credential.user!.updateDisplayName(user.fullName);

      return user;
    } catch (e) {
      // Clean up if user creation failed
      if (_firebaseAuth.currentUser != null) {
        await _firebaseAuth.currentUser!.delete();
      }
      rethrow;
    }
  }

  // Sign in with email and password
  Future<User?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        throw Exception('Failed to sign in');
      }

      return await getCurrentUser(credential.user!.uid);
    } catch (e) {
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
    } catch (e) {
      throw Exception('Failed to sign out: $e');
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } catch (e) {
      rethrow;
    }
  }

  // Update user profile
  Future<User?> updateUserProfile({
    required String userId,
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? profileImageUrl,
    String? address,
    String? city,
    double? latitude,
    double? longitude,
  }) async {
    try {
      final updates = <String, dynamic>{
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      };

      if (firstName != null) updates['firstName'] = firstName;
      if (lastName != null) updates['lastName'] = lastName;
      if (phoneNumber != null) updates['phoneNumber'] = phoneNumber;
      if (profileImageUrl != null) updates['profileImageUrl'] = profileImageUrl;
      if (address != null) updates['address'] = address;
      if (city != null) updates['city'] = city;
      if (latitude != null) updates['latitude'] = latitude;
      if (longitude != null) updates['longitude'] = longitude;

      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .update(updates);

      // Update Firebase Auth display name if name changed
      if (firstName != null || lastName != null) {
        final currentUser = await getCurrentUser(userId);
        if (currentUser != null && _firebaseAuth.currentUser != null) {
          await _firebaseAuth.currentUser!.updateDisplayName(currentUser.fullName);
        }
      }

      return await getCurrentUser(userId);
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }

  // Change password
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null || user.email == null) {
        throw Exception('No authenticated user');
      }

      // Re-authenticate user
      final credential = firebase_auth.EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(credential);

      // Update password
      await user.updatePassword(newPassword);
    } catch (e) {
      rethrow;
    }
  }

  // Delete account
  Future<void> deleteAccount(String password) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null || user.email == null) {
        throw Exception('No authenticated user');
      }

      // Re-authenticate user
      final credential = firebase_auth.EmailAuthProvider.credential(
        email: user.email!,
        password: password,
      );
      await user.reauthenticateWithCredential(credential);

      // Delete user data from Firestore
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(user.uid)
          .delete();

      // Delete Firebase Auth account
      await user.delete();
    } catch (e) {
      rethrow;
    }
  }

  // Update user availability (for riders)
  Future<bool> updateUserAvailability({
    required String userId,
    required bool isAvailable,
  }) async {
    try {
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .update({
        'isAvailable': isAvailable,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
      return true;
    } catch (e) {
      throw Exception('Failed to update availability: $e');
    }
  }

  // Update user location
  Future<bool> updateUserLocation({
    required String userId,
    required double latitude,
    required double longitude,
    String? address,
  }) async {
    try {
      final updates = {
        'latitude': latitude,
        'longitude': longitude,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      };

      if (address != null) {
        updates['address'] = address;
      }

      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .update(updates);
      return true;
    } catch (e) {
      throw Exception('Failed to update location: $e');
    }
  }

  // Update user rating
  Future<bool> updateUserRating({
    required String userId,
    required double rating,
  }) async {
    try {
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .update({
        'rating': rating,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
      return true;
    } catch (e) {
      throw Exception('Failed to update rating: $e');
    }
  }

  // Increment total deliveries (for riders)
  Future<bool> incrementTotalDeliveries(String userId) async {
    try {
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .update({
        'totalDeliveries': FieldValue.increment(1),
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
      return true;
    } catch (e) {
      throw Exception('Failed to increment total deliveries: $e');
    }
  }

  // Increment total orders (for customers)
  Future<bool> incrementTotalOrders(String userId) async {
    try {
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .update({
        'totalOrders': FieldValue.increment(1),
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
      return true;
    } catch (e) {
      throw Exception('Failed to increment total orders: $e');
    }
  }

  // Get users by role
  Future<List<User>> getUsersByRole(UserRole role) async {
    try {
      final querySnapshot = await _firestore
          .collection(AppConstants.usersCollection)
          .where('role', isEqualTo: role.toString().split('.').last)
          .where('status', isEqualTo: 'active')
          .get();

      return querySnapshot.docs
          .map((doc) => User.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get users by role: $e');
    }
  }

  // Get available riders near location
  Future<List<User>> getAvailableRiders({
    required double latitude,
    required double longitude,
    double radiusKm = 10.0,
  }) async {
    try {
      // This is a simplified version. In production, you'd want to use
      // a more sophisticated geo-query using GeoFirestore or similar
      final querySnapshot = await _firestore
          .collection(AppConstants.usersCollection)
          .where('role', isEqualTo: 'rider')
          .where('status', isEqualTo: 'active')
          .where('isAvailable', isEqualTo: true)
          .get();

      final riders = querySnapshot.docs
          .map((doc) => User.fromFirestore(doc))
          .where((rider) => rider.hasLocation)
          .toList();

      // Filter by distance (simplified calculation)
      return riders.where((rider) {
        final distance = _calculateDistance(
          latitude,
          longitude,
          rider.latitude!,
          rider.longitude!,
        );
        return distance <= radiusKm;
      }).toList();
    } catch (e) {
      throw Exception('Failed to get available riders: $e');
    }
  }

  // Calculate distance between two points (Haversine formula)
  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371; // Earth's radius in kilometers
    
    final double dLat = _degreesToRadians(lat2 - lat1);
    final double dLon = _degreesToRadians(lon2 - lon1);
    
    final double a = 
        math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(lat1) * math.cos(lat2) * 
        math.sin(dLon / 2) * math.sin(dLon / 2);
    
    final double c = 2 * math.asin(math.sqrt(a));
    
    return earthRadius * c;
  }

  double _degreesToRadians(double degrees) {
    return degrees * (math.pi / 180);
  }

  // Verify SMS code for phone authentication
  Future<bool> verifySmsCode(String verificationId, String smsCode) async {
    try {
      final credential = firebase_auth.PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );

      await _firebaseAuth.signInWithCredential(credential);
      return true;
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw Exception(_getFirebaseErrorMessage(e.code));
    } catch (e) {
      throw Exception('Failed to verify SMS code: ${e.toString()}');
    }
  }

  // Convert Firebase error codes to user-friendly messages
  String _getFirebaseErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'invalid-verification-code':
        return 'Invalid verification code. Please try again.';
      case 'invalid-verification-id':
        return 'Invalid verification ID. Please request a new code.';
      case 'session-expired':
        return 'Verification session expired. Please request a new code.';
      case 'quota-exceeded':
        return 'SMS quota exceeded. Please try again later.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'network-request-failed':
        return 'Network error. Please check your internet connection.';
      default:
        return 'Verification failed. Please try again.';
    }
  }
}
