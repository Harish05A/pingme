import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pingme/widgets/empty_state_widget.dart';

void main() {
  group('EmptyStateWidget Tests', () {
    testWidgets('Should display icon, title, and message', (tester) async {
      const testTitle = 'No Data';
      const testMessage = 'There is no data to display';

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyStateWidget(
              icon: Icons.inbox,
              title: testTitle,
              message: testMessage,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.inbox), findsOneWidget);
      expect(find.text(testTitle), findsOneWidget);
      expect(find.text(testMessage), findsOneWidget);
    });

    testWidgets('Should display action button when provided', (tester) async {
      bool actionCalled = false;
      const actionLabel = 'Add Item';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyStateWidget(
              icon: Icons.inbox,
              title: 'No Data',
              message: 'Add your first item',
              onAction: () => actionCalled = true,
              actionLabel: actionLabel,
            ),
          ),
        ),
      );

      expect(find.text(actionLabel), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);

      await tester.tap(find.byType(ElevatedButton));
      expect(actionCalled, true);
    });

    testWidgets('Should not display action button when not provided',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyStateWidget(
              icon: Icons.inbox,
              title: 'No Data',
              message: 'No data available',
            ),
          ),
        ),
      );

      expect(find.byType(ElevatedButton), findsNothing);
    });

    testWidgets('Should use custom icon color when provided', (tester) async {
      const customColor = Colors.blue;

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyStateWidget(
              icon: Icons.inbox,
              title: 'No Data',
              message: 'No data available',
              iconColor: customColor,
            ),
          ),
        ),
      );

      final icon = tester.widget<Icon>(find.byIcon(Icons.inbox));
      expect(icon.color, customColor);
    });
  });
}
