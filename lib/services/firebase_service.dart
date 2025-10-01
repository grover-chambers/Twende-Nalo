import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

class FirebaseService {
  static FirebaseAuth? _auth;
  static FirebaseFirestore? _firestore;
  static FirebaseStorage? _storage;
  static FirebaseMessaging? _messaging;
  static FirebaseCrashlytics? _crashlytics;
  static FirebaseAnalytics? _analytics;

  // Getters
  static FirebaseAuth get auth => _auth ??= FirebaseAuth.instance;
  static FirebaseFirestore get firestore => _firestore ??= FirebaseFirestore.instance;
  static FirebaseStorage get storage => _storage ??= FirebaseStorage.instance;
  static FirebaseMessaging get messaging => _messaging ??= FirebaseMessaging.instance;
  static FirebaseCrashlytics get crashlytics => _crashlytics ??= FirebaseCrashlytics.instance;
  static FirebaseAnalytics get analytics => _analytics ??= FirebaseAnalytics.instance;

  static bool _initialized = false;

  // Initialize Firebase services
  static Future<void> initialize() async {
    if (_initialized) return;

    try {
      // Initialize Firebase
      await Firebase.initializeApp();

      // Configure Firestore settings
      await _configureFirestore();

      // Configure Firebase Messaging
      await _configureMessaging();

      // Configure Crashlytics
      await _configureCrashlytics();

      // Configure Analytics
      await _configureAnalytics();

      _initialized = true;
      if (kDebugMode) {
        print('Firebase services initialized successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error initializing Firebase services: $e');
      }
      crashlytics.recordError(e, null);
      rethrow;
    }
  }

  // Configure Firestore settings
  static Future<void> _configureFirestore() async {
    try {
      // Set cache size (100 MB)
      firestore.settings = const Settings(
        persistenceEnabled: true,
        cacheSizeBytes: 100 * 1024 * 1024,
      );

      if (kDebugMode) {
        print('Firestore configured successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error configuring Firestore: $e');
      }
      // Don't rethrow here as this might fail on web
    }
  }

  // Configure Firebase Messaging
  static Future<void> _configureMessaging() async {
    try {
      // Request notification permissions
      NotificationSettings settings = await messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      if (kDebugMode) {
        print('Messaging permission status: ${settings.authorizationStatus}');
      }

      // Configure foreground message handling
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        if (kDebugMode) {
          print('Received foreground message: ${message.messageId}');
        }
        _handleForegroundMessage(message);
      });

      // Configure background message handling
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        if (kDebugMode) {
          print('Message opened app: ${message.messageId}');
        }
        _handleMessageOpenedApp(message);
      });

      if (kDebugMode) {
        print('Firebase Messaging configured successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error configuring Firebase Messaging: $e');
      }
      crashlytics.recordError(e, null);
    }
  }

  // Configure Crashlytics
  static Future<void> _configureCrashlytics() async {
    try {
      // Enable Crashlytics collection
      await crashlytics.setCrashlyticsCollectionEnabled(true);
      
      // Set up crash reporting
      FlutterError.onError = crashlytics.recordFlutterFatalError;
      
      if (kDebugMode) {
        print('Crashlytics configured successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error configuring Crashlytics: $e');
      }
    }
  }

  // Configure Analytics
  static Future<void> _configureAnalytics() async {
    try {
      // Enable analytics collection
      await analytics.setAnalyticsCollectionEnabled(true);
      
      if (kDebugMode) {
        print('Analytics configured successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error configuring Analytics: $e');
      }
    }
  }

  // Handle foreground messages
  static void _handleForegroundMessage(RemoteMessage message) {
    // This will be handled by the NotificationService
    if (kDebugMode) {
      print('Handling foreground message: ${message.notification?.title}');
    }
  }

  // Handle messages that opened the app
  static void _handleMessageOpenedApp(RemoteMessage message) {
    // This will be handled by the NotificationService
    if (kDebugMode) {
      print('Handling message that opened app: ${message.notification?.title}');
    }
  }

  // Get FCM token
  static Future<String?> getFCMToken() async {
    try {
      return await messaging.getToken();
    } catch (e) {
      if (kDebugMode) {
        print('Error getting FCM token: $e');
      }
      crashlytics.recordError(e, null);
      return null;
    }
  }

  // Subscribe to topic
  static Future<void> subscribeToTopic(String topic) async {
    try {
      await messaging.subscribeToTopic(topic);
      if (kDebugMode) {
        print('Subscribed to topic: $topic');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error subscribing to topic $topic: $e');
      }
      crashlytics.recordError(e, null);
    }
  }

  // Unsubscribe from topic
  static Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await messaging.unsubscribeFromTopic(topic);
      if (kDebugMode) {
        print('Unsubscribed from topic: $topic');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error unsubscribing from topic $topic: $e');
      }
      crashlytics.recordError(e, null);
    }
  }

  // Log custom event to Analytics
  static Future<void> logEvent(String name, Map<String, Object>? parameters) async {
    try {
      await analytics.logEvent(
        name: name,
        parameters: parameters,
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error logging event $name: $e');
      }
    }
  }

  // Set user properties for Analytics
  static Future<void> setUserProperties({
    required String userId,
    String? userRole,
    String? city,
  }) async {
    try {
      await analytics.setUserId(id: userId);
      
      if (userRole != null) {
        await analytics.setUserProperty(name: 'user_role', value: userRole);
      }
      
      if (city != null) {
        await analytics.setUserProperty(name: 'city', value: city);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error setting user properties: $e');
      }
    }
  }

  // Log screen view
  static Future<void> logScreenView({
    required String screenName,
    String? screenClass,
  }) async {
    try {
      await analytics.logScreenView(
        screenName: screenName,
        screenClass: screenClass,
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error logging screen view: $e');
      }
    }
  }

  // Record error to Crashlytics
  static void recordError(
    dynamic exception,
    StackTrace? stackTrace, {
    String? reason,
    bool fatal = false,
  }) {
    try {
      if (fatal) {
        crashlytics.recordFlutterFatalError(
          FlutterErrorDetails(
            exception: exception,
            stack: stackTrace,
            library: 'Twende Nalo',
            context: ErrorDescription(reason ?? 'Fatal error'),
          ),
        );
      } else {
        crashlytics.recordError(
          exception,
          stackTrace,
          reason: reason,
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error recording to Crashlytics: $e');
      }
    }
  }

  // Set custom keys for Crashlytics
  static void setCrashlyticsCustomKeys(Map<String, dynamic> customKeys) {
    try {
      customKeys.forEach((key, value) {
        crashlytics.setCustomKey(key, value);
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error setting Crashlytics custom keys: $e');
      }
    }
  }

  // Upload file to Firebase Storage
  static Future<String?> uploadFile({
    required String filePath,
    required String fileName,
    required String folder,
  }) async {
    try {
      final ref = storage.ref().child('$folder/$fileName');
      final uploadTask = ref.putFile(File(filePath));
      final snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      if (kDebugMode) {
        print('Error uploading file: $e');
      }
      recordError(e, null, reason: 'File upload failed');
      return null;
    }
  }

  // Upload data to Firebase Storage
  static Future<String?> uploadData({
    required List<int> data,
    required String fileName,
    required String folder,
    String? contentType,
  }) async {
    try {
      final ref = storage.ref().child('$folder/$fileName');
      final metadata = SettableMetadata(
        contentType: contentType,
      );
      final uploadTask = ref.putData(Uint8List.fromList(data), metadata);
      final snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      if (kDebugMode) {
        print('Error uploading data: $e');
      }
      recordError(e, null, reason: 'Data upload failed');
      return null;
    }
  }

  // Delete file from Firebase Storage
  static Future<bool> deleteFile(String downloadUrl) async {
    try {
      final ref = storage.refFromURL(downloadUrl);
      await ref.delete();
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting file: $e');
      }
      recordError(e, null, reason: 'File deletion failed');
      return false;
    }
  }

  // Batch write operations
  static WriteBatch batch() => firestore.batch();

  // Transaction operations
  static Future<T> runTransaction<T>(
    TransactionHandler<T> updateFunction, {
    Duration timeout = const Duration(seconds: 30),
  }) {
    return firestore.runTransaction(updateFunction, timeout: timeout);
  }

  // Check network connectivity
  static Future<bool> checkConnectivity() async {
    try {
      await firestore.enableNetwork();
      return true;
    } catch (e) {
      return false;
    }
  }

  // Enable/Disable network
  static Future<void> enableNetwork() async {
    try {
      await firestore.enableNetwork();
    } catch (e) {
      if (kDebugMode) {
        print('Error enabling network: $e');
      }
    }
  }

  static Future<void> disableNetwork() async {
    try {
      await firestore.disableNetwork();
    } catch (e) {
      if (kDebugMode) {
        print('Error disabling network: $e');
      }
    }
  }

  // Clear persistence cache
  static Future<void> clearPersistence() async {
    try {
      await firestore.clearPersistence();
    } catch (e) {
      if (kDebugMode) {
        print('Error clearing persistence: $e');
      }
    }
  }

  // Dispose resources
  static Future<void> dispose() async {
    try {
      await firestore.terminate();
      _initialized = false;
    } catch (e) {
      if (kDebugMode) {
        print('Error disposing Firebase services: $e');
      }
    }
  }
}

// Required imports that need to be added to pubspec.yaml
/*
dependencies:
  firebase_core: ^2.15.0
  firebase_auth: ^4.7.2
  firebase_firestore: ^4.8.4
  firebase_storage: ^11.2.5
  firebase_messaging: ^14.6.6
  firebase_crashlytics: ^3.3.4
  firebase_analytics: ^10.4.4
*/
