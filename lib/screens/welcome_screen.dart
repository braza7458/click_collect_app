import 'package:flutter/material.dart';

import '../data/menu_data.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/ui.dart';
import 'dashboard_shell.dart';
import 'login_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // La photo nette en haut, qui se fond dans le fond flouté.
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: MediaQuery.sizeOf(context).height * 0.66,
            child: ShaderMask(
              shaderCallback: (rect) => const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.black, Colors.black, Colors.transparent],
                stops: [0, 0.55, 1],
              ).createShader(rect),
              blendMode: BlendMode.dstIn,
              child: Image.asset('assets/images/fond.jpg', fit: BoxFit.cover, alignment: const Alignment(0, 0.2)),
            ),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.charcoal.withValues(alpha: 0.55),
                  AppColors.charcoal.withValues(alpha: 0.05),
                  AppColors.charcoal.withValues(alpha: 0.75),
                  AppColors.charcoal,
                ],
                stops: const [0, 0.25, 0.6, 1],
              ),
            ),
          ),
          SafeArea(
            // SliverFillRemaining : le contenu tient l'écran (Spacer) et
            // défile quand même sur les petits téléphones.
            child: CustomScrollView(
              slivers: [
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const FadeSlideIn(child: BrandSeal(size: 64)),
                        const Spacer(),
                        const FadeSlideIn(
                          index: 1,
                          child: Eyebrow('Rôtisserie artisanale · Artix', color: AppColors.honey),
                        ),
                        const SizedBox(height: 12),
                        FadeSlideIn(
                          index: 2,
                          child: Text(
                            'Bienvenue chez\n$restaurantName',
                            style: textTheme.displaySmall?.copyWith(fontSize: 40, height: 1.05, letterSpacing: -0.5),
                          ),
                        ),
                        const SizedBox(height: 14),
                        FadeSlideIn(
                          index: 3,
                          child: Text(
                            'Poulet fermier Label Rouge rôti à la broche, bowls généreux et plats du jour — '
                            'commandez, on s\'occupe du reste.',
                            style: textTheme.bodyLarge?.copyWith(color: AppColors.creamMuted),
                          ),
                        ),
                        const SizedBox(height: 18),
                        const FadeSlideIn(
                          index: 4,
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              StatusPill(
                                label: 'Label Rouge',
                                color: AppColors.honey,
                                icon: Icons.workspace_premium_rounded,
                              ),
                              StatusPill(
                                label: 'Click & Collect',
                                color: AppColors.orange,
                                icon: Icons.shopping_bag_rounded,
                              ),
                              StatusPill(label: 'Fidélité', color: AppColors.green, icon: Icons.favorite_rounded),
                            ],
                          ),
                        ),
                        const SizedBox(height: 28),
                        FadeSlideIn(
                          index: 5,
                          child: GlowButton(
                            label: 'Connexion / Inscription',
                            onPressed: () =>
                                Navigator.of(context).push(MaterialPageRoute(builder: (_) => const LoginScreen())),
                          ),
                        ),
                        const SizedBox(height: 6),
                        FadeSlideIn(
                          index: 6,
                          child: Center(
                            child: TextButton(
                              style: TextButton.styleFrom(foregroundColor: AppColors.cream),
                              onPressed: () {
                                AppStateScope.of(context).continueAsGuest();
                                Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute(builder: (_) => const DashboardShell()),
                                  (route) => false,
                                );
                              },
                              child: const Text('Continuer en tant qu\'invité'),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
