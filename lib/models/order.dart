import 'cart_line.dart';
import 'order_mode.dart';

/// An order placed entirely on-device (no backend yet — see [AppState]).
/// There is deliberately no "en préparation" / "prête" progression: with no
/// kitchen system behind it, the app cannot know the real status, so it only
/// ever reports [confirmed] rather than fabricate one.
enum OrderStatus { confirmed }

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
      };

  factory Order.fromJson(Map<String, dynamic> json) => Order(
        id: json['id'] as String,
        date: DateTime.parse(json['date'] as String),
        mode: OrderMode.values.byName(json['mode'] as String),
        lines: (json['lines'] as List<dynamic>)
            .map((l) => CartLine.fromJson(l as Map<String, dynamic>))
            .toList(),
        total: (json['total'] as num).toDouble(),
        pointsEarned: json['pointsEarned'] as int,
        restaurantName: json['restaurantName'] as String?,
        fulfillmentDetail: json['fulfillmentDetail'] as String?,
        status: OrderStatus.values.byName(json['status'] as String? ?? 'confirmed'),
      );
}
