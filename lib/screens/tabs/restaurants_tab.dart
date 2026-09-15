import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../data/restaurant_data.dart';
import '../../theme/app_theme.dart';

Future<void> _openItinerary(BuildContext context, RestaurantLocation restaurant) async {
  final query = Uri.encodeComponent('${restaurant.name} ${restaurant.address}');
  final uri = Uri.parse('https://www.google.com/maps/search/?api=1&query=$query');
  final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
  if (!opened && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Impossible d\'ouvrir le plan.')),
    );
  }
}

class RestaurantsTab extends StatelessWidget {
  const RestaurantsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      itemCount: restaurantLocations.length + 1,
      separatorBuilder: (_, _) => const SizedBox(height: 16),
      itemBuilder: (context, i) {
        if (i == 0) {
          return Text('Nos restaurants', style: textTheme.headlineSmall);
        }
        final restaurant = restaurantLocations[i - 1];
        final statusColor = restaurant.isOpenNow ? AppColors.green : AppColors.red;
        return Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.charcoalSoft,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: AppColors.divider),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.4),
                blurRadius: 2,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(child: Text(restaurant.name, style: textTheme.titleMedium)),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 7,
                          height: 7,
                          decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          restaurant.isOpenNow ? 'Ouvert' : 'Fermé',
                          style: textTheme.labelSmall?.copyWith(
                            color: statusColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.location_on_outlined, size: 16, color: AppColors.creamMuted),
                  const SizedBox(width: 6),
                  Expanded(child: Text(restaurant.address, style: textTheme.bodySmall)),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.schedule_outlined, size: 16, color: AppColors.creamMuted),
                  const SizedBox(width: 6),
                  Text(restaurant.hours, style: textTheme.bodySmall),
                ],
              ),
              const SizedBox(height: 14),
              Align(
                alignment: Alignment.centerLeft,
                child: OutlinedButton.icon(
                  onPressed: () => _openItinerary(context, restaurant),
                  icon: const Icon(Icons.directions_outlined, size: 18),
                  label: const Text('Itinéraire'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
