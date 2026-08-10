// اختبار أساسي للتأكد من إقلاع تطبيق نور القلوب وبناء شريط التنقّل.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:nour_alqoloob/main.dart';

void main() {
  testWidgets('App launches and shows bottom navigation', (tester) async {
    await tester.pumpWidget(const NourAlQoloobApp());
    // Avoid pumpAndSettle: the loading spinner animates indefinitely.
    await tester.pump();

    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.byType(NavigationDestination), findsNWidgets(4));
  });
}
