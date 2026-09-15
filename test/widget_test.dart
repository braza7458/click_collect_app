import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:click_collect_app/main.dart';

void main() {
  setUp(() {
    // AppState persists to shared_preferences on every change — the test
    // environment has no real platform storage, so mock it empty.
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Welcome screen shows the restaurant name and entry points', (WidgetTester tester) async {
    await tester.pumpWidget(const ClickCollectApp());
    await tester.pumpAndSettle();

    expect(find.textContaining('Les Poulets de Mamie'), findsOneWidget);
    expect(find.text('Connexion / Inscription'), findsOneWidget);
    expect(find.text('Continuer en tant qu\'invité'), findsOneWidget);
  });

  testWidgets('Guest can reach the menu and add an item to the cart', (WidgetTester tester) async {
    await tester.pumpWidget(const ClickCollectApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Continuer en tant qu\'invité'));
    await tester.pumpAndSettle();

    final bottomNav = find.byType(NavigationBar);
    await tester.tap(find.descendant(of: bottomNav, matching: find.text('Commander')));
    await tester.pumpAndSettle();

    expect(find.text('Le Poulet Rôti'), findsOneWidget);

    await tester.tap(find.text('Le Poulet Rôti'));
    await tester.pumpAndSettle();
    await tester.tap(find.textContaining('Ajouter ·'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Voir le panier'), findsOneWidget);
  });
}
