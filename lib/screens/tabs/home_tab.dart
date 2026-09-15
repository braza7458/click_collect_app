import 'package:flutter/material.dart';

import '../../state/app_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/order_mode_sheet.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({super.key, required this.onNavigate});

  final ValueChanged<int> onNavigate;

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Bonjour ${appState.firstName}', style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 4),
                  Text(
                    appState.isGuest
                        ? 'Connectez-vous pour cumuler des points'
                        : 'Vous avez ${appState.points} points',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            OutlinedButton.icon(
              onPressed: () => _showMemberCard(context, appState),
              icon: const Icon(Icons.qr_code_2, size: 18),
              label: const Text('Mon identifiant'),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Text('En ce moment en restaurant', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        SizedBox(
          height: 150,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _offers.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (context, i) => _OfferCard(offer: _offers[i]),
          ),
        ),
        const SizedBox(height: 28),
        Text('Votre restaurant favori', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: _level1Decoration(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      appState.favoriteRestaurantName ?? 'Aucun restaurant sélectionné',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(color: AppColors.green, shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Ouvert',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(color: AppColors.green, letterSpacing: 0),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 16,
                runSpacing: 8,
                children: const [
                  _ServiceBadge(icon: Icons.storefront_outlined, label: 'Click & Collect'),
                  _ServiceBadge(icon: Icons.delivery_dining_outlined, label: 'Livraison'),
                  _ServiceBadge(icon: Icons.table_bar_outlined, label: 'Sur place'),
                ],
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => showOrderModeSheet(context),
                icon: const Icon(Icons.shopping_bag_outlined, size: 20),
                label: const Text('Commander'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),
        Text('Événements & Ateliers', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        SizedBox(
          height: 132,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _events.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (context, i) => _EventCard(event: _events[i]),
          ),
        ),
        const SizedBox(height: 28),
        _ActionCard(
          icon: Icons.restaurant_menu_outlined,
          title: 'La carte',
          description: 'Découvrez tous nos poulets rôtis, bowls et accompagnements.',
          buttonLabel: 'Découvrir la carte',
          onPressed: () => onNavigate(2),
        ),
        const SizedBox(height: 16),
        _ActionCard(
          icon: Icons.help_outline,
          title: 'Besoin d\'assistance ?',
          description: 'Une question sur votre commande ou votre compte fidélité ?',
          buttonLabel: 'Consulter l\'aide',
          onPressed: () => showDialog(
            context: context,
            builder: (dialogContext) => AlertDialog(
              title: const Text('Besoin d\'aide ?'),
              content: const Text(
                'Contactez-nous au 01 23 45 67 89 ou directement en boutique. Notre équipe vous répond du mardi au dimanche.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Fermer'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showMemberCard(BuildContext context, AppState appState) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Mon identifiant'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.qr_code_2, size: 160, color: AppColors.orange),
            const SizedBox(height: 12),
            Text(appState.isGuest ? 'Invité' : appState.firstName, style: Theme.of(dialogContext).textTheme.titleMedium),
            Text('${appState.points} points', style: Theme.of(dialogContext).textTheme.bodyMedium),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }
}

class _ServiceBadge extends StatelessWidget {
  const _ServiceBadge({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: AppColors.creamMuted),
        const SizedBox(width: 6),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

/// Level-1 elevation: [AppColors.charcoalSoft] fill, a hairline
/// [AppColors.divider] border, and a barely-there shadow purely to lift the
/// edge off the near-black background — used for standard cards/list tiles.
BoxDecoration _level1Decoration({double radius = AppRadius.lg}) {
  return BoxDecoration(
    color: AppColors.charcoalSoft,
    borderRadius: BorderRadius.circular(radius),
    border: Border.all(color: AppColors.divider),
    boxShadow: [
      BoxShadow(color: AppColors.charcoal.withValues(alpha: 0.4), blurRadius: 2, offset: const Offset(0, 1)),
    ],
  );
}

class _Offer {
  const _Offer(this.title, this.subtitle);
  final String title;
  final String subtitle;
}

const _offers = [
  _Offer('Nouveau', 'Le Crousty Cheddar arrive en boutique'),
  _Offer('Cette semaine', 'Tajine du mercredi — 11,50 €'),
  _Offer('Fidélité', 'Double points sur les bowls ce week-end'),
];

class _OfferCard extends StatelessWidget {
  const _OfferCard({required this.offer});

  final _Offer offer;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.secondary, AppColors.orangeDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: [
          BoxShadow(color: AppColors.charcoal.withValues(alpha: 0.35), blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.badgeAmber,
              borderRadius: BorderRadius.circular(AppRadius.pill),
            ),
            child: Text(
              offer.title,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: AppColors.charcoal,
                    fontSize: 11,
                    letterSpacing: 0,
                  ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            offer.subtitle,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(color: AppColors.cream),
          ),
        ],
      ),
    );
  }
}

class _Event {
  const _Event(this.title, this.date, this.icon);
  final String title;
  final String date;
  final IconData icon;
}

const _events = [
  _Event('Atelier découpe de poulet', 'Samedi 10h', Icons.content_cut),
  _Event('Soirée dégustation', 'Vendredi 19h', Icons.local_fire_department_outlined),
];

class _EventCard extends StatelessWidget {
  const _EventCard({required this.event});

  final _Event event;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 210,
      padding: const EdgeInsets.all(14),
      decoration: _level1Decoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.orange.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(event.icon, color: AppColors.orange, size: 20),
          ),
          const SizedBox(height: 8),
          Text(event.title, style: Theme.of(context).textTheme.titleMedium, maxLines: 2, overflow: TextOverflow.ellipsis),
          Text(event.date, style: Theme.of(context).textTheme.bodySmall),
          const Spacer(),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              style: TextButton.styleFrom(minimumSize: const Size(0, 48), padding: EdgeInsets.zero),
              onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Réservation pour "${event.title}" enregistrée.')),
              ),
              child: const Text('Réserver'),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.buttonLabel,
    required this.onPressed,
  });

  final IconData icon;
  final String title;
  final String description;
  final String buttonLabel;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _level1Decoration(),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.orange.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(icon, color: AppColors.orange),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(description, style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    style: TextButton.styleFrom(minimumSize: const Size(0, 48), padding: EdgeInsets.zero),
                    onPressed: onPressed,
                    child: Text(
                      buttonLabel,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(color: AppColors.orange, letterSpacing: 0),
                    ),
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
