import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';

import 'package:health_fitness_app/main.dart';

void main() {
  testWidgets('App builds without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
