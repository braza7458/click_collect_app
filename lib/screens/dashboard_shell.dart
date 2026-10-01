import 'package:flutter/material.dart';

import '../state/app_state.dart';
import '../theme/app_theme.dart';
import 'tabs/fidelity_tab.dart';
import 'tabs/home_tab.dart';
import 'tabs/more_tab.dart';
import 'tabs/order_tab.dart';
import 'tabs/restaurant_tab.dart';

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
    final appState = AppStateScope.of(context);
    final tabs = [
      HomeTab(onNavigate: _goToTab),
      const RestaurantTab(),
      const OrderTab(),
      FidelityTab(onNavigate: _goToTab),
      const MoreTab(),
    ];

    final navTextTheme = Theme.of(context).textTheme;
    final cartCount = appState.cartItemCount;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: IndexedStack(index: _navIndex, children: tabs),
      ),
      // Barre de navigation flottante en verre fumé, détachée des bords.
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 6, 14, 10),
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.xl),
              border: Border.all(color: AppColors.glassBorder),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.45), blurRadius: 30, offset: const Offset(0, 12)),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.xl),
              child: NavigationBarTheme(
                data: NavigationBarThemeData(
                  labelTextStyle: WidgetStateProperty.resolveWith((states) {
                    final selected = states.contains(WidgetState.selected);
                    return (navTextTheme.labelSmall ?? const TextStyle(fontSize: 11)).copyWith(
                      color: selected ? AppColors.orange : AppColors.creamMuted,
                      fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                      letterSpacing: 0,
                      fontSize: 11,
                    );
                  }),
                ),
                child: NavigationBar(
                  height: 66,
                  elevation: 0,
                  surfaceTintColor: Colors.transparent,
                  backgroundColor: AppColors.glassStrong,
                  indicatorColor: AppColors.orange.withValues(alpha: 0.18),
                  indicatorShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
                  labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
                  selectedIndex: _navIndex,
                  onDestinationSelected: _goToTab,
                  destinations: [
                    const NavigationDestination(
                      icon: Icon(Icons.home_outlined, color: AppColors.creamMuted),
                      selectedIcon: Icon(Icons.home_rounded, color: AppColors.orange),
                      label: 'Pour vous',
                    ),
                    const NavigationDestination(
                      icon: Icon(Icons.storefront_outlined, color: AppColors.creamMuted),
                      selectedIcon: Icon(Icons.storefront_rounded, color: AppColors.orange),
                      label: 'Restaurant',
                    ),
                    NavigationDestination(
                      icon: Badge(
                        isLabelVisible: cartCount > 0,
                        label: Text('$cartCount'),
                        backgroundColor: AppColors.orange,
                        textColor: AppColors.charcoal,
                        child: const Icon(Icons.restaurant_menu_outlined, color: AppColors.creamMuted),
                      ),
                      selectedIcon: Badge(
                        isLabelVisible: cartCount > 0,
                        label: Text('$cartCount'),
                        backgroundColor: AppColors.honey,
                        textColor: AppColors.charcoal,
                        child: const Icon(Icons.restaurant_menu_rounded, color: AppColors.orange),
                      ),
                      label: 'Commander',
                    ),
                    const NavigationDestination(
                      icon: Icon(Icons.workspace_premium_outlined, color: AppColors.creamMuted),
                      selectedIcon: Icon(Icons.workspace_premium_rounded, color: AppColors.orange),
                      label: 'Fidélité',
                    ),
                    NavigationDestination(
                      icon: Badge(
                        isLabelVisible: appState.unreadNotificationCount > 0,
                        smallSize: 8,
                        backgroundColor: AppColors.orange,
                        child: const Icon(Icons.person_outline_rounded, color: AppColors.creamMuted),
                      ),
                      selectedIcon: const Icon(Icons.person_rounded, color: AppColors.orange),
                      label: 'Plus',
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
