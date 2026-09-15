import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:click_collect_app/main.dart';

void main() {
  testWidgets('Welcome screen shows the restaurant name and entry points', (WidgetTester tester) async {
    await tester.pumpWidget(const ClickCollectApp());

    expect(find.textContaining('Les Poulets de Mamie'), findsOneWidget);
    expect(find.text('Connexion / Inscription'), findsOneWidget);
    expect(find.text('Continuer en tant qu\'invité'), findsOneWidget);
  });

  testWidgets('Guest can reach the menu from the dashboard', (WidgetTester tester) async {
    await tester.pumpWidget(const ClickCollectApp());

    await tester.tap(find.text('Continuer en tant qu\'invité'));
    await tester.pumpAndSettle();

    final bottomNav = find.byType(NavigationBar);
    await tester.tap(find.descendant(of: bottomNav, matching: find.text('Commander')));
    await tester.pumpAndSettle();

    expect(find.text('Le Poulet Rôti'), findsOneWidget);
  });
}
