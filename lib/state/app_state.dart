import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/loyalty_data.dart';
import '../models/app_notification.dart';
import '../models/cart_line.dart';
import '../models/order.dart';
import '../models/order_mode.dart';

export '../models/order_mode.dart';

const _storageKey = 'app_state_v1';

/// Simple app-wide state shared across screens via [AppStateScope].
///
/// Persisted locally with `shared_preferences` — this is a single-device,
/// single-session store. There is no server behind it yet, so this data
/// never syncs across devices and isn't a substitute for real accounts.
/// That arrives once auth (Firebase) and a backend are wired in.
class AppState extends ChangeNotifier {
  String firstName = '';
  String email = '';
  String phone = '';
  bool isGuest = false;
  int points = 0;

  String? favoriteRestaurantName;
  OrderMode? lastOrderMode;

  bool emailOptIn = false;
  bool smsOptIn = false;

  List<CartLine> cart = [];
  List<Order> orderHistory = [];
  List<AppNotification> notifications = [];

  SharedPreferences? _prefs;

  bool get isLoggedIn => firstName.isNotEmpty && !isGuest;

  int get unreadNotificationCount => notifications.where((n) => !n.read).length;

  double get cartTotal => cart.fold(0.0, (sum, l) => sum + l.lineTotal);
  int get cartItemCount => cart.fold(0, (sum, l) => sum + l.quantity);

  /// Loads any previously saved session. Call once, before the app decides
  /// which screen to open on.
  Future<void> load() async {
    _prefs = await SharedPreferences.getInstance();
    final raw = _prefs!.getString(_storageKey);
    if (raw == null) return;
    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      firstName = json['firstName'] as String? ?? '';
      email = json['email'] as String? ?? '';
      phone = json['phone'] as String? ?? '';
      isGuest = json['isGuest'] as bool? ?? false;
      points = json['points'] as int? ?? 0;
      favoriteRestaurantName = json['favoriteRestaurantName'] as String?;
      final modeName = json['lastOrderMode'] as String?;
      lastOrderMode = modeName == null
          ? null
          : OrderMode.values.byName(modeName);
      emailOptIn = json['emailOptIn'] as bool? ?? false;
      smsOptIn = json['smsOptIn'] as bool? ?? false;
      cart = (json['cart'] as List<dynamic>? ?? [])
          .map((l) => CartLine.fromJson(l as Map<String, dynamic>))
          .toList();
      orderHistory = (json['orderHistory'] as List<dynamic>? ?? [])
          .map((o) => Order.fromJson(o as Map<String, dynamic>))
          .toList();
      notifications = (json['notifications'] as List<dynamic>? ?? [])
          .map((n) => AppNotification.fromJson(n as Map<String, dynamic>))
          .toList();
    } catch (_) {
      // Corrupted or outdated local data — start clean rather than crash.
    }
    notifyListeners();
  }

  void _persist() {
    final json = {
      'firstName': firstName,
      'email': email,
      'phone': phone,
      'isGuest': isGuest,
      'points': points,
      'favoriteRestaurantName': favoriteRestaurantName,
      'lastOrderMode': lastOrderMode?.name,
      'emailOptIn': emailOptIn,
      'smsOptIn': smsOptIn,
      'cart': cart.map((l) => l.toJson()).toList(),
      'orderHistory': orderHistory.map((o) => o.toJson()).toList(),
      'notifications': notifications.map((n) => n.toJson()).toList(),
    };
    _prefs?.setString(_storageKey, jsonEncode(json));
  }

  void loginAs(String name, {int points = 128, String email = ''}) {
    firstName = name;
    isGuest = false;
    this.points = points;
    if (email.isNotEmpty) this.email = email;
    _persist();
    notifyListeners();
  }

  void continueAsGuest() {
    firstName = 'Invité';
    isGuest = true;
    points = 0;
    _persist();
    notifyListeners();
  }

  void updateProfile({String? firstName, String? email, String? phone}) {
    if (firstName != null) this.firstName = firstName;
    if (email != null) this.email = email;
    if (phone != null) this.phone = phone;
    _persist();
    notifyListeners();
  }

  void setFavoriteRestaurant(String name) {
    favoriteRestaurantName = name;
    _persist();
    notifyListeners();
  }

  void setOptIns({required bool email, required bool sms}) {
    emailOptIn = email;
    smsOptIn = sms;
    _persist();
    notifyListeners();
  }

  void setOrderMode(OrderMode mode) {
    lastOrderMode = mode;
    _persist();
    notifyListeners();
  }

  // --- Cart -----------------------------------------------------------

  void addToCart(CartLine line) {
    final existing = cart.where((l) => l.id == line.id).toList();
    if (existing.isNotEmpty) {
      existing.first.quantity += line.quantity;
    } else {
      cart.add(line);
    }
    _persist();
    notifyListeners();
  }

  void updateCartQuantity(String lineId, int quantity) {
    if (quantity <= 0) {
      cart.removeWhere((l) => l.id == lineId);
    } else {
      final line = cart.where((l) => l.id == lineId).toList();
      if (line.isNotEmpty) line.first.quantity = quantity;
    }
    _persist();
    notifyListeners();
  }

  void removeFromCart(String lineId) {
    cart.removeWhere((l) => l.id == lineId);
    _persist();
    notifyListeners();
  }

  void clearCart() {
    cart = [];
    _persist();
    notifyListeners();
  }

  // --- Orders -----------------------------------------------------------

  /// Places the current cart as an order. There is no payment processor
  /// wired in yet, so this only records the order locally — the confirmation
  /// screen is explicit that payment happens in store.
  Order placeOrder({
    required OrderMode mode,
    String? restaurantName,
    String? fulfillmentDetail,
  }) {
    final total = cartTotal;
    // Guests aren't attached to a loyalty account, so no points accrue.
    final earned = isGuest ? 0 : total.floor();
    final order = Order(
      id: DateTime.now().millisecondsSinceEpoch.toRadixString(36).toUpperCase(),
      date: DateTime.now(),
      mode: mode,
      lines: List.of(cart),
      total: total,
      pointsEarned: earned,
      restaurantName: restaurantName,
      fulfillmentDetail: fulfillmentDetail,
    );

    orderHistory.insert(0, order);
    points += earned;
    lastOrderMode = mode;
    cart = [];
    _addNotification(
      'Commande #${order.id} confirmée',
      'Merci ! Réglez-la sur place à la récupération.'
          '${earned > 0 ? ' Vous gagnerez $earned points fidélité.' : ''}',
    );
    _persist();
    notifyListeners();
    return order;
  }

  // --- Fidélité -----------------------------------------------------------

  /// Attempts to redeem [tier]. Returns false without side effects if the
  /// user doesn't have enough points.
  bool redeemReward(RewardTier tier) {
    if (points < tier.points) return false;
    points -= tier.points;
    _addNotification(
      'Récompense échangée',
      '« ${tier.label} » — présentez cet écran en caisse.',
    );
    _persist();
    notifyListeners();
    return true;
  }

  // --- Notifications -----------------------------------------------------------

  void _addNotification(String title, String message) {
    notifications.insert(
      0,
      AppNotification(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        title: title,
        message: message,
        date: DateTime.now(),
      ),
    );
  }

  void markAllNotificationsRead() {
    if (notifications.every((n) => n.read)) return;
    for (final n in notifications) {
      n.read = true;
    }
    _persist();
    notifyListeners();
  }

  void logout() {
    firstName = '';
    isGuest = false;
    points = 0;
    email = '';
    phone = '';
    favoriteRestaurantName = null;
    lastOrderMode = null;
    emailOptIn = false;
    smsOptIn = false;
    cart = [];
    orderHistory = [];
    notifications = [];
    _persist();
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
