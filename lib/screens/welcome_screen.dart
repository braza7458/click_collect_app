import 'package:flutter/material.dart';

import '../data/menu_data.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import 'dashboard_shell.dart';
import 'login_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/menu.jpeg',
            fit: BoxFit.cover,
            alignment: Alignment.topCenter,
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.charcoal.withValues(alpha: 0.45),
                  AppColors.charcoal.withValues(alpha: 0.85),
                  AppColors.charcoal,
                ],
                stops: const [0.0, 0.55, 1.0],
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
              child: Column(
                children: [
                  const Spacer(flex: 3),
                  Container(
                    width: 104,
                    height: 104,
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.charcoalSoft,
                      border: Border.all(color: AppColors.orange, width: 2.5),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.charcoal.withValues(alpha: 0.4),
                          blurRadius: 24,
                          offset: const Offset(0, 10),
                        ),
                        BoxShadow(
                          color: AppColors.orangeDark.withValues(alpha: 0.22),
                          blurRadius: 20,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: const ClipOval(
                      child: Image(
                        image: AssetImage('assets/images/logo.jpg'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  Text(
                    'Bienvenue chez\n$restaurantName',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    restaurantTagline,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontStyle: FontStyle.italic,
                        ),
                  ),
                  const Spacer(flex: 4),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                    ),
                    child: const Text('Connexion / Inscription'),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () {
                      AppStateScope.of(context).continueAsGuest();
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (_) => const DashboardShell()),
                        (route) => false,
                      );
                    },
                    child: const Text('Continuer en tant qu\'invité'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
