import 'package:flutter/material.dart';

import '../services/contact.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import 'ui.dart';

/// Feuille "Besoin d'aide ?" : appeler le restaurant en un geste, avec les
/// horaires du jour pour savoir si quelqu'un décrochera.
Future<void> showHelpDialog(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    builder: (sheetContext) {
      final restaurant = AppStateScope.of(sheetContext).restaurant;
      final textTheme = Theme.of(sheetContext).textTheme;
      final status = restaurant.statusAt(DateTime.now());
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Eyebrow('Assistance'),
              const SizedBox(height: 6),
              Text('Besoin d\'aide ?', style: textTheme.headlineSmall),
              const SizedBox(height: 10),
              Text(
                'Une question sur votre commande ou votre compte fidélité ? Appelez-nous au '
                '${restaurant.phone}, ou passez directement au restaurant.',
                style: textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  StatusPill(
                    label: status.headline,
                    color: status.isOpen ? AppColors.green : AppColors.red,
                  ),
                  const SizedBox(width: 10),
                  Expanded(child: Text(status.detail, style: textTheme.bodySmall)),
                ],
              ),
              const SizedBox(height: 22),
              GlowButton(
                icon: Icons.call_rounded,
                label: 'Appeler le ${restaurant.phone}',
                onPressed: () => callRestaurant(sheetContext, restaurant),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.of(sheetContext).pop(),
                  child: const Text('Fermer'),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
