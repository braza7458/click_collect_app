import 'package:flutter/material.dart';

import '../data/orders_repository.dart';
import '../models/order.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/order_summary_card.dart';
import '../widgets/ui.dart';
import 'dashboard_shell.dart';

class OrderConfirmationScreen extends StatefulWidget {
  const OrderConfirmationScreen({super.key, required this.order});

  final Order order;

  @override
  State<OrderConfirmationScreen> createState() => _OrderConfirmationScreenState();
}

class _OrderConfirmationScreenState extends State<OrderConfirmationScreen> {
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
      } catch (_) {}
    }
  }

  void _goHome() => Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const DashboardShell()),
        (route) => false,
      );

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      body: SafeArea(
        child: StreamBuilder<List<Order>>(
          stream: _stream,
          builder: (context, snapshot) {
            // La version en direct de cette commande (statut mis à jour par le
            // terminal), sinon celle qu'on vient de passer.
            final live = snapshot.data?.where((o) => o.id == widget.order.id).firstOrNull ?? widget.order;
            final ready = live.status == OrderStatus.ready;
            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 24),
              children: [
                Center(child: _SuccessBadge(ready: ready)),
                const SizedBox(height: 22),
                FadeSlideIn(
                  index: 2,
                  child: Text(
                    ready ? 'Votre commande est prête !' : 'Commande confirmée',
                    textAlign: TextAlign.center,
                    style: textTheme.headlineMedium,
                  ),
                ),
                const SizedBox(height: 8),
                FadeSlideIn(
                  index: 3,
                  child: Text(
                    ready
                        ? 'Elle vous attend au comptoir — à tout de suite.'
                        : live.paid
                            ? 'Paiement reçu. Mamie s\'occupe du reste — vous recevrez un SMS quand ce sera prêt.'
                            : 'Vous réglerez sur place. Vous recevrez un SMS quand ce sera prêt.',
                    textAlign: TextAlign.center,
                    style: textTheme.bodyMedium,
                  ),
                ),
                const SizedBox(height: 26),
                FadeSlideIn(index: 4, child: OrderSummaryCard(order: live, showTracker: true)),
                const SizedBox(height: 22),
                FadeSlideIn(index: 5, child: GlowButton(label: 'Retour à l\'accueil', onPressed: _goHome)),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// Coche qui "éclot" avec un rebond, entourée d'un halo.
class _SuccessBadge extends StatelessWidget {
  const _SuccessBadge({required this.ready});

  final bool ready;

  @override
  Widget build(BuildContext context) {
    final color = ready ? AppColors.green : AppColors.orange;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 900),
      curve: Curves.elasticOut,
      builder: (context, t, child) => Transform.scale(scale: 0.4 + 0.6 * t, child: child),
      child: AnimatedContainer(
        duration: AppMotion.slow,
        width: 104,
        height: 104,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color.lerp(color, Colors.white, 0.25)!, color],
          ),
          boxShadow: [BoxShadow(color: color.withValues(alpha: 0.55), blurRadius: 44, spreadRadius: 4)],
        ),
        child: Icon(
          ready ? Icons.notifications_active_rounded : Icons.check_rounded,
          color: AppColors.charcoal,
          size: 54,
        ),
      ),
    );
  }
}
