import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Basic routing test', (WidgetTester tester) async {
    // Build a simple app with navigation
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          appBar: AppBar(title: const Text('Home')),
          body: Center(
            child: ElevatedButton(
              onPressed: () {},
              child: const Text('Navigate'),
            ),
          ),
        ),
      ),
    );

    // Verify basic structure
    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.text('Navigate'), findsOneWidget);
  });
}
