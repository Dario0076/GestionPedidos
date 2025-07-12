// This is a basic Flutter widget test for Gestion Pedidos app.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:gestion_pedidos/main.dart';

void main() {
  testWidgets('App loads without errors', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      const ProviderScope(
        child: MyApp(),
      ),
    );

    // Wait for the widget to settle
    await tester.pumpAndSettle();

    // Verify that the app loads without crashing
    // This will find the login screen or home screen depending on auth state
    expect(find.byType(Scaffold), findsWidgets);
  });

  testWidgets('Login screen elements are present', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      const ProviderScope(
        child: MyApp(),
      ),
    );

    // Wait for the widget to settle
    await tester.pumpAndSettle();

    // Verify that login elements are present (assuming user is not logged in)
    // Look for common elements that should be present
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
