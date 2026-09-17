import 'package:flutter/material.dart';

import '../state/app_state.dart';
import '../theme/app_theme.dart';
import 'dashboard_shell.dart';

class LoyaltyIntroScreen extends StatelessWidget {
  const LoyaltyIntroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final rewardTiers = AppStateScope.of(context).rewardTiers;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              Text('Le programme fidélité', style: textTheme.headlineMedium),
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
                      color: AppColors.orangeDark.withValues(alpha: 0.28),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.loyalty, color: AppColors.charcoal, size: 32),
                    const SizedBox(height: 12),
                    Text(
                      '1 € dépensé = 1 point gagné',
                      style: textTheme.titleLarge?.copyWith(color: AppColors.charcoal),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Vos points sont automatiquement crédités sur votre compte à chaque commande.',
                      style: textTheme.bodyMedium?.copyWith(color: AppColors.charcoal.withValues(alpha: 0.8)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              Text('Vos récompenses', style: textTheme.titleMedium),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.separated(
                  itemCount: rewardTiers.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, i) {
                    final tier = rewardTiers[i];
                    return Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.charcoalSoft,
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                        border: Border.all(color: AppColors.divider),
                        boxShadow: const [
                          BoxShadow(color: Color(0x66000000), blurRadius: 2, offset: Offset(0, 1)),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: AppColors.orange.withValues(alpha: 0.12),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(tier.icon, color: AppColors.orange, size: 22),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text(tier.label, style: textTheme.titleMedium),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: AppColors.badgeAmber.withValues(alpha: 0.14),
                              borderRadius: BorderRadius.circular(AppRadius.pill),
                            ),
                            child: Text(
                              '${tier.points} pts',
                              style: textTheme.labelLarge?.copyWith(color: AppColors.badgeAmber),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const DashboardShell()),
                  (route) => false,
                ),
                child: const Text('Accéder à mon compte'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
