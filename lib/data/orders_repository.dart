import 'package:cloud_firestore/cloud_firestore.dart' hide Order;

import '../models/order.dart';

/// Reads and writes the shared `orders` collection — the same collection
/// the kiosk writes to, so every order placed anywhere ends up in one
/// place. Each order's `date` is stored as an ISO-8601 string (sortable as
/// plain text) rather than a Firestore [Timestamp], simply so [Order]'s
/// existing [Order.toJson]/[Order.fromJson] can be reused as-is.
///
/// SMS design note: neither this app nor the kiosk calls an SMS API
/// directly. Once a provider is chosen, a Firestore-triggered Cloud
/// Function is the right place for both messages — `onCreate` on this
/// collection sends the "confirmée" SMS to `customerPhone` (covering the
/// app and the kiosk identically, since they write to the same
/// collection), and `onUpdate` watching for a `status` change to "ready"
/// sends the "prête" one. That second part also needs a staff surface that
/// can flip an order to "ready" in the first place — not built yet.
class OrdersRepository {
  const OrdersRepository._();

  static Future<void> submitOrder(Order order) =>
      FirebaseFirestore.instance.collection('orders').doc(order.id).set(order.toJson());

  static Future<List<Order>> fetchOrdersForUser(String uid) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('orders')
        .where('userId', isEqualTo: uid)
        .orderBy('date', descending: true)
        .get();
    return snapshot.docs.map((doc) => Order.fromJson(doc.data())).toList();
  }
}
