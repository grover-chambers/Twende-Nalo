import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../models/user.dart' as app_user;
import '../services/auth_service.dart';

enum AuthState {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
}

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  
  AuthState _state = AuthState.initial;
  app_user.User? _currentUser;
  String? _errorMessage;
  bool _isLoading = false;

  // Getters
  AuthState get state => _state;
  app_user.User? get currentUser => _currentUser;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _currentUser != null && _state == AuthState.authenticated;
  app_user.UserRole? get userRole => _currentUser?.role;

  AuthProvider() {
    _initializeAuth();
  }

  // Initialize authentication state
  void _initializeAuth() {
    firebase_auth.FirebaseAuth.instance.authStateChanges().listen((firebaseUser) {
      if (firebaseUser != null) {
        _loadCurrentUser(firebaseUser.uid);
      } else {
        _setUnauthenticated();
      }
    });
  }

  // Load current user data
  Future<void> _loadCurrentUser(String userId) async {
    try {
      _setLoading(true);
      final user = await _authService.getCurrentUser(userId);
      if (user != null) {
        _setAuthenticated(user);
      } else {
        _setUnauthenticated();
      }
    } catch (e) {
      _setError('Failed to load user data: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  // Register new user
  Future<bool> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required app_user.UserRole role,
    String? phoneNumber,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      final user = await _authService.registerWithEmailAndPassword(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
        role: role,
        phoneNumber: phoneNumber,
      );

      if (user != null) {
        _setAuthenticated(user);
        return true;
      } else {
        _setError('Registration failed');
        return false;
      }
    } on firebase_auth.FirebaseAuthException catch (e) {
      _setError(_getFirebaseErrorMessage(e.code));
      return false;
    } catch (e) {
      _setError('Registration failed: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Sign in with email and password
  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      final user = await _authService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (user != null) {
        _setAuthenticated(user);
        return true;
      } else {
        _setError('Sign in failed');
        return false;
      }
    } on firebase_auth.FirebaseAuthException catch (e) {
      _setError(_getFirebaseErrorMessage(e.code));
      return false;
    } catch (e) {
      _setError('Sign in failed: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      _setLoading(true);
      await _authService.signOut();
      _setUnauthenticated();
    } catch (e) {
      _setError('Sign out failed: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  // Reset password
  Future<bool> resetPassword(String email) async {
    try {
      _setLoading(true);
      _clearError();
      
      await _authService.resetPassword(email);
      return true;
    } on firebase_auth.FirebaseAuthException catch (e) {
      _setError(_getFirebaseErrorMessage(e.code));
      return false;
    } catch (e) {
      _setError('Password reset failed: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Update user profile
  Future<bool> updateProfile({
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? profileImageUrl,
    String? address,
    String? city,
    double? latitude,
    double? longitude,
  }) async {
    if (_currentUser == null) return false;

    try {
      _setLoading(true);
      _clearError();

      final updatedUser = await _authService.updateUserProfile(
        userId: _currentUser!.id,
        firstName: firstName,
        lastName: lastName,
        phoneNumber: phoneNumber,
        profileImageUrl: profileImageUrl,
        address: address,
        city: city,
        latitude: latitude,
        longitude: longitude,
      );

      if (updatedUser != null) {
        _currentUser = updatedUser;
        notifyListeners();
        return true;
      } else {
        _setError('Profile update failed');
        return false;
      }
    } catch (e) {
      _setError('Profile update failed: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Change password
  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      await _authService.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      return true;
    } on firebase_auth.FirebaseAuthException catch (e) {
      _setError(_getFirebaseErrorMessage(e.code));
      return false;
    } catch (e) {
      _setError('Password change failed: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Delete account
  Future<bool> deleteAccount(String password) async {
    try {
      _setLoading(true);
      _clearError();

      await _authService.deleteAccount(password);
      _setUnauthenticated();
      return true;
    } on firebase_auth.FirebaseAuthException catch (e) {
      _setError(_getFirebaseErrorMessage(e.code));
      return false;
    } catch (e) {
      _setError('Account deletion failed: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Verify SMS code for phone authentication
  Future<bool> verifySmsCode(String verificationId, String smsCode) async {
    try {
      _setLoading(true);
      _clearError();

      final success = await _authService.verifySmsCode(verificationId, smsCode);
      
      if (success) {
        final firebaseUser = firebase_auth.FirebaseAuth.instance.currentUser;
        if (firebaseUser != null) {
          await _loadCurrentUser(firebaseUser.uid);
        }
      }
      
      return success;
    } on firebase_auth.FirebaseAuthException catch (e) {
      _setError(_getFirebaseErrorMessage(e.code));
      return false;
    } catch (e) {
      _setError('Verification failed: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Get Firebase user
  firebase_auth.User? get firebaseUser => firebase_auth.FirebaseAuth.instance.currentUser;

  // Update user availability (for riders)
  Future<bool> updateAvailability(bool isAvailable) async {
    if (_currentUser == null || _currentUser!.role != app_user.UserRole.rider) {
      return false;
    }

    try {
      _setLoading(true);
      
      final success = await _authService.updateUserAvailability(
        userId: _currentUser!.id,
        isAvailable: isAvailable,
      );

      if (success) {
        _currentUser = _currentUser!.copyWith(isAvailable: isAvailable);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _setError('Failed to update availability: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Private helper methods
  void _setAuthenticated(app_user.User user) {
    _state = AuthState.authenticated;
    _currentUser = user;
    _errorMessage = null;
    notifyListeners();
  }

  void _setUnauthenticated() {
    _state = AuthState.unauthenticated;
    _currentUser = null;
    _errorMessage = null;
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    if (loading) {
      _state = AuthState.loading;
    }
    notifyListeners();
  }

  void _setError(String error) {
    _state = AuthState.error;
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    if (_state == AuthState.error) {
      _state = _currentUser != null ? AuthState.authenticated : AuthState.unauthenticated;
    }
    notifyListeners();
  }

  // Convert Firebase error codes to user-friendly messages
  String _getFirebaseErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'user-not-found':
        return 'No user found with this email address.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'email-already-in-use':
        return 'This email address is already registered.';
      case 'weak-password':
        return 'Password is too weak. Please choose a stronger password.';
      case 'invalid-email':
        return 'Invalid email address format.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many failed attempts. Please try again later.';
      case 'network-request-failed':
        return 'Network error. Please check your internet connection.';
      case 'requires-recent-login':
        return 'Please sign in again to perform this action.';
      default:
        return 'Authentication error. Please try again.';
    }
  }
}
