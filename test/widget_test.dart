import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:familyos/main.dart';

void main() {
  testWidgets('FamilyOS smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const FamilyOSApp());
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
