import 'package:flutter/material.dart';

import '../data/menu_data.dart';
import '../models/order.dart';
import '../models/order_mode.dart';
import '../theme/app_theme.dart';

String formatOrderDate(DateTime date) {
  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');
  final hour = date.hour.toString().padLeft(2, '0');
  final minute = date.minute.toString().padLeft(2, '0');
  return '$day/$month/${date.year} à $hour:$minute';
}

class OrderSummaryCard extends StatelessWidget {
  const OrderSummaryCard({super.key, required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final itemCount = order.lines.fold(0, (sum, l) => sum + l.quantity);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.charcoalSoft,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.divider),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.4), blurRadius: 2, offset: const Offset(0, 1)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text('Commande #${order.id}', style: textTheme.titleMedium),
              ),
              Text(formatPrice(order.total), style: textTheme.titleMedium?.copyWith(color: AppColors.orange)),
            ],
          ),
          const SizedBox(height: 4),
          Text(formatOrderDate(order.date), style: textTheme.bodySmall),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _Chip(icon: order.mode.icon, label: order.mode.label),
              _Chip(icon: Icons.shopping_bag_outlined, label: '$itemCount article${itemCount > 1 ? 's' : ''}'),
              if (order.pointsEarned > 0) _Chip(icon: Icons.loyalty, label: '+${order.pointsEarned} pts'),
              if (order.paid) _Chip(icon: Icons.check_circle_outline, label: 'Payée'),
              if (order.appliedRewardLabel != null) _Chip(icon: Icons.card_giftcard, label: order.appliedRewardLabel!),
            ],
          ),
          if (order.fulfillmentDetail != null) ...[
            const SizedBox(height: 10),
            Text(order.fulfillmentDetail!, style: textTheme.bodySmall),
          ],
          const SizedBox(height: 10),
          ...order.lines.map(
            (l) => Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                '${l.quantity} × ${l.itemName}${l.sizeLabel != null ? ' (${l.sizeLabel})' : ''}',
                style: textTheme.bodySmall,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.orange.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.orange),
          const SizedBox(width: 5),
          Text(label, style: Theme.of(context).textTheme.labelLarge?.copyWith(color: AppColors.orange, letterSpacing: 0, fontSize: 12)),
        ],
      ),
    );
  }
}
