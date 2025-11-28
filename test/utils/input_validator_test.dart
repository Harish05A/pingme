import 'package:flutter_test/flutter_test.dart';
import 'package:pingme/utils/input_validator.dart';

void main() {
  group('InputValidator Tests', () {
    group('Email Validation', () {
      test('Valid email should pass', () {
        expect(InputValidator.validateEmail('test@example.com'), null);
        expect(InputValidator.validateEmail('user.name@domain.co.uk'), null);
        expect(InputValidator.validateEmail('user+tag@example.com'), null);
      });

      test('Invalid email should fail', () {
        expect(InputValidator.validateEmail(''), isNotNull);
        expect(InputValidator.validateEmail('invalid'), isNotNull);
        expect(InputValidator.validateEmail('test@'), isNotNull);
        expect(InputValidator.validateEmail('@example.com'), isNotNull);
        expect(InputValidator.validateEmail('test @example.com'), isNotNull);
      });

      test('Null email should fail', () {
        expect(InputValidator.validateEmail(null), isNotNull);
      });
    });

    group('Password Validation', () {
      test('Valid password should pass', () {
        expect(InputValidator.validatePassword('123456'), null);
        expect(InputValidator.validatePassword('password123'), null);
        expect(InputValidator.validatePassword('VeryLongPassword123!'), null);
      });

      test('Short password should fail', () {
        expect(InputValidator.validatePassword('12345'), isNotNull);
        expect(InputValidator.validatePassword('abc'), isNotNull);
      });

      test('Empty password should fail', () {
        expect(InputValidator.validatePassword(''), isNotNull);
        expect(InputValidator.validatePassword(null), isNotNull);
      });
    });

    group('Name Validation', () {
      test('Valid name should pass', () {
        expect(InputValidator.validateName('John Doe'), null);
        expect(InputValidator.validateName('Alice'), null);
        expect(InputValidator.validateName('Mary Jane Watson'), null);
      });

      test('Invalid name should fail', () {
        expect(InputValidator.validateName(''), isNotNull);
        expect(InputValidator.validateName('A'), isNotNull);
        expect(InputValidator.validateName('John123'), isNotNull);
        expect(InputValidator.validateName('John@Doe'), isNotNull);
      });

      test('Name too long should fail', () {
        expect(
          InputValidator.validateName('A' * 51),
          isNotNull,
        );
      });
    });

    group('Duration Validation', () {
      test('Valid duration should pass', () {
        expect(InputValidator.validateDuration('1'), null);
        expect(InputValidator.validateDuration('25'), null);
        expect(InputValidator.validateDuration('90'), null);
        expect(InputValidator.validateDuration('180'), null);
      });

      test('Invalid duration should fail', () {
        expect(InputValidator.validateDuration('0'), isNotNull);
        expect(InputValidator.validateDuration('181'), isNotNull);
        expect(InputValidator.validateDuration('-5'), isNotNull);
        expect(InputValidator.validateDuration('abc'), isNotNull);
        expect(InputValidator.validateDuration(''), isNotNull);
      });
    });

    group('Sanitization', () {
      test('Should remove dangerous characters', () {
        expect(InputValidator.sanitize('<script>alert("xss")</script>'),
            'scriptalert("xss")/script');
        expect(InputValidator.sanitize('Hello <World>'), 'Hello World');
        expect(InputValidator.sanitize('  spaces  '), 'spaces');
      });

      test('Should keep safe characters', () {
        expect(InputValidator.sanitize('Hello World'), 'Hello World');
        expect(InputValidator.sanitize('test@example.com'), 'test@example.com');
      });
    });
  });
}
