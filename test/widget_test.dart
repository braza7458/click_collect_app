import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:click_collect_app/data/loyalty_data.dart';
import 'package:click_collect_app/data/menu_data.dart';
import 'package:click_collect_app/data/restaurant_data.dart';
import 'package:click_collect_app/main.dart';
import 'package:click_collect_app/state/app_state.dart';

/// The menu, restaurants and reward tiers now live in Firestore, which isn't
/// reachable from a widget test — inject a small fixture instead of hitting
/// the network. `loadCatalog()` fails silently offline and keeps this
/// untouched. Auth is a [MockFirebaseAuth] for the same reason: the real
/// `FirebaseAuth.instance` needs an initialized Firebase app that doesn't
/// exist in this environment. Calls that reach real Firestore afterwards
/// (profile/points/orders) fail offline and fall back to local-only state,
/// exactly like they would on a phone with no signal.
AppState _testAppState() => AppState(auth: MockFirebaseAuth())
  ..menuCategories = const [
    MenuCategory(
      title: 'Poulets rôtis',
      items: [MenuItem(name: 'Le Poulet Rôti', price: 20.50)],
    ),
  ]
  ..restaurants = const [
    RestaurantLocation(name: 'Les Poulets de Mamie — Centre Ville', address: '12 Rue de la République', hours: '11h30 - 21h30'),
  ]
  ..rewardTiers = const [
    RewardTier(points: 100, label: 'Un dessert offert', iconKey: 'dessert'),
  ];

void main() {
  setUp(() {
    // AppState persists to shared_preferences on every change — the test
    // environment has no real platform storage, so mock it empty.
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Welcome screen shows the restaurant name and entry points', (WidgetTester tester) async {
    await tester.pumpWidget(ClickCollectApp(appState: _testAppState()));
    await tester.pumpAndSettle();

    expect(find.textContaining('Les Poulets de Mamie'), findsOneWidget);
    expect(find.text('Connexion / Inscription'), findsOneWidget);
    expect(find.text('Continuer en tant qu\'invité'), findsOneWidget);
  });

  testWidgets('Guest can reach the menu and add an item to the cart', (WidgetTester tester) async {
    await tester.pumpWidget(ClickCollectApp(appState: _testAppState()));
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

  testWidgets('Paying by card fails gracefully when the payment call can\'t reach Firebase', (WidgetTester tester) async {
    // Tall enough that the cart screen's checkout buttons are fully built by
    // the sliver's cache extent, instead of fighting scroll-dependent widget
    // inflation.
    await tester.binding.setSurfaceSize(const Size(800, 1400));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(ClickCollectApp(appState: _testAppState()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Continuer en tant qu\'invité'));
    await tester.pumpAndSettle();
    await tester.tap(find.descendant(of: find.byType(NavigationBar), matching: find.text('Commander')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Le Poulet Rôti'));
    await tester.pumpAndSettle();
    await tester.tap(find.textContaining('Ajouter ·'));
    await tester.pumpAndSettle();
    // The "ajouté au panier" snackbar's exit animation pauses once its route
    // is covered by later screens, so it can keep absorbing taps near the
    // bottom of the screen indefinitely unless cleared explicitly here.
    ScaffoldMessenger.of(tester.element(find.byIcon(Icons.shopping_bag_outlined))).clearSnackBars();
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.shopping_bag_outlined));
    await tester.pumpAndSettle();

    // Table service needs the least setup to reach a submittable cart.
    await tester.tap(find.text('Service à table'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).at(0), '12'); // table number
    await tester.enterText(find.byType(TextField).at(1), '0612345678'); // SMS phone
    await tester.pumpAndSettle();

    // This first button just navigates to the Stripe screen — it doesn't pay.
    await tester.tap(find.text('Payer 20,50 € par carte'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Payer 20,50 €'));
    await tester.pumpAndSettle();

    // The Cloud Function is real now, but this test environment has no
    // initialized Firebase app to reach it through — that must degrade
    // gracefully (the generic catch-all in stripe_checkout_screen.dart)
    // instead of crashing. The message includes the actual exception so a
    // real failure is diagnosable from the snackbar alone.
    expect(find.textContaining('Le paiement a échoué'), findsOneWidget);
  });

  testWidgets('Guest can place an in-store order and reach the confirmation screen', (WidgetTester tester) async {
    // Tall enough that the cart screen's content — summary card and both
    // checkout buttons included — is fully built by the sliver's cache
    // extent, instead of fighting scroll-dependent widget inflation.
    await tester.binding.setSurfaceSize(const Size(800, 1400));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(ClickCollectApp(appState: _testAppState()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Continuer en tant qu\'invité'));
    await tester.pumpAndSettle();
    await tester.tap(find.descendant(of: find.byType(NavigationBar), matching: find.text('Commander')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Le Poulet Rôti'));
    await tester.pumpAndSettle();
    await tester.tap(find.textContaining('Ajouter ·'));
    await tester.pumpAndSettle();
    ScaffoldMessenger.of(tester.element(find.byIcon(Icons.shopping_bag_outlined))).clearSnackBars();
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.shopping_bag_outlined));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Service à table'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).at(0), '5'); // table number
    await tester.enterText(find.byType(TextField).at(1), '0612345678'); // SMS phone
    await tester.pumpAndSettle();

    // placeOrder() now writes to Firestore first (and falls back to local
    // state offline, as here) — this exercises that whole async path end to
    // end instead of just the synchronous version it used to be.
    await tester.tap(find.text('Commander — payer sur place'));
    await tester.pumpAndSettle();

    expect(find.text('Commande confirmée'), findsOneWidget);
  });

  testWidgets('Signing up only asks for a pseudo and a password', (WidgetTester tester) async {
    await tester.pumpWidget(ClickCollectApp(appState: _testAppState()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Connexion / Inscription'));
    await tester.pumpAndSettle();
    // The link is a raw RichText combining two spans ("Pas encore de
    // compte ? " + "Créer un compte") — match a substring of the flattened
    // text rather than the (non-matching) exact full string.
    await tester.tap(find.textContaining('Créer un compte', findRichText: true));
    await tester.pumpAndSettle();

    // No e-mail or phone field anywhere in the signup flow.
    expect(find.byType(TextField), findsNWidgets(2));
    expect(find.text('Pseudo'), findsOneWidget);

    await tester.enterText(find.byType(TextField).at(0), 'ChickenFan');
    await tester.enterText(find.byType(TextField).at(1), 'Cocotte1');
    await tester.pumpAndSettle();

    await tester.tap(find.text('Continuer'));
    await tester.pumpAndSettle();

    await tester.tap(find.textContaining('J\'accepte les Conditions', findRichText: true));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Je valide mon inscription'));
    await tester.pumpAndSettle();

    expect(find.text('Mon restaurant favori'), findsOneWidget);
  });
}
