import 'package:flutter_test/flutter_test.dart';
import 'package:pingme/utils/error_handler.dart';
import 'package:firebase_core/firebase_core.dart';

void main() {
  group('ErrorHandler Tests', () {
    group('Firebase Error Messages', () {
      test('Permission denied error', () {
        final error = FirebaseException(
          plugin: 'test',
          code: 'permission-denied',
        );
        expect(
          ErrorHandler.getErrorMessage(error),
          contains('permission'),
        );
      });

      test('Not found error', () {
        final error = FirebaseException(
          plugin: 'test',
          code: 'not-found',
        );
        expect(
          ErrorHandler.getErrorMessage(error),
          contains('not found'),
        );
      });

      test('Unauthenticated error', () {
        final error = FirebaseException(
          plugin: 'test',
          code: 'unauthenticated',
        );
        expect(
          ErrorHandler.getErrorMessage(error),
          contains('sign in'),
        );
      });

      test('Unknown error code', () {
        final error = FirebaseException(
          plugin: 'test',
          code: 'unknown-error',
        );
        expect(
          ErrorHandler.getErrorMessage(error),
          contains('unknown-error'),
        );
      });
    });

    group('Generic Error Messages', () {
      test('Exception error', () {
        final error = Exception('Test error');
        expect(
          ErrorHandler.getErrorMessage(error),
          contains('Test error'),
        );
      });

      test('Unknown error type', () {
        final error = 'String error';
        expect(
          ErrorHandler.getErrorMessage(error),
          contains('unexpected error'),
        );
      });
    });
  });
}
