import 'package:flutter/material.dart';

import '../../data/restaurant_data.dart';
import '../../services/contact.dart';
import '../../state/app_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/ui.dart';

/// Onglet "Restaurant" : l'unique restaurant de l'enseigne — adresse,
/// téléphone, horaires de la semaine (jour courant mis en avant) et la
/// carte papier en grand.
class RestaurantTab extends StatelessWidget {
  const RestaurantTab({super.key});

  @override
  Widget build(BuildContext context) {
    final restaurant = AppStateScope.of(context).restaurant;
    final textTheme = Theme.of(context).textTheme;
    final status = restaurant.statusAt(DateTime.now());

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
      children: [
        FadeSlideIn(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.xl),
            child: SizedBox(
              height: 210,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset('assets/images/fond.jpg', fit: BoxFit.cover, alignment: const Alignment(0, 0.15)),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, AppColors.charcoal.withValues(alpha: 0.9)],
                        stops: const [0.3, 1],
                      ),
                    ),
                  ),
                  Positioned(
                    left: 18,
                    right: 18,
                    bottom: 16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        DecoratedBox(
                          // Fond sombre sous la pastille : lisible sur la photo.
                          decoration: BoxDecoration(
                            color: AppColors.glassStrong,
                            borderRadius: BorderRadius.circular(AppRadius.pill),
                          ),
                          child: StatusPill(
                            label: '${status.headline} · ${status.detail}',
                            color: status.isOpen ? AppColors.green : AppColors.red,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(restaurant.name, style: textTheme.headlineMedium),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),
        FadeSlideIn(
          index: 1,
          child: GlassCard(
            child: Column(
              children: [
                _InfoRow(icon: Icons.place_rounded, label: 'Adresse', value: restaurant.address),
                const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider()),
                _InfoRow(icon: Icons.call_rounded, label: 'Téléphone', value: restaurant.phone ?? '—'),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: GlowButton(
                        height: 52,
                        icon: Icons.call_rounded,
                        label: 'Appeler',
                        onPressed: () => callRestaurant(context, restaurant),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: SizedBox(
                        height: 52,
                        child: OutlinedButton.icon(
                          onPressed: () => openItinerary(context, restaurant),
                          icon: const Icon(Icons.directions_rounded, size: 20),
                          label: const Text('Itinéraire'),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 26),
        const FadeSlideIn(index: 2, child: SectionHeader('Horaires', eyebrow: 'Quand passer nous voir')),
        const SizedBox(height: 12),
        FadeSlideIn(index: 3, child: _HoursCard(restaurant: restaurant)),
        const SizedBox(height: 26),
        const FadeSlideIn(index: 4, child: SectionHeader('Sur place & à emporter', eyebrow: 'Services')),
        const SizedBox(height: 12),
        const FadeSlideIn(
          index: 5,
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              StatusPill(label: 'Click & Collect', color: AppColors.orange, icon: Icons.shopping_bag_rounded),
              StatusPill(label: 'Sur place', color: AppColors.honey, icon: Icons.restaurant_rounded),
              StatusPill(label: 'Livraison', color: AppColors.green, icon: Icons.delivery_dining_rounded),
              StatusPill(label: 'Poulet fermier Label Rouge', color: AppColors.honey, icon: Icons.workspace_premium_rounded),
            ],
          ),
        ),
        const SizedBox(height: 26),
        FadeSlideIn(
          index: 6,
          child: GlassCard(
            onTap: () => _showPaperMenu(context),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                  child: Image.asset('assets/images/menu.jpeg', width: 56, height: 72, fit: BoxFit.cover),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('La carte papier', style: textTheme.titleMedium),
                      const SizedBox(height: 2),
                      Text('Toute la carte du restaurant, à zoomer du bout des doigts.', style: textTheme.bodySmall),
                    ],
                  ),
                ),
                const Icon(Icons.zoom_out_map_rounded, color: AppColors.creamMuted),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showPaperMenu(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.9),
      builder: (dialogContext) => GestureDetector(
        onTap: () => Navigator.of(dialogContext).pop(),
        child: Stack(
          children: [
            Positioned.fill(
              child: InteractiveViewer(
                maxScale: 5,
                child: Center(child: Image.asset('assets/images/menu.jpeg')),
              ),
            ),
            Positioned(
              top: MediaQuery.paddingOf(dialogContext).top + 8,
              right: 8,
              child: IconButton.filled(
                style: IconButton.styleFrom(backgroundColor: AppColors.glassStrong),
                onPressed: () => Navigator.of(dialogContext).pop(),
                icon: const Icon(Icons.close_rounded, color: AppColors.cream),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Row(
      children: [
        IconBadge(icon, size: 40),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: textTheme.bodySmall),
              const SizedBox(height: 2),
              Text(value, style: textTheme.titleMedium),
            ],
          ),
        ),
      ],
    );
  }
}

class _HoursCard extends StatelessWidget {
  const _HoursCard({required this.restaurant});

  final RestaurantLocation restaurant;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final today = DateTime.now().weekday - 1;
    return GlassCard(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          for (var i = 0; i < 7; i++)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
              decoration: BoxDecoration(
                color: i == today ? AppColors.orange.withValues(alpha: 0.14) : Colors.transparent,
                borderRadius: BorderRadius.circular(AppRadius.sm),
                border: i == today ? Border.all(color: AppColors.orange.withValues(alpha: 0.35)) : null,
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 96,
                    child: Text(
                      weekdayNames[i],
                      style: (i == today ? textTheme.titleSmall?.copyWith(color: AppColors.orange) : textTheme.bodyMedium),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      restaurant.hoursLabelFor(i),
                      textAlign: TextAlign.right,
                      style: restaurant.schedule[i].isEmpty
                          ? textTheme.bodyMedium?.copyWith(color: AppColors.red.withValues(alpha: 0.85))
                          : (i == today ? textTheme.titleSmall : textTheme.bodyLarge),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
