import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pingme/widgets/loading_widget.dart';

void main() {
  group('LoadingWidget Tests', () {
    testWidgets('Should display CircularProgressIndicator', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LoadingWidget(),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('Should display message when provided', (tester) async {
      const testMessage = 'Loading data...';

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LoadingWidget(message: testMessage),
          ),
        ),
      );

      expect(find.text(testMessage), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('Should not display message when not provided', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LoadingWidget(),
          ),
        ),
      );

      expect(find.byType(Text), findsNothing);
    });

    testWidgets('Should use custom color when provided', (tester) async {
      const customColor = Colors.red;

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LoadingWidget(color: customColor),
          ),
        ),
      );

      final progressIndicator = tester.widget<CircularProgressIndicator>(
        find.byType(CircularProgressIndicator),
      );

      expect(progressIndicator.valueColor, isNotNull);
    });
  });
}
