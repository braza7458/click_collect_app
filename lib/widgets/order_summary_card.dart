import 'package:flutter/material.dart';

import '../data/menu_data.dart';
import '../models/order.dart';
import '../models/order_mode.dart';
import '../theme/app_theme.dart';
import 'ui.dart';

String formatOrderDate(DateTime date) {
  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');
  final hour = date.hour.toString().padLeft(2, '0');
  final minute = date.minute.toString().padLeft(2, '0');
  return '$day/$month/${date.year} à $hour:$minute';
}

Color orderStatusColor(OrderStatus status) => switch (status) {
      OrderStatus.confirmed => AppColors.orange,
      OrderStatus.ready => AppColors.green,
      OrderStatus.completed => AppColors.creamMuted,
    };

class OrderSummaryCard extends StatelessWidget {
  const OrderSummaryCard({super.key, required this.order, this.showTracker = false});

  final Order order;

  /// Affiche la frise "En préparation → Prête → Récupérée".
  final bool showTracker;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final itemCount = order.lines.fold(0, (sum, l) => sum + l.quantity);

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Commande #${order.id}', style: textTheme.titleMedium),
                    const SizedBox(height: 2),
                    Text(formatOrderDate(order.date), style: textTheme.bodySmall),
                  ],
                ),
              ),
              Text(formatPrice(order.total), style: textTheme.titleLarge?.copyWith(color: AppColors.orange)),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              StatusPill(label: order.status.label, color: orderStatusColor(order.status)),
              StatusPill(label: order.mode.label, color: AppColors.cream, icon: order.mode.icon),
              if (order.paid) const StatusPill(label: 'Payée', color: AppColors.green, icon: Icons.check_rounded),
              if (order.pointsEarned > 0)
                StatusPill(label: '+${order.pointsEarned} pts', color: AppColors.honey, icon: Icons.workspace_premium_rounded),
              if (order.appliedRewardLabel != null)
                StatusPill(label: order.appliedRewardLabel!, color: AppColors.honey, icon: Icons.card_giftcard_rounded),
            ],
          ),
          if (showTracker) ...[
            const SizedBox(height: 18),
            OrderTracker(status: order.status),
          ],
          const SizedBox(height: 14),
          const Divider(),
          const SizedBox(height: 10),
          ...order.lines.map(
            (l) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  Text('${l.quantity}×', style: textTheme.bodyMedium?.copyWith(color: AppColors.orange, fontWeight: FontWeight.w700)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${l.itemName}${l.sizeLabel != null ? ' · ${l.sizeLabel}' : ''}'
                      '${l.supplements.isNotEmpty ? ' (+ ${l.supplements.map((s) => s.name).join(', ')})' : ''}',
                      style: textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (order.fulfillmentDetail != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.schedule_rounded, size: 15, color: AppColors.creamMuted),
                const SizedBox(width: 6),
                Expanded(child: Text(order.fulfillmentDetail!, style: textTheme.bodySmall)),
              ],
            ),
          ],
          const SizedBox(height: 2),
          Text('$itemCount article${itemCount > 1 ? 's' : ''}', style: textTheme.bodySmall),
        ],
      ),
    );
  }
}

/// Frise de suivi à 3 étapes, la courante mise en lumière.
class OrderTracker extends StatelessWidget {
  const OrderTracker({super.key, required this.status});

  final OrderStatus status;

  static const _steps = [
    (icon: Icons.local_fire_department_rounded, label: 'En préparation'),
    (icon: Icons.notifications_active_rounded, label: 'Prête'),
    (icon: Icons.check_circle_rounded, label: 'Récupérée'),
  ];

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final current = status.step;
    return Row(
      children: [
        for (var i = 0; i < _steps.length; i++) ...[
          if (i > 0)
            Expanded(
              child: AnimatedContainer(
                duration: AppMotion.slow,
                height: 3,
                margin: const EdgeInsets.only(bottom: 22),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2),
                  color: i <= current ? AppColors.orange : AppColors.glassBorder,
                ),
              ),
            ),
          Column(
            children: [
              AnimatedContainer(
                duration: AppMotion.slow,
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: i <= current ? AppColors.orange : AppColors.glass,
                  border: Border.all(color: i <= current ? AppColors.orange : AppColors.glassBorder),
                  boxShadow: i == current
                      ? [BoxShadow(color: AppColors.orange.withValues(alpha: 0.55), blurRadius: 16)]
                      : null,
                ),
                child: Icon(_steps[i].icon, size: 19, color: i <= current ? AppColors.charcoal : AppColors.creamMuted),
              ),
              const SizedBox(height: 6),
              Text(
                _steps[i].label,
                style: textTheme.labelMedium?.copyWith(color: i <= current ? AppColors.cream : AppColors.creamMuted),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
