import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

/// Global error handler for consistent error messaging
class ErrorHandler {
  /// Get user-friendly error message from any error
  static String getErrorMessage(dynamic error) {
    if (error is FirebaseException) {
      return _getFirebaseErrorMessage(error.code);
    } else if (error is Exception) {
      return error.toString().replaceAll('Exception: ', '');
    }
    return 'An unexpected error occurred. Please try again.';
  }

  /// Get Firebase-specific error messages
  static String _getFirebaseErrorMessage(String code) {
    switch (code) {
      case 'permission-denied':
        return 'You don\'t have permission to perform this action.';
      case 'not-found':
        return 'The requested data was not found.';
      case 'already-exists':
        return 'This data already exists.';
      case 'unauthenticated':
        return 'Please sign in to continue.';
      case 'unavailable':
        return 'Service is currently unavailable. Please try again later.';
      case 'deadline-exceeded':
        return 'Request timed out. Please check your connection.';
      case 'invalid-argument':
        return 'Invalid data provided. Please check your input.';
      default:
        return 'An error occurred: $code';
    }
  }

  /// Show error snackbar with retry option
  static void showErrorSnackBar(
    BuildContext context,
    dynamic error, {
    VoidCallback? onRetry,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(getErrorMessage(error)),
        backgroundColor: Colors.red[700],
        duration: const Duration(seconds: 4),
        action: onRetry != null
            ? SnackBarAction(
                label: 'Retry',
                textColor: Colors.white,
                onPressed: onRetry,
              )
            : SnackBarAction(
                label: 'Dismiss',
                textColor: Colors.white,
                onPressed: () {},
              ),
      ),
    );
  }

  /// Show success snackbar
  static void showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green[700],
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// Show info snackbar
  static void showInfoSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.blue[700],
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Log error for debugging (can be extended with crash reporting)
  static void logError(dynamic error, StackTrace? stackTrace) {
    // In production, send to crash reporting service
    debugPrint('ERROR: $error');
    if (stackTrace != null) {
      debugPrint('STACK TRACE: $stackTrace');
    }
  }
}
