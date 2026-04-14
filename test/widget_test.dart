import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:directfast/core/services/storage_service.dart';
import 'package:directfast/main.dart';

void main() {
  testWidgets('DirectFast app starts without crashing', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    await StorageService.init();

    await tester.pumpWidget(
      const ProviderScope(
        child: DirectFastApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
