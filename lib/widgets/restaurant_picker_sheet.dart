import 'package:flutter/material.dart';

import '../data/restaurant_data.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';

Future<RestaurantLocation?> showRestaurantPickerSheet(BuildContext context) {
  return showModalBottomSheet<RestaurantLocation>(
    context: context,
    isScrollControlled: true,
    builder: (sheetContext) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'CHOISIR UN RESTAURANT',
                    style: Theme.of(sheetContext).textTheme.titleMedium?.copyWith(letterSpacing: 0.4),
                  ),
                ),
                SizedBox(
                  width: 44,
                  height: 44,
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    icon: const Icon(Icons.close_rounded, color: AppColors.cream),
                    tooltip: 'Fermer',
                    onPressed: () => Navigator.of(sheetContext).pop(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...AppStateScope.of(sheetContext).restaurants.map(
              (r) => ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(
                  Icons.storefront_outlined,
                  color: r.isOpenNow ? AppColors.orange : AppColors.creamMuted.withValues(alpha: 0.4),
                ),
                title: Text(r.name, style: Theme.of(sheetContext).textTheme.titleMedium),
                subtitle: Text(
                  '${r.address} — ${r.hours}${r.isOpenNow ? '' : ' · Fermé actuellement'}',
                  style: Theme.of(sheetContext).textTheme.bodySmall,
                ),
                onTap: () => Navigator.of(sheetContext).pop(r),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
