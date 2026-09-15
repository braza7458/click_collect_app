import 'package:flutter/material.dart';

import '../../data/restaurant_data.dart';
import '../../theme/app_theme.dart';

class RestaurantsTab extends StatelessWidget {
  const RestaurantsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      itemCount: restaurantLocations.length + 1,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, i) {
        if (i == 0) {
          return Text('Nos restaurants', style: Theme.of(context).textTheme.headlineSmall);
        }
        final restaurant = restaurantLocations[i - 1];
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.charcoalSoft,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(child: Text(restaurant.name, style: Theme.of(context).textTheme.titleMedium)),
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: restaurant.isOpenNow ? AppColors.green : AppColors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        restaurant.isOpenNow ? 'Ouvert' : 'Fermé',
                        style: TextStyle(
                          color: restaurant.isOpenNow ? AppColors.green : AppColors.red,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.location_on_outlined, size: 16, color: AppColors.creamMuted),
                  const SizedBox(width: 6),
                  Expanded(child: Text(restaurant.address, style: Theme.of(context).textTheme.bodySmall)),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.schedule_outlined, size: 16, color: AppColors.creamMuted),
                  const SizedBox(width: 6),
                  Text(restaurant.hours, style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerLeft,
                child: OutlinedButton.icon(
                  onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Fonctionnalité à venir.')),
                  ),
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
