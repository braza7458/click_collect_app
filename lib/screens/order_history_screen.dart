import 'package:flutter/material.dart';

import '../data/orders_repository.dart';
import '../models/order.dart';
import '../state/app_state.dart';
import '../widgets/order_summary_card.dart';
import '../widgets/ui.dart';

/// "Mes commandes" — suivies en direct : le statut change à l'écran dès
/// que l'équipe la marque prête au terminal de réception.
class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  Stream<List<Order>>? _stream;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;
    final uid = AppStateScope.of(context).uid;
    if (uid != null) {
      try {
        _stream = OrdersRepository.watchOrdersForUser(uid);
      } catch (_) {
        // Firestore indisponible : on se rabat sur l'historique en mémoire.
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Mes commandes')),
      body: _stream == null
          ? _OrderList(orders: appState.orderHistory)
          : StreamBuilder<List<Order>>(
              stream: _stream,
              builder: (context, snapshot) {
                // Erreur ou chargement : l'historique déjà connu plutôt qu'un écran vide.
                final orders = snapshot.data ?? appState.orderHistory;
                if (snapshot.connectionState == ConnectionState.waiting && orders.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }
                return _OrderList(orders: orders, onRefresh: appState.refreshOrders);
              },
            ),
    );
  }
}

class _OrderList extends StatelessWidget {
  const _OrderList({required this.orders, this.onRefresh});

  final List<Order> orders;
  final Future<void> Function()? onRefresh;

  @override
  Widget build(BuildContext context) {
    if (orders.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: EmptyState(
            icon: Icons.receipt_long_rounded,
            title: 'Aucune commande pour le moment',
            message: 'Vos commandes apparaîtront ici, avec leur suivi en direct.',
          ),
        ),
      );
    }
    final list = ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
      itemCount: orders.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, i) => FadeSlideIn(
        index: i,
        child: OrderSummaryCard(
          order: orders[i],
          // Suivi détaillé pour les commandes encore en cours.
          showTracker: orders[i].status != OrderStatus.completed,
        ),
      ),
    );
    return onRefresh == null ? list : RefreshIndicator(onRefresh: onRefresh!, child: list);
  }
}
