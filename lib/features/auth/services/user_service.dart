// ignore_for_file: unused_field

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Create user profile if new user
  Future<void> createUserProfileIfNew(
    User user,
    String role,
    String name,
  ) async {
    final userDoc = _firestore.collection('users').doc(user.uid);

    final docSnapshot = await userDoc.get();

    if (!docSnapshot.exists) {
      final referralCode = 'TN${Uuid().v4().substring(0, 6).toUpperCase()}';

      await userDoc.set({
        'phone': user.phoneNumber ?? '',
        'email': user.email ?? '',
        'role': role,
        'name': name,
        'referralCode': referralCode,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
  }

  /// Get user profile data
  Future<Map<String, dynamic>?> getUserProfile(String uid) async {
    final userDoc = _firestore.collection('users').doc(uid);
    final docSnapshot = await userDoc.get();
    
    if (docSnapshot.exists) {
      return docSnapshot.data();
    }
    return null;
  }

  /// Update user profile
  Future<void> updateUserProfile({
    required String uid,
    required String name,
    required String role,
    String? phoneNumber,
  }) async {
    final userDoc = _firestore.collection('users').doc(uid);
    
    await userDoc.update({
      'name': name,
      'role': role,
      if (phoneNumber != null) 'phone': phoneNumber,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Check if user exists
  Future<bool> userExists(String uid) async {
    final userDoc = _firestore.collection('users').doc(uid);
    final docSnapshot = await userDoc.get();
    return docSnapshot.exists;
  }
}
