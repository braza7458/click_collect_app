import 'package:flutter/material.dart';

import '../../state/app_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/order_summary_card.dart';
import '../login_screen.dart';
import '../order_history_screen.dart';

class FidelityTab extends StatelessWidget {
  const FidelityTab({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);
    final textTheme = Theme.of(context).textTheme;

    if (appState.isGuest) {
      return _GuestGate(textTheme: textTheme);
    }

    final rewardTiers = appState.rewardTiers;
    if (rewardTiers.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    final nextTier = rewardTiers.firstWhere(
      (t) => t.points > appState.points,
      orElse: () => rewardTiers.last,
    );
    final double progress = (appState.points / nextTier.points).clamp(0.0, 1.0).toDouble();

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      children: [
        Text('Fidélité', style: textTheme.headlineSmall),
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
            borderRadius: BorderRadius.circular(AppRadius.xl),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.35),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${appState.points}',
                style: textTheme.displayMedium?.copyWith(color: AppColors.charcoal),
              ),
              Text(
                'points cumulés',
                style: textTheme.bodyMedium?.copyWith(color: AppColors.charcoal.withValues(alpha: 0.8)),
              ),
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.sm),
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
                style: textTheme.bodySmall?.copyWith(color: AppColors.charcoal.withValues(alpha: 0.85)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Text('Récompenses disponibles', style: textTheme.titleMedium),
        const SizedBox(height: 12),
        ...rewardTiers.map((tier) {
          final unlocked = appState.points >= tier.points;
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: unlocked ? AppColors.surfaceAlt : AppColors.charcoalSoft,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(
                color: unlocked ? AppColors.orange.withValues(alpha: 0.4) : AppColors.divider,
              ),
              boxShadow: const [
                BoxShadow(color: Color(0x66000000), blurRadius: 2, offset: Offset(0, 1)),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.orange.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(tier.icon, color: AppColors.orange, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(tier.label, style: textTheme.titleMedium),
                      Text('${tier.points} points', style: textTheme.bodySmall),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                OutlinedButton(
                  onPressed: unlocked
                      ? () async {
                          final success = await appState.redeemReward(tier);
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                success
                                    ? 'Récompense "${tier.label}" échangée — présentez cet écran en caisse.'
                                    : 'Points insuffisants pour cette récompense.',
                              ),
                            ),
                          );
                        }
                      : null,
                  child: const Text('Échanger'),
                ),
              ],
            ),
          );
        }),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: Text('Historique', style: textTheme.titleMedium)),
            if (appState.orderHistory.length > 3)
              TextButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const OrderHistoryScreen()),
                ),
                child: const Text('Voir tout'),
              ),
          ],
        ),
        const SizedBox(height: 4),
        if (appState.orderHistory.isEmpty)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 32),
            decoration: BoxDecoration(
              color: AppColors.charcoalSoft,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: AppColors.divider),
            ),
            child: Column(
              children: [
                Icon(Icons.receipt_long_outlined, color: AppColors.creamMuted.withValues(alpha: 0.6), size: 36),
                const SizedBox(height: 8),
                Text('Aucune commande pour le moment', style: textTheme.bodyMedium),
              ],
            ),
          )
        else
          ...appState.orderHistory.take(3).map(
                (order) => Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: OrderSummaryCard(order: order),
                ),
              ),
      ],
    );
  }
}

/// Shown instead of the loyalty program for a guest session — points only
/// ever accrue on a real (pseudo + password) account, so there's nothing
/// genuine to show a guest here; this explains why and offers the one way
/// in.
class _GuestGate extends StatelessWidget {
  const _GuestGate({required this.textTheme});

  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.loyalty_outlined, color: AppColors.creamMuted.withValues(alpha: 0.6), size: 48),
            const SizedBox(height: 20),
            Text('Créez un compte pour la fidélité', style: textTheme.titleLarge, textAlign: TextAlign.center),
            const SizedBox(height: 10),
            Text(
              'Les points ne sont accessibles qu\'avec un compte (pseudo + mot de passe — ni e-mail ni téléphone requis).',
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              ),
              child: const Text('Créer un compte / Se connecter'),
            ),
          ],
        ),
      ),
    );
  }
}
