import 'package:flutter/material.dart';

enum OrderMode { clickCollect, delivery, tableService }

extension OrderModeInfo on OrderMode {
  String get label => switch (this) {
        OrderMode.clickCollect => 'Click & Collect',
        OrderMode.delivery => 'Livraison',
        OrderMode.tableService => 'Service à table',
      };

  String get description => switch (this) {
        OrderMode.clickCollect => 'Commandez et récupérez en boutique à l\'heure choisie',
        OrderMode.delivery => 'Faites-vous livrer directement chez vous',
        OrderMode.tableService => 'Scannez le QR code de votre table pour commander',
      };

  IconData get icon => switch (this) {
        OrderMode.clickCollect => Icons.storefront_outlined,
        OrderMode.delivery => Icons.delivery_dining_outlined,
        OrderMode.tableService => Icons.table_bar_outlined,
      };
}

/// Simple app-wide state shared across screens via [AppStateScope].
class AppState extends ChangeNotifier {
  String firstName = '';
  bool isGuest = false;
  int points = 0;

  String? favoriteRestaurantName;
  OrderMode? lastOrderMode;

  bool emailOptIn = false;
  bool smsOptIn = false;

  bool get isLoggedIn => firstName.isNotEmpty && !isGuest;

  void loginAs(String name, {int points = 128}) {
    firstName = name;
    isGuest = false;
    this.points = points;
    notifyListeners();
  }

  void continueAsGuest() {
    firstName = 'Invité';
    isGuest = true;
    points = 0;
    notifyListeners();
  }

  void setFavoriteRestaurant(String name) {
    favoriteRestaurantName = name;
    notifyListeners();
  }

  void setOptIns({required bool email, required bool sms}) {
    emailOptIn = email;
    smsOptIn = sms;
    notifyListeners();
  }

  void setOrderMode(OrderMode mode) {
    lastOrderMode = mode;
    notifyListeners();
  }

  void logout() {
    firstName = '';
    isGuest = false;
    points = 0;
    favoriteRestaurantName = null;
    lastOrderMode = null;
    emailOptIn = false;
    smsOptIn = false;
    notifyListeners();
  }
}

/// Exposes a single [AppState] instance to the widget tree.
class AppStateScope extends InheritedNotifier<AppState> {
  const AppStateScope({super.key, required AppState state, required super.child})
      : super(notifier: state);

  static AppState of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppStateScope>();
    assert(scope != null, 'No AppStateScope found in context');
    return scope!.notifier!;
  }
}
