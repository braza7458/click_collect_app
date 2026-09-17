import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/catalog_repository.dart';
import '../data/loyalty_data.dart';
import '../data/menu_data.dart';
import '../data/orders_repository.dart';
import '../data/restaurant_data.dart';
import '../data/user_repository.dart';
import '../models/app_notification.dart';
import '../models/cart_line.dart';
import '../models/order.dart';
import '../models/order_mode.dart';

export '../models/order_mode.dart';

const _storageKey = 'app_state_v1';

/// The outcome of a sign-in/sign-up attempt — `errorMessage` is a
/// user-facing French message, already translated from Firebase's error
/// codes, ready to show in a form.
class AuthResult {
  const AuthResult.success() : errorMessage = null;
  const AuthResult.failure(this.errorMessage);

  final String? errorMessage;
  bool get isSuccess => errorMessage == null;
}

/// Firebase Auth only speaks e-mail/password — accounts here are meant to
/// carry neither, so a pseudo is turned into a fake, undeliverable address
/// on a domain the restaurant doesn't own the mailbox for. Firebase never
/// sends anything there; it's just used as a unique account key. This also
/// means self-service password reset (which needs a real inbox) isn't
/// possible — see the login screen.
String pseudoEmailFor(String username) {
  final normalized = username.trim().toLowerCase().replaceAll(RegExp(r'[^a-z0-9._-]'), '-');
  return '$normalized@pseudo.no-reply.invalid';
}

String _authErrorMessage(FirebaseAuthException e) {
  switch (e.code) {
    case 'user-not-found':
    case 'wrong-password':
    case 'invalid-credential':
      return 'Pseudo ou mot de passe incorrect.';
    case 'email-already-in-use':
      return 'Ce pseudo est déjà pris.';
    case 'weak-password':
      return 'Mot de passe trop faible.';
    case 'invalid-email':
      return 'Pseudo invalide — utilisez au moins 3 caractères (lettres, chiffres).';
    case 'too-many-requests':
      return 'Trop de tentatives — réessayez dans quelques minutes.';
    case 'network-request-failed':
      return 'Pas de connexion internet.';
    default:
      return e.message ?? 'Une erreur est survenue.';
  }
}

/// App-wide state shared across screens via [AppStateScope].
///
/// Accounts are deliberately minimal: a pseudo and a password, nothing
/// else. No e-mail, no phone number is ever attached to an account — a
/// choice made to keep the restaurant out of the data the law holds you
/// responsible for if it leaks. A phone number is still collected, but only
/// per order (see [placeOrder]), purely to send that order's SMS updates —
/// never stored on the account.
///
/// Identity and everything tied to an account (profile, points, order
/// history) live in Firebase Auth + Firestore, and sync across devices.
/// Only device-local conveniences — the in-progress cart, local
/// notifications, the last order mode picked — still live in
/// `shared_preferences`. Guests get a Firebase **anonymous** session (so
/// Firestore rules can still tell "someone" placed an order) but no
/// `users/{uid}` profile document — hence no points, and nothing to sync.
class AppState extends ChangeNotifier {
  AppState({FirebaseAuth? auth}) : _auth = auth ?? FirebaseAuth.instance;

  final FirebaseAuth _auth;

  String username = '';
  bool isGuest = false;
  int points = 0;

  String? favoriteRestaurantName;
  OrderMode? lastOrderMode;

  List<CartLine> cart = [];
  List<Order> orderHistory = [];
  List<AppNotification> notifications = [];

  /// The shared catalog, read from Firestore — the same menu the kiosk
  /// reads. Empty until [loadCatalog] resolves.
  List<MenuCategory> menuCategories = [];
  List<RestaurantLocation> restaurants = [];
  List<RewardTier> rewardTiers = [];

  SharedPreferences? _prefs;

  bool get isLoggedIn => username.isNotEmpty && !isGuest;
  String? get uid => _auth.currentUser?.uid;

  int get unreadNotificationCount => notifications.where((n) => !n.read).length;

  double get cartTotal => cart.fold(0.0, (sum, l) => sum + l.lineTotal);
  int get cartItemCount => cart.fold(0, (sum, l) => sum + l.quantity);

  /// The "Suppléments bowls" items, for the bowl customization sheet.
  List<MenuItem> get bowlSupplements => menuCategories
      .firstWhere(
        (c) => c.title == 'Suppléments bowls',
        orElse: () => const MenuCategory(title: '', items: []),
      )
      .items;

  Future<void> loadCatalog() async {
    try {
      final results = await Future.wait([
        CatalogRepository.fetchMenu(),
        CatalogRepository.fetchRestaurants(),
        CatalogRepository.fetchRewardTiers(),
      ]);
      menuCategories = results[0] as List<MenuCategory>;
      restaurants = results[1] as List<RestaurantLocation>;
      rewardTiers = results[2] as List<RewardTier>;
    } catch (_) {
      // Offline, or Firestore unreachable — keep whatever catalog is
      // already loaded rather than taking the app down.
    }
    notifyListeners();
  }

  /// Restores local prefs (cart, notifications…) and the signed-in session,
  /// if any — Firebase Auth keeps that persisted on its own. Call once,
  /// before the app decides which screen to open on.
  Future<void> load() async {
    _prefs = await SharedPreferences.getInstance();
    _loadLocalPrefs();

    final user = _auth.currentUser;
    if (user != null) {
      if (user.isAnonymous) {
        username = 'Invité';
        isGuest = true;
      } else {
        await _loadUserProfile(user.uid);
      }
    }
    notifyListeners();
  }

  Future<void> _loadUserProfile(String uid) async {
    try {
      final data = await UserRepository.fetchProfile(uid);
      if (data != null) {
        username = data['username'] as String? ?? '';
        points = (data['points'] as num?)?.toInt() ?? 0;
        favoriteRestaurantName = data['favoriteRestaurantName'] as String?;
      }
      orderHistory = await OrdersRepository.fetchOrdersForUser(uid);
    } catch (_) {
      // Offline — keep whatever profile we already had loaded.
    }
    isGuest = false;
    notifyListeners();
  }

  void _loadLocalPrefs() {
    final raw = _prefs!.getString(_storageKey);
    if (raw == null) return;
    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      final modeName = json['lastOrderMode'] as String?;
      lastOrderMode = modeName == null ? null : OrderMode.values.byName(modeName);
      cart = (json['cart'] as List<dynamic>? ?? [])
          .map((l) => CartLine.fromJson(l as Map<String, dynamic>))
          .toList();
      notifications = (json['notifications'] as List<dynamic>? ?? [])
          .map((n) => AppNotification.fromJson(n as Map<String, dynamic>))
          .toList();
    } catch (_) {
      // Corrupted or outdated local data — start clean rather than crash.
    }
  }

  void _persistLocal() {
    final json = {
      'lastOrderMode': lastOrderMode?.name,
      'cart': cart.map((l) => l.toJson()).toList(),
      'notifications': notifications.map((n) => n.toJson()).toList(),
    };
    _prefs?.setString(_storageKey, jsonEncode(json));
  }

  // --- Auth -----------------------------------------------------------

  Future<AuthResult> signUp({required String username, required String password}) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: pseudoEmailFor(username),
        password: password,
      );
      final newUid = credential.user!.uid;
      try {
        await UserRepository.createProfile(newUid, {
          'username': username,
          'points': 0,
          'favoriteRestaurantName': null,
        });
      } catch (_) {
        // Offline right at signup — the Auth account still exists, so let
        // the user in; the profile document will need to sync later.
      }
      this.username = username;
      points = 0;
      isGuest = false;
      favoriteRestaurantName = null;
      orderHistory = [];
      notifyListeners();
      return const AuthResult.success();
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(_authErrorMessage(e));
    }
  }

  Future<AuthResult> signIn({required String username, required String password}) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: pseudoEmailFor(username),
        password: password,
      );
      await _loadUserProfile(credential.user!.uid);
      return const AuthResult.success();
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(_authErrorMessage(e));
    }
  }

  /// Signs in anonymously so Firestore rules can still recognize "someone"
  /// placed an order, without creating a real account. If anonymous sign-in
  /// isn't enabled on the Firebase project, browsing still works — only
  /// placing an order will fail later, with a clear message.
  Future<void> continueAsGuest() async {
    // Set the visible state first — callers that don't await this still see
    // it applied immediately, and the network call is a "nice to have" that
    // only actually matters later, at placeOrder() time.
    username = 'Invité';
    isGuest = true;
    points = 0;
    notifyListeners();
    try {
      await _auth.signInAnonymously();
    } catch (_) {
      // Falls through — still usable for browsing; see placeOrder().
    }
  }

  Future<void> setFavoriteRestaurant(String name) async {
    favoriteRestaurantName = name;
    final currentUid = uid;
    if (!isGuest && currentUid != null) {
      try {
        await UserRepository.updateProfile(currentUid, {'favoriteRestaurantName': name});
      } catch (_) {}
    }
    notifyListeners();
  }

  void setOrderMode(OrderMode mode) {
    lastOrderMode = mode;
    _persistLocal();
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
    _persistLocal();
    notifyListeners();
  }

  void updateCartQuantity(String lineId, int quantity) {
    if (quantity <= 0) {
      cart.removeWhere((l) => l.id == lineId);
    } else {
      final line = cart.where((l) => l.id == lineId).toList();
      if (line.isNotEmpty) line.first.quantity = quantity;
    }
    _persistLocal();
    notifyListeners();
  }

  void removeFromCart(String lineId) {
    cart.removeWhere((l) => l.id == lineId);
    _persistLocal();
    notifyListeners();
  }

  void clearCart() {
    cart = [];
    _persistLocal();
    notifyListeners();
  }

  // --- Orders -----------------------------------------------------------

  /// Places the current cart as an order, written to the shared `orders`
  /// collection (the kiosk writes to the same one). If Firestore can't be
  /// reached, the order still completes locally rather than blocking the
  /// customer — it just won't be synced.
  ///
  /// [customerPhone] is stored on the order (see [Order.customerPhone]),
  /// never on the account. It's there for the SMS confirmation and "ready"
  /// messages — see [OrdersRepository]'s doc comment for where that sending
  /// actually happens.
  ///
  /// [reward] is a loyalty tier the customer chose to redeem for this order
  /// (only possible when logged in with enough points) — its points are
  /// deducted right here, in the same balance update as the points earned
  /// from this order's total, and its label rides along on the order so
  /// staff see it without a separate "show your app" step. It's a free
  /// add-on, never a discount: [Order.total] is unaffected.
  Future<Order> placeOrder({
    required OrderMode mode,
    required String customerPhone,
    String? restaurantName,
    String? fulfillmentDetail,
    bool paid = false,
    RewardTier? reward,
  }) async {
    final total = cartTotal;
    final currentUid = uid;
    // Guests aren't attached to a loyalty account, so no points accrue or redeem.
    final earned = isGuest ? 0 : total.floor();
    final redeemed = (!isGuest && reward != null && points >= reward.points) ? reward.points : 0;
    final appliedReward = redeemed > 0 ? reward : null;
    final order = Order(
      id: DateTime.now().millisecondsSinceEpoch.toRadixString(36).toUpperCase(),
      date: DateTime.now(),
      mode: mode,
      lines: List.of(cart),
      total: total,
      pointsEarned: earned,
      restaurantName: restaurantName,
      fulfillmentDetail: fulfillmentDetail,
      paid: paid,
      userId: currentUid,
      customerPhone: customerPhone,
      appliedRewardLabel: appliedReward?.label,
    );
    final netPoints = earned - redeemed;

    try {
      await OrdersRepository.submitOrder(order);
      if (!isGuest && currentUid != null && netPoints != 0) {
        points = await UserRepository.adjustPoints(currentUid, netPoints);
      }
    } catch (_) {
      // Offline — keep going locally so the customer isn't blocked; the
      // order just won't show up on another device.
      points += netPoints;
    }

    orderHistory.insert(0, order);
    lastOrderMode = mode;
    cart = [];
    _addNotification(
      'Commande #${order.id} confirmée',
      (paid
              ? 'Merci, votre paiement a bien été reçu !'
              : 'Merci ! Réglez-la sur place à la récupération.') +
          (appliedReward != null ? ' « ${appliedReward.label} » sera ajouté à votre commande.' : '') +
          (earned > 0 ? ' Vous gagnerez $earned points fidélité.' : ''),
    );
    _persistLocal();
    notifyListeners();
    return order;
  }

  // --- Fidélité -----------------------------------------------------------

  /// Attempts to redeem [tier]. Returns false without side effects if the
  /// user doesn't have enough points.
  Future<bool> redeemReward(RewardTier tier) async {
    if (points < tier.points) return false;
    final currentUid = uid;
    if (!isGuest && currentUid != null) {
      try {
        points = await UserRepository.adjustPoints(currentUid, -tier.points);
      } catch (_) {
        points -= tier.points;
      }
    } else {
      points -= tier.points;
    }
    _addNotification(
      'Récompense échangée',
      '« ${tier.label} » — présentez cet écran en caisse.',
    );
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
    _persistLocal();
    notifyListeners();
  }

  Future<void> logout() async {
    username = '';
    isGuest = false;
    points = 0;
    favoriteRestaurantName = null;
    lastOrderMode = null;
    cart = [];
    orderHistory = [];
    notifications = [];
    _persistLocal();
    notifyListeners();
    await _auth.signOut();
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
