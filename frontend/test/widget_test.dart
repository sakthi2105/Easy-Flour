// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:frontend/main.dart';
import 'package:frontend/providers/auth_provider.dart';
import 'package:frontend/routes/app_router.dart';

void main() {
  testWidgets('App should build successfully', (WidgetTester tester) async {
    final authProvider = AuthProvider();

    // Build our app and trigger a frame.
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: authProvider),
        ],
        child: NammaMaavuApp(appRouter: createRouter(authProvider)),
      ),
    );

    // Verify that the app builds.
    expect(find.byType(NammaMaavuApp), findsOneWidget);
  });
}
