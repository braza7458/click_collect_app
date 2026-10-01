import 'package:flutter/material.dart';

import '../../data/restaurant_data.dart';
import '../../state/app_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/help_dialog.dart';
import '../../widgets/ui.dart';
import '../login_screen.dart';

/// Onglet "Pour vous" : l'accueil.
class HomeTab extends StatelessWidget {
  const HomeTab({super.key, required this.onNavigate});

  /// Index des onglets : 0 accueil, 1 restaurant, 2 commander, 3 fidélité, 4 plus.
  final ValueChanged<int> onNavigate;

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 5 || h >= 18) return 'Bonsoir';
    return 'Bonjour';
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);
    final textTheme = Theme.of(context).textTheme;
    final restaurant = appState.restaurant;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
      children: [
        FadeSlideIn(
          child: Row(
            children: [
              const BrandSeal(size: 46),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      appState.isGuest ? '${_greeting()} !' : '${_greeting()}, ${appState.username}',
                      style: textTheme.titleLarge,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      appState.isGuest ? 'Envie d\'un bon poulet rôti ?' : 'Ravi de vous revoir',
                      style: textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Invité : on l'invite à se connecter. Connecté : sa carte membre.
              if (appState.isGuest)
                _HeaderButton(
                  icon: Icons.login_rounded,
                  label: 'Me connecter',
                  highlighted: true,
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const LoginScreen())),
                )
              else
                _HeaderButton(
                  icon: Icons.qr_code_2_rounded,
                  label: 'Mon identifiant',
                  onTap: () => _showMemberCard(context, appState),
                ),
            ],
          ),
        ),
        const SizedBox(height: 22),
        FadeSlideIn(index: 1, child: _OpeningHero(restaurant: restaurant, onOrder: () => onNavigate(2))),
        if (!appState.isGuest && appState.rewardTiers.isNotEmpty) ...[
          const SizedBox(height: 14),
          FadeSlideIn(index: 2, child: _LoyaltyStrip(appState: appState, onTap: () => onNavigate(3))),
        ],
        const SizedBox(height: 30),
        const FadeSlideIn(index: 3, child: SectionHeader('Les incontournables', eyebrow: 'En ce moment')),
        const SizedBox(height: 14),
        FadeSlideIn(
          index: 4,
          child: SizedBox(
            height: 236,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              clipBehavior: Clip.none,
              itemCount: _features.length,
              separatorBuilder: (_, _) => const SizedBox(width: 14),
              itemBuilder: (context, i) => _FeatureCard(feature: _features[i], onTap: () => onNavigate(2)),
            ),
          ),
        ),
        const SizedBox(height: 30),
        const FadeSlideIn(index: 5, child: SectionHeader('Événements à venir', eyebrow: 'Au restaurant')),
        const SizedBox(height: 14),
        const FadeSlideIn(index: 6, child: _UpcomingEvents()),
        const SizedBox(height: 30),
        FadeSlideIn(
          index: 7,
          child: Row(
            children: [
              Expanded(
                child: _QuickAction(
                  icon: Icons.restaurant_menu_rounded,
                  title: 'La carte',
                  subtitle: 'Poulets, bowls, plats du jour',
                  onTap: () => onNavigate(2),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _QuickAction(
                  icon: Icons.support_agent_rounded,
                  title: 'Besoin d\'aide ?',
                  subtitle: restaurant.phone ?? '',
                  onTap: () => showHelpDialog(context),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showMemberCard(BuildContext context, AppState appState) {
    final textTheme = Theme.of(context).textTheme;
    showModalBottomSheet(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Eyebrow('Carte membre', color: AppColors.honey),
              const SizedBox(height: 6),
              Text('Mon identifiant', style: textTheme.headlineSmall),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.cream,
                  borderRadius: BorderRadius.circular(AppRadius.xl),
                  boxShadow: [BoxShadow(color: AppColors.honey.withValues(alpha: 0.35), blurRadius: 40)],
                ),
                child: const Icon(Icons.qr_code_2_rounded, size: 180, color: AppColors.charcoal),
              ),
              const SizedBox(height: 18),
              Text(appState.username, style: textTheme.titleLarge),
              const SizedBox(height: 4),
              Text('${appState.points} points · à la borne, connectez-vous avec votre pseudo', style: textTheme.bodySmall),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeaderButton extends StatelessWidget {
  const _HeaderButton({required this.icon, required this.label, required this.onTap, this.highlighted = false});

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final fg = highlighted ? AppColors.charcoal : AppColors.cream;
    return Pressable(
      child: Material(
        color: highlighted ? AppColors.orange : AppColors.glass,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.pill),
          side: highlighted ? BorderSide.none : const BorderSide(color: AppColors.glassBorder),
        ),
        child: InkWell(
          customBorder: const StadiumBorder(),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 18, color: fg),
                const SizedBox(width: 6),
                Text(label, style: Theme.of(context).textTheme.labelLarge?.copyWith(color: fg, fontSize: 13)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// La grande carte du haut : ouvert / fermé en direct, horaires du jour et
/// le bouton pour commander.
class _OpeningHero extends StatelessWidget {
  const _OpeningHero({required this.restaurant, required this.onOrder});

  final RestaurantLocation restaurant;
  final VoidCallback onOrder;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final status = restaurant.statusAt(DateTime.now());
    final statusColor = status.isOpen ? AppColors.green : AppColors.red;
    return GlassCard(
      padding: EdgeInsets.zero,
      radius: AppRadius.xl,
      child: Stack(
        children: [
          Positioned(
            right: -30,
            top: -30,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [AppColors.orange.withValues(alpha: 0.35), AppColors.orange.withValues(alpha: 0)],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    StatusPill(label: status.headline, color: statusColor),
                    const SizedBox(width: 10),
                    Expanded(child: Text(status.detail, style: textTheme.bodySmall)),
                  ],
                ),
                const SizedBox(height: 16),
                Text('Votre poulet rôti,\nprêt quand vous l\'êtes.', style: textTheme.headlineSmall?.copyWith(height: 1.15)),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(Icons.place_outlined, size: 16, color: AppColors.creamMuted),
                    const SizedBox(width: 6),
                    Expanded(child: Text(restaurant.address, style: textTheme.bodySmall)),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.schedule_rounded, size: 16, color: AppColors.creamMuted),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text('Aujourd\'hui : ${restaurant.todayHoursLabel}', style: textTheme.bodySmall),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                GlowButton(
                  icon: Icons.shopping_bag_rounded,
                  label: status.isOpen ? 'Commander maintenant' : 'Commander pour plus tard',
                  onPressed: onOrder,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LoyaltyStrip extends StatelessWidget {
  const _LoyaltyStrip({required this.appState, required this.onTap});

  final AppState appState;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final tiers = appState.rewardTiers;
    final next = tiers.firstWhere((t) => t.points > appState.points, orElse: () => tiers.last);
    final progress = (appState.points / next.points).clamp(0.0, 1.0);
    final left = (next.points - appState.points).clamp(0, next.points);
    return GlassCard(
      onTap: onTap,
      padding: const EdgeInsets.all(16),
      borderColor: AppColors.honey.withValues(alpha: 0.35),
      child: Row(
        children: [
          SizedBox(
            width: 52,
            height: 52,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 4,
                  color: AppColors.honey,
                  backgroundColor: AppColors.honey.withValues(alpha: 0.15),
                  strokeCap: StrokeCap.round,
                ),
                const Icon(Icons.workspace_premium_rounded, color: AppColors.honey, size: 22),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${appState.points} points', style: textTheme.titleMedium?.copyWith(color: AppColors.honey)),
                const SizedBox(height: 2),
                Text(
                  left == 0 ? '« ${next.label} » est à vous !' : 'Plus que $left pts pour « ${next.label} »',
                  style: textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: AppColors.creamMuted),
        ],
      ),
    );
  }
}

class _Feature {
  const _Feature({required this.image, required this.tag, required this.title, required this.subtitle});
  final String image;
  final String tag;
  final String title;
  final String subtitle;
}

const _features = [
  _Feature(
    image: 'assets/images/tasty_cheddar.jpg',
    tag: 'Nouveau',
    title: 'Crousty Cheddar',
    subtitle: 'Bowl · 8,50 €',
  ),
  _Feature(
    image: 'assets/images/tajine.jpg',
    tag: 'Le mercredi',
    title: 'Tajine du mercredi',
    subtitle: 'Plat de la semaine · 11,50 €',
  ),
];

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({required this.feature, required this.onTap});

  final _Feature feature;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final width = (MediaQuery.sizeOf(context).width * 0.74).clamp(240.0, 340.0);
    return Pressable(
      child: SizedBox(
        width: width,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.xl),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.45), blurRadius: 24, offset: const Offset(0, 12))],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.xl),
            child: Material(
              color: AppColors.charcoal,
              child: InkWell(
                onTap: onTap,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(feature.image, fit: BoxFit.cover),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.transparent, AppColors.charcoal.withValues(alpha: 0.92)],
                          stops: const [0.35, 1],
                        ),
                      ),
                    ),
                    Positioned(
                      right: 14,
                      top: 14,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppColors.honey,
                          borderRadius: BorderRadius.circular(AppRadius.pill),
                        ),
                        child: Text(
                          feature.tag.toUpperCase(),
                          style: textTheme.labelSmall?.copyWith(color: AppColors.charcoal, letterSpacing: 1),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 16,
                      right: 16,
                      bottom: 16,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(feature.title, style: textTheme.titleLarge),
                                const SizedBox(height: 2),
                                Text(feature.subtitle, style: textTheme.bodySmall?.copyWith(color: AppColors.cream)),
                              ],
                            ),
                          ),
                          Container(
                            width: 40,
                            height: 40,
                            decoration: const BoxDecoration(color: AppColors.orange, shape: BoxShape.circle),
                            child: const Icon(Icons.arrow_forward_rounded, color: AppColors.charcoal, size: 20),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Événements à venir. Aucun n'est programmé pour l'instant : on l'affiche
/// honnêtement plutôt que d'inventer des dates. Pour en annoncer un, ajouter
/// une entrée à [_events].
class _UpcomingEvents extends StatelessWidget {
  const _UpcomingEvents();

  static const List<({String title, String date})> _events = [];

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    if (_events.isEmpty) {
      return GlassCard(
        child: Row(
          children: [
            const IconBadge(Icons.celebration_rounded, color: AppColors.honey),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Rien de prévu pour l\'instant', style: textTheme.titleMedium),
                  const SizedBox(height: 2),
                  Text(
                    'Soirées spéciales, plats de saison… les prochains rendez-vous de Mamie apparaîtront ici.',
                    style: textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }
    return Column(
      children: [
        for (final e in _events)
          GlassCard(
            margin: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                const IconBadge(Icons.event_rounded, color: AppColors.honey),
                const SizedBox(width: 14),
                Expanded(child: Text(e.title, style: textTheme.titleMedium)),
                Text(e.date, style: textTheme.bodySmall),
              ],
            ),
          ),
      ],
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({required this.icon, required this.title, required this.subtitle, required this.onTap});

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return GlassCard(
      onTap: onTap,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconBadge(icon, size: 40),
          const SizedBox(height: 14),
          Text(title, style: textTheme.titleMedium),
          const SizedBox(height: 2),
          Text(subtitle, style: textTheme.bodySmall, maxLines: 1, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}
