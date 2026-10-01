import 'package:cloud_firestore/cloud_firestore.dart' hide Order;

import '../models/order.dart';

/// Reads and writes the shared `orders` collection — the same collection
/// the kiosk writes to, so every order placed anywhere ends up in one
/// place. Each order's `date` is stored as an ISO-8601 string (sortable as
/// plain text) rather than a Firestore [Timestamp], simply so [Order]'s
/// existing [Order.toJson]/[Order.fromJson] can be reused as-is.
///
/// SMS: neither this app nor the kiosk calls an SMS API directly — Cloud
/// Functions (functions/index.js) send the "confirmée" SMS on create and the
/// "prête" one when the reception terminal flips `status` to `ready`.
///
/// "Mes commandes" : la requête ne filtre QUE sur `userId` et le tri par date
/// se fait ici, côté client. Un `where(userId) + orderBy(date)` exigerait un
/// index composite Firestore — absent, la requête échouait silencieusement
/// et la liste restait vide.
class OrdersRepository {
  const OrdersRepository._();

  static Future<void> submitOrder(Order order) =>
      FirebaseFirestore.instance.collection('orders').doc(order.id).set(order.toJson());

  static Query<Map<String, dynamic>> _forUser(String uid) =>
      FirebaseFirestore.instance.collection('orders').where('userId', isEqualTo: uid);

  static List<Order> _parse(QuerySnapshot<Map<String, dynamic>> snapshot) {
    final orders = <Order>[];
    for (final doc in snapshot.docs) {
      try {
        orders.add(Order.fromJson(doc.data()));
      } catch (_) {
        // Un document mal formé ne doit pas vider toute la liste.
      }
    }
    orders.sort((a, b) => b.date.compareTo(a.date));
    return orders;
  }

  static Future<List<Order>> fetchOrdersForUser(String uid) async => _parse(await _forUser(uid).get());

  /// Suivi en direct : le statut (en préparation → prête → récupérée) change
  /// à l'écran dès que le terminal de réception le fait avancer.
  static Stream<List<Order>> watchOrdersForUser(String uid) => _forUser(uid).snapshots().map(_parse);
}
