import 'cart_line.dart';
import 'order_mode.dart';

/// An order, written to the shared Firestore `orders` collection — the same
/// collection the kiosk writes to (with `source: 'kiosk'`), so every order
/// placed anywhere ends up in one place.
///
/// An order is created as [confirmed] and only ever moves forward
/// (confirmed → ready → completed) — see the reception terminal
/// (click_collect_terminal), which is the only place that advances it.
enum OrderStatus { confirmed, ready, completed }

extension OrderStatusInfo on OrderStatus {
  /// Libellé côté client (le terminal parle de "Nouvelle / Prête / Terminée").
  String get label => switch (this) {
        OrderStatus.confirmed => 'En préparation',
        OrderStatus.ready => 'Prête à récupérer',
        OrderStatus.completed => 'Récupérée',
      };

  /// Étape dans le suivi (0, 1, 2).
  int get step => index;
}

class Order {
  Order({
    required this.id,
    required this.date,
    required this.mode,
    required this.lines,
    required this.total,
    required this.pointsEarned,
    this.restaurantName,
    this.fulfillmentDetail,
    this.status = OrderStatus.confirmed,
    this.paid = false,
    this.userId,
    this.customerPhone,
    this.appliedRewardLabel,
    this.customerName,
    this.source = 'app',
    this.ticketNumber,
  });

  final String id;
  final DateTime date;
  final OrderMode mode;
  final List<CartLine> lines;
  final double total;
  final int pointsEarned;
  final String? restaurantName;
  final String? fulfillmentDetail;
  final OrderStatus status;

  /// Label of the loyalty reward redeemed for this order (e.g. "Un dessert
  /// offert"), if any — see [AppState.placeOrder]'s `reward` parameter.
  /// Null means no reward was applied. The reward is a free add-on, not a
  /// discount: it never changes [total].
  final String? appliedRewardLabel;

  /// Whether this order was paid online (Stripe) at checkout, as opposed to
  /// the in-store fallback where payment happens at pickup.
  final bool paid;

  /// The Firebase Auth uid of whoever placed this order — null for guests,
  /// who have no account to attach it to.
  final String? userId;

  /// Collected at checkout for this order's SMS updates only — never saved
  /// to the account (see [AppState]'s class doc).
  final String? customerPhone;

  /// Pseudo du compte fidélité — affiché sur le terminal de réception.
  final String? customerName;

  /// 'app' ou 'kiosk' (commande passée sur la borne avec son compte).
  final String source;

  /// Numéro de ticket de la borne.
  final int? ticketNumber;

  bool get isFromKiosk => source == 'kiosk';

  /// "Commande #K3F9A" ou "Ticket borne n° 12".
  String get displayTitle => isFromKiosk ? 'Ticket borne n° ${ticketNumber ?? '?'}' : 'Commande #$id';

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date.toIso8601String(),
        'mode': mode.name,
        'lines': lines.map((l) => l.toJson()).toList(),
        'total': total,
        'pointsEarned': pointsEarned,
        'restaurantName': restaurantName,
        'fulfillmentDetail': fulfillmentDetail,
        'status': status.name,
        'paid': paid,
        'userId': userId,
        'customerPhone': customerPhone,
        'appliedRewardLabel': appliedRewardLabel,
        'customerName': customerName,
        'source': source,
        if (ticketNumber != null) 'number': ticketNumber,
      };

  factory Order.fromJson(Map<String, dynamic> json) => Order(
        id: json['id'] as String,
        date: DateTime.parse(json['date'] as String),
        mode: OrderMode.values.asNameMap()[json['mode']] ?? OrderMode.clickCollect,
        lines: (json['lines'] as List<dynamic>)
            .map((l) => CartLine.fromJson(Map<String, dynamic>.from(l as Map)))
            .toList(),
        total: (json['total'] as num).toDouble(),
        pointsEarned: (json['pointsEarned'] as num?)?.toInt() ?? 0,
        restaurantName: json['restaurantName'] as String?,
        fulfillmentDetail: json['fulfillmentDetail'] as String?,
        status: OrderStatus.values.asNameMap()[json['status']] ?? OrderStatus.confirmed,
        paid: json['paid'] as bool? ?? false,
        userId: json['userId'] as String?,
        customerPhone: json['customerPhone'] as String?,
        appliedRewardLabel: json['appliedRewardLabel'] as String?,
        customerName: json['customerName'] as String?,
        source: json['source'] as String? ?? 'app',
        ticketNumber: (json['number'] as num?)?.toInt(),
      );
}
