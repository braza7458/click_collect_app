import 'package:flutter/material.dart';

import '../data/restaurant_data.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import 'loyalty_intro_screen.dart';

class ChooseRestaurantScreen extends StatefulWidget {
  const ChooseRestaurantScreen({super.key});

  @override
  State<ChooseRestaurantScreen> createState() => _ChooseRestaurantScreenState();
}

class _ChooseRestaurantScreenState extends State<ChooseRestaurantScreen> {
  RestaurantLocation? _selected;

  Future<void> _openPicker() async {
    final picked = await showModalBottomSheet<RestaurantLocation>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Choisir un restaurant', style: Theme.of(sheetContext).textTheme.headlineSmall),
              const SizedBox(height: 12),
              ...restaurantLocations.map(
                (r) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.storefront_outlined, color: AppColors.orange),
                  title: Text(r.name, style: Theme.of(sheetContext).textTheme.titleMedium),
                  subtitle: Text('${r.address} — ${r.hours}'),
                  onTap: () => Navigator.of(sheetContext).pop(r),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    if (picked != null && mounted) {
      setState(() => _selected = picked);
    }
  }

  void _confirm() {
    if (_selected == null) return;
    AppStateScope.of(context).setFavoriteRestaurant(_selected!.name);
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const LoyaltyIntroScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          child: Column(
            children: [
              const Spacer(),
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.orange.withValues(alpha: 0.15),
                ),
                child: const Icon(Icons.storefront, color: AppColors.orange, size: 56),
              ),
              const SizedBox(height: 28),
              Text('Mon restaurant favori', style: Theme.of(context).textTheme.headlineMedium, textAlign: TextAlign.center),
              const SizedBox(height: 10),
              Text(
                'Choisissez le restaurant où vous commandez le plus souvent pour un accès rapide à ses infos et ses offres.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 28),
              InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: _openPicker,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  decoration: BoxDecoration(
                    color: AppColors.charcoalSoft,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.creamMuted.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.star_border_rounded, color: AppColors.orange),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _selected?.name ?? 'Choisir un restaurant',
                          style: TextStyle(
                            color: _selected == null ? AppColors.creamMuted.withValues(alpha: 0.7) : AppColors.cream,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const Icon(Icons.chevron_right, color: AppColors.creamMuted),
                    ],
                  ),
                ),
              ),
              const Spacer(flex: 2),
              ElevatedButton(
                onPressed: _selected != null ? _confirm : null,
                child: const Text('Je valide mon restaurant'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
