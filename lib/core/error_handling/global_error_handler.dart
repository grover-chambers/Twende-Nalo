import 'package:flutter/material.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'dart:ui' show PlatformDispatcher;
import 'failure.dart';

class GlobalErrorHandler {
  static void initialize() {
    print("Initializing Global Error Handler..."); // Debug statement
    // Initialize Firebase Crashlytics for Flutter errors
    FlutterError.onError = (FlutterErrorDetails details) {
      FirebaseCrashlytics.instance.recordFlutterError(details);
    };

    // Handle platform errors (non-Flutter errors)
    PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
  }

  /// Show error dialog with user-friendly message
  static void showErrorDialog(BuildContext context, String message, {String? title}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(title ?? 'Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  /// Show success dialog
  static void showSuccessDialog(BuildContext context, String message, {String? title}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(title ?? 'Success'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  /// Show error SnackBar
  static void showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Show success SnackBar
  static void showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// Handle failure with appropriate UI feedback
  static void handleFailure(BuildContext context, Failure failure, {bool showSnackBar = false}) {
    final message = FailureMapper.getUserFriendlyMessage(failure);
    
    if (showSnackBar) {
      showErrorSnackBar(context, message);
    } else {
      showErrorDialog(context, message);
    }
    
    // Log to Crashlytics
    FirebaseCrashlytics.instance.recordError(
      failure,
      StackTrace.current,
      reason: failure.message,
    );
  }

  /// Handle error with retry option
  static void showErrorWithRetry(
    BuildContext context,
    String message,
    VoidCallback onRetry, {
    String? title,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(title ?? 'Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onRetry();
            },
            child: const Text('Retry'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  /// Show loading dialog
  static void showLoadingDialog(BuildContext context, {String? message}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Row(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: 20),
            Text(message ?? 'Loading...'),
          ],
        ),
      ),
    );
  }

  /// Hide loading dialog
  static void hideLoadingDialog(BuildContext context) {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }

  /// Safe async operation wrapper
  static Future<T?> safeAsync<T>(
    BuildContext context,
    Future<T> Function() operation, {
    String? loadingMessage,
    bool showSnackBarOnError = false,
    bool showDialogOnError = true,
  }) async {
    try {
      if (loadingMessage != null) {
        showLoadingDialog(context, message: loadingMessage);
      }
      
      final result = await operation();
      
      if (loadingMessage != null) {
        hideLoadingDialog(context);
      }
      
      return result;
    } on Exception catch (e) {
      if (loadingMessage != null) {
        hideLoadingDialog(context);
      }
      
      final failure = FailureMapper.fromException(e);
      
      if (showDialogOnError) {
        handleFailure(context, failure, showSnackBar: showSnackBarOnError);
      } else if (showSnackBarOnError) {
        showErrorSnackBar(context, FailureMapper.getUserFriendlyMessage(failure));
      }
      
      return null;
    } catch (e) {
      if (loadingMessage != null) {
        hideLoadingDialog(context);
      }
      
      final failure = FailureMapper.fromError(e);
      
      if (showDialogOnError) {
        handleFailure(context, failure, showSnackBar: showSnackBarOnError);
      } else if (showSnackBarOnError) {
        showErrorSnackBar(context, FailureMapper.getUserFriendlyMessage(failure));
      }
      
      return null;
    }
  }
}
