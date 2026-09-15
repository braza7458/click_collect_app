import 'package:flutter/material.dart';

import '../../data/loyalty_data.dart';
import '../../state/app_state.dart';
import '../../theme/app_theme.dart';

class FidelityTab extends StatelessWidget {
  const FidelityTab({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);
    final nextTier = rewardTiers.firstWhere(
      (t) => t.points > appState.points,
      orElse: () => rewardTiers.last,
    );
    final double progress = (appState.points / nextTier.points).clamp(0.0, 1.0).toDouble();

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      children: [
        Text('Fidélité', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 20),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.orange, AppColors.orangeDark],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${appState.points}', style: Theme.of(context).textTheme.displayMedium?.copyWith(color: AppColors.charcoal)),
              Text('points cumulés', style: TextStyle(color: AppColors.charcoal.withValues(alpha: 0.8))),
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 8,
                  backgroundColor: AppColors.charcoal.withValues(alpha: 0.2),
                  valueColor: const AlwaysStoppedAnimation(AppColors.charcoal),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Plus que ${(nextTier.points - appState.points).clamp(0, nextTier.points)} points pour "${nextTier.label}"',
                style: TextStyle(color: AppColors.charcoal.withValues(alpha: 0.85), fontSize: 13),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Text('Récompenses disponibles', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        ...rewardTiers.map((tier) {
          final unlocked = appState.points >= tier.points;
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.charcoalSoft,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.orange.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(tier.icon, color: AppColors.orange),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(tier.label, style: Theme.of(context).textTheme.titleMedium),
                      Text('${tier.points} points', style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                ),
                OutlinedButton(
                  onPressed: unlocked
                      ? () => ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Récompense "${tier.label}" échangée.')),
                          )
                      : null,
                  child: const Text('Échanger'),
                ),
              ],
            ),
          );
        }),
        const SizedBox(height: 12),
        Text('Historique', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 32),
          decoration: BoxDecoration(
            color: AppColors.charcoalSoft,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            children: [
              Icon(Icons.receipt_long_outlined, color: AppColors.creamMuted.withValues(alpha: 0.6), size: 36),
              const SizedBox(height: 8),
              Text('Aucune commande pour le moment', style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ),
      ],
    );
  }
}
