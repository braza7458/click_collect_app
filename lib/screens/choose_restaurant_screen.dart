import 'package:flutter/material.dart';

import '../data/restaurant_data.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/restaurant_picker_sheet.dart';
import 'loyalty_intro_screen.dart';

class ChooseRestaurantScreen extends StatefulWidget {
  /// When true (signup flow), confirming pushes the loyalty intro screen.
  /// When false (revisited from Plus > Mon restaurant favori), confirming
  /// just saves the choice and returns.
  const ChooseRestaurantScreen({super.key, this.isOnboarding = true});

  final bool isOnboarding;

  @override
  State<ChooseRestaurantScreen> createState() => _ChooseRestaurantScreenState();
}

class _ChooseRestaurantScreenState extends State<ChooseRestaurantScreen> {
  RestaurantLocation? _selected;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      if (!widget.isOnboarding) {
        final appState = AppStateScope.of(context);
        final matches = appState.restaurants.where((r) => r.name == appState.favoriteRestaurantName);
        if (matches.isNotEmpty) _selected = matches.first;
      }
    }
  }

  Future<void> _openPicker() async {
    final picked = await showRestaurantPickerSheet(context);
    if (picked != null && mounted) {
      setState(() => _selected = picked);
    }
  }

  void _confirm() {
    if (_selected == null) return;
    AppStateScope.of(context).setFavoriteRestaurant(_selected!.name);
    if (widget.isOnboarding) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const LoyaltyIntroScreen()),
      );
    } else {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Restaurant favori mis à jour.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.isOnboarding ? null : AppBar(title: const Text('Restaurant favori')),
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
                  color: AppColors.orange.withValues(alpha: 0.12),
                ),
                child: const Icon(Icons.storefront_outlined, color: AppColors.orange, size: 52),
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
                borderRadius: BorderRadius.circular(AppRadius.xl),
                onTap: _openPicker,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  decoration: BoxDecoration(
                    color: AppColors.charcoalSoft,
                    borderRadius: BorderRadius.circular(AppRadius.xl),
                    border: Border.all(color: AppColors.divider),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.4),
                        offset: const Offset(0, 1),
                        blurRadius: 2,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.star_border_rounded, color: AppColors.orange),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _selected?.name ?? 'Choisir un restaurant',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: _selected == null ? AppColors.creamMuted.withValues(alpha: 0.7) : AppColors.cream,
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                      ),
                      const Icon(Icons.chevron_right_rounded, color: AppColors.creamMuted),
                    ],
                  ),
                ),
              ),
              const Spacer(flex: 2),
              ElevatedButton(
                onPressed: _selected != null ? _confirm : null,
                child: Text(widget.isOnboarding ? 'Je valide mon restaurant' : 'Enregistrer'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
