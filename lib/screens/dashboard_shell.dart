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

    return Scaffold(
      body: SafeArea(
        child: IndexedStack(index: _navIndex, children: tabs),
      ),
      bottomNavigationBar: NavigationBar(
        backgroundColor: AppColors.charcoalSoft,
        indicatorColor: AppColors.orange.withValues(alpha: 0.22),
        selectedIndex: _navIndex,
        onDestinationSelected: _goToTab,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.storefront_outlined), selectedIcon: Icon(Icons.storefront), label: 'Pour vous'),
          NavigationDestination(icon: Icon(Icons.place_outlined), selectedIcon: Icon(Icons.place), label: 'Restaurants'),
          NavigationDestination(icon: Icon(Icons.restaurant_menu_outlined), selectedIcon: Icon(Icons.restaurant_menu), label: 'Commander'),
          NavigationDestination(icon: Icon(Icons.loyalty_outlined), selectedIcon: Icon(Icons.loyalty), label: 'Fidélité'),
          NavigationDestination(icon: Icon(Icons.menu_outlined), selectedIcon: Icon(Icons.menu), label: 'Plus'),
        ],
      ),
    );
  }
}
