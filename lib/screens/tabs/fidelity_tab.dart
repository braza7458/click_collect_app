import 'package:flutter/material.dart';

import '../../data/loyalty_data.dart';
import '../../state/app_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/order_summary_card.dart';
import '../../widgets/ui.dart';
import '../login_screen.dart';
import '../order_history_screen.dart';

class FidelityTab extends StatelessWidget {
  const FidelityTab({super.key, this.onNavigate});

  final ValueChanged<int>? onNavigate;

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);
    final textTheme = Theme.of(context).textTheme;

    if (appState.isGuest) return const _GuestGate();

    final rewardTiers = appState.rewardTiers;
    if (rewardTiers.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
      children: [
        const FadeSlideIn(child: Eyebrow('Programme fidélité', color: AppColors.honey)),
        const SizedBox(height: 4),
        FadeSlideIn(child: Text('Mes avantages', style: textTheme.headlineMedium)),
        const SizedBox(height: 18),
        FadeSlideIn(index: 1, child: _MemberCard(appState: appState)),
        const SizedBox(height: 18),
        const FadeSlideIn(index: 2, child: _HowItWorks()),
        const SizedBox(height: 28),
        const FadeSlideIn(index: 3, child: SectionHeader('Récompenses', eyebrow: 'À échanger')),
        const SizedBox(height: 12),
        for (var i = 0; i < rewardTiers.length; i++)
          FadeSlideIn(index: 4 + i, child: _RewardTile(tier: rewardTiers[i], appState: appState)),
        const SizedBox(height: 18),
        SectionHeader(
          'Mes dernières commandes',
          actionLabel: appState.orderHistory.isNotEmpty ? 'Voir tout' : null,
          onAction: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const OrderHistoryScreen())),
        ),
        const SizedBox(height: 12),
        if (appState.orderHistory.isEmpty)
          GlassCard(
            child: Row(
              children: [
                const IconBadge(Icons.receipt_long_rounded),
                const SizedBox(width: 14),
                Expanded(child: Text('Aucune commande pour le moment', style: textTheme.bodyMedium)),
                if (onNavigate != null)
                  TextButton(onPressed: () => onNavigate!(2), child: const Text('Commander')),
              ],
            ),
          )
        else
          ...appState.orderHistory.take(3).map(
                (order) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: OrderSummaryCard(order: order),
                ),
              ),
      ],
    );
  }
}

/// La carte membre, façon carte premium : or miel → braise, motif
/// d'anneaux, points qui "comptent", progression vers la prochaine récompense.
class _MemberCard extends StatelessWidget {
  const _MemberCard({required this.appState});

  final AppState appState;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final tiers = appState.rewardTiers;
    final next = tiers.firstWhere((t) => t.points > appState.points, orElse: () => tiers.last);
    final progress = (appState.points / next.points).clamp(0.0, 1.0);
    final left = (next.points - appState.points).clamp(0, next.points);
    const ink = AppColors.charcoal;

    return AspectRatio(
      aspectRatio: 1.62,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.xl),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFFD98A), AppColors.honey, Color(0xFFF0A145), AppColors.orange],
            stops: [0, 0.35, 0.75, 1],
          ),
          boxShadow: [
            BoxShadow(color: AppColors.honey.withValues(alpha: 0.35), blurRadius: 40, offset: const Offset(0, 16)),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.xl),
          child: Stack(
            children: [
              Positioned.fill(child: CustomPaint(painter: _RingsPainter())),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'LES POULETS DE MAMIE',
                          style: textTheme.labelSmall?.copyWith(color: ink.withValues(alpha: 0.75), letterSpacing: 2),
                        ),
                        const Spacer(),
                        Icon(Icons.workspace_premium_rounded, color: ink.withValues(alpha: 0.8)),
                      ],
                    ),
                    const Spacer(),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        CountUpText(
                          appState.points,
                          style: textTheme.displayMedium?.copyWith(color: ink, fontSize: 52, height: 0.9),
                        ),
                        const SizedBox(width: 8),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Text('points', style: textTheme.titleMedium?.copyWith(color: ink.withValues(alpha: 0.75))),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                      child: TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0, end: progress),
                        duration: const Duration(milliseconds: 1100),
                        curve: Curves.easeOutCubic,
                        builder: (context, v, _) => LinearProgressIndicator(
                          value: v,
                          minHeight: 8,
                          backgroundColor: ink.withValues(alpha: 0.15),
                          valueColor: const AlwaysStoppedAnimation(ink),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            left == 0
                                ? '« ${next.label} » est débloqué !'
                                : 'Plus que $left pts pour « ${next.label} »',
                            style: textTheme.bodySmall?.copyWith(color: ink.withValues(alpha: 0.85), fontWeight: FontWeight.w600),
                          ),
                        ),
                        Text(
                          appState.username,
                          style: textTheme.labelLarge?.copyWith(color: ink),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RingsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = Colors.white.withValues(alpha: 0.22);
    final center = Offset(size.width * 0.95, size.height * 0.05);
    for (var r = 30.0; r < size.width * 1.2; r += 22) {
      canvas.drawCircle(center, r, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _HowItWorks extends StatelessWidget {
  const _HowItWorks();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    Widget step(IconData icon, String title, String text) => Expanded(
          child: Column(
            children: [
              IconBadge(icon, color: AppColors.honey, size: 42),
              const SizedBox(height: 8),
              Text(title, style: textTheme.titleSmall, textAlign: TextAlign.center),
              Text(text, style: textTheme.bodySmall, textAlign: TextAlign.center),
            ],
          ),
        );
    return GlassCard(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          step(Icons.shopping_bag_rounded, 'Commandez', 'en ligne ou au comptoir'),
          step(Icons.euro_rounded, '1 € = 1 point', 'crédité automatiquement'),
          step(Icons.redeem_rounded, 'Régalez-vous', 'échangez vos points'),
        ],
      ),
    );
  }
}

class _RewardTile extends StatelessWidget {
  const _RewardTile({required this.tier, required this.appState});

  final RewardTier tier;
  final AppState appState;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final unlocked = appState.points >= tier.points;
    final progress = (appState.points / tier.points).clamp(0.0, 1.0);
    return GlassCard(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      borderColor: unlocked ? AppColors.honey.withValues(alpha: 0.5) : null,
      child: Row(
        children: [
          IconBadge(tier.icon, color: unlocked ? AppColors.honey : AppColors.creamMuted),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tier.label, style: textTheme.titleMedium),
                const SizedBox(height: 6),
                if (unlocked)
                  Text('${tier.points} points · disponible', style: textTheme.bodySmall?.copyWith(color: AppColors.honey))
                else ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 4,
                      color: AppColors.honey,
                      backgroundColor: AppColors.glassBorder,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text('${appState.points} / ${tier.points} points', style: textTheme.bodySmall),
                ],
              ],
            ),
          ),
          const SizedBox(width: 10),
          if (unlocked)
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.honey,
                foregroundColor: AppColors.charcoal,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
              ),
              onPressed: () async {
                final success = await appState.redeemReward(tier);
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? 'Récompense « ${tier.label} » échangée — présentez cet écran en caisse.'
                          : 'Points insuffisants pour cette récompense.',
                    ),
                  ),
                );
              },
              child: const Text('Échanger'),
            )
          else
            const Icon(Icons.lock_outline_rounded, color: AppColors.creamMuted),
        ],
      ),
    );
  }
}

/// Pour un invité : les points n'existent qu'avec un compte (pseudo + mot de
/// passe) — on explique pourquoi et on propose la seule porte d'entrée.
class _GuestGate extends StatelessWidget {
  const _GuestGate();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
        child: EmptyState(
          icon: Icons.workspace_premium_rounded,
          title: 'Vos points vous attendent',
          message: '1 € dépensé = 1 point, et des desserts, bowls ou menus offerts à la clé. '
              'Il suffit d\'un compte : un pseudo et un mot de passe, ni e-mail ni téléphone.',
          action: Column(
            children: [
              SizedBox(
                width: 280,
                child: GlowButton(
                  label: 'Créer un compte / Se connecter',
                  onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const LoginScreen())),
                ),
              ),
              const SizedBox(height: 10),
              Text('Gratuit, en 20 secondes.', style: textTheme.bodySmall),
            ],
          ),
        ),
      ),
    );
  }
}
