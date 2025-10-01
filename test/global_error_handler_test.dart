import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:twende_nalo/core/error_handling/global_error_handler.dart';

void main() {
  group('GlobalErrorHandler Tests', () {
    test('initialize() method exists and is callable', () {
      expect(() => GlobalErrorHandler.initialize(), returnsNormally);
    });

    test('showErrorDialog method exists and is callable', () {
      expect(() => GlobalErrorHandler.showErrorDialog, returnsNormally);
    });

    test('showSuccessDialog method exists and is callable', () {
      expect(() => GlobalErrorHandler.showSuccessDialog, returnsNormally);
    });

    testWidgets('showErrorDialog displays correct dialog', (WidgetTester tester) async {
      final testMessage = 'Test error message';
      
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (BuildContext context) {
              return ElevatedButton(
                onPressed: () => GlobalErrorHandler.showErrorDialog(context, testMessage),
                child: Text('Show Error'),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Show Error'));
      await tester.pump();

      expect(find.text('Error'), findsOneWidget);
      expect(find.text(testMessage), findsOneWidget);
      expect(find.text('OK'), findsOneWidget);
    });

    testWidgets('showSuccessDialog displays correct dialog', (WidgetTester tester) async {
      final testMessage = 'Test success message';
      
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (BuildContext context) {
              return ElevatedButton(
                onPressed: () => GlobalErrorHandler.showSuccessDialog(context, testMessage),
                child: Text('Show Success'),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Show Success'));
      await tester.pump();

      expect(find.text('Success'), findsOneWidget);
      expect(find.text(testMessage), findsOneWidget);
      expect(find.text('OK'), findsOneWidget);
    });
  });
}
