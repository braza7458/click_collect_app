import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'tabs/fidelity_tab.dart';
import 'tabs/home_tab.dart';
import 'tabs/more_tab.dart';
import 'tabs/order_tab.dart';
import 'tabs/restaurants_tab.dart';

class DashboardShell extends StatefulWidget {
  const DashboardShell({super.key});

  @override
  State<DashboardShell> createState() => _DashboardShellState();
}

class _DashboardShellState extends State<DashboardShell> {
  int _navIndex = 0;

  void _goToTab(int index) => setState(() => _navIndex = index);

  @override
  Widget build(BuildContext context) {
    final tabs = [
      HomeTab(onNavigate: _goToTab),
      const RestaurantsTab(),
      const OrderTab(),
      const FidelityTab(),
      const MoreTab(),
    ];

    final navTextTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: IndexedStack(index: _navIndex, children: tabs),
      ),
      bottomNavigationBar: DecoratedBox(
        // Hairline top border instead of a heavy Material shadow — the
        // "elevation from borders, not fills" language of the design system.
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppColors.divider, width: 1)),
        ),
        child: NavigationBarTheme(
          data: NavigationBarThemeData(
            labelTextStyle: WidgetStateProperty.resolveWith((states) {
              final base = navTextTheme.labelSmall ?? const TextStyle(fontSize: 12);
              return base.copyWith(
                color: states.contains(WidgetState.selected) ? AppColors.orange : AppColors.creamMuted,
                fontWeight: states.contains(WidgetState.selected) ? FontWeight.w600 : FontWeight.w500,
              );
            }),
          ),
          child: NavigationBar(
            height: 68,
            elevation: 0,
            surfaceTintColor: Colors.transparent,
            backgroundColor: AppColors.charcoalSoft,
            // Filled icon + gold tint marks the selected tab; the soft gold
            // indicator pill sits behind it at low opacity (never a hard fill).
            indicatorColor: AppColors.orange.withValues(alpha: 0.16),
            indicatorShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.pill)),
            selectedIndex: _navIndex,
            onDestinationSelected: _goToTab,
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.storefront_outlined, color: AppColors.creamMuted),
                selectedIcon: Icon(Icons.storefront, color: AppColors.orange),
                label: 'Pour vous',
              ),
              NavigationDestination(
                icon: Icon(Icons.place_outlined, color: AppColors.creamMuted),
                selectedIcon: Icon(Icons.place, color: AppColors.orange),
                label: 'Restaurants',
              ),
              NavigationDestination(
                icon: Icon(Icons.restaurant_menu_outlined, color: AppColors.creamMuted),
                selectedIcon: Icon(Icons.restaurant_menu, color: AppColors.orange),
                label: 'Commander',
              ),
              NavigationDestination(
                icon: Icon(Icons.loyalty_outlined, color: AppColors.creamMuted),
                selectedIcon: Icon(Icons.loyalty, color: AppColors.orange),
                label: 'Fidélité',
              ),
              NavigationDestination(
                icon: Icon(Icons.menu_outlined, color: AppColors.creamMuted),
                selectedIcon: Icon(Icons.menu, color: AppColors.orange),
                label: 'Plus',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
