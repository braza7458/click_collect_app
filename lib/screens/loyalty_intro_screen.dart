import 'package:flutter/material.dart';

import '../data/loyalty_data.dart';
import '../theme/app_theme.dart';
import 'dashboard_shell.dart';

class LoyaltyIntroScreen extends StatelessWidget {
  const LoyaltyIntroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              Text('Le programme fidélité', style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.orange, AppColors.orangeDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.loyalty, color: AppColors.charcoal, size: 32),
                    const SizedBox(height: 12),
                    Text(
                      '1 € dépensé = 1 point gagné',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppColors.charcoal),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Vos points sont automatiquement crédités sur votre compte à chaque commande.',
                      style: TextStyle(color: AppColors.charcoal.withValues(alpha: 0.8)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              Text('Vos récompenses', style: Theme.of(context).textTheme.titleMedium),
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
                            child: Text(tier.label, style: Theme.of(context).textTheme.titleMedium),
                          ),
                          Text(
                            '${tier.points} pts',
                            style: const TextStyle(color: AppColors.orange, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
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
