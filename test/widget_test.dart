// اختبار أساسي للتأكد من إقلاع تطبيق نور القلوب.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:nour_alqoloob/main.dart';

void main() {
  testWidgets('App launches and shows bottom navigation', (tester) async {
    await tester.pumpWidget(const NourAlQoloobApp());
    await tester.pump();

    expect(find.text('الأذكار'), findsWidgets);
    expect(find.byType(NavigationBar), findsOneWidget);
  });
}
