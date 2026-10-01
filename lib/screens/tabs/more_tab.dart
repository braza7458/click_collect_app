import 'package:flutter/material.dart';

import '../../services/contact.dart';
import '../../state/app_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/help_dialog.dart';
import '../../widgets/ui.dart';
import '../legal/cgu_screen.dart';
import '../legal/privacy_screen.dart';
import '../login_screen.dart';
import '../notifications_screen.dart';
import '../order_history_screen.dart';
import '../profile_screen.dart';
import '../welcome_screen.dart';

class MoreTab extends StatelessWidget {
  const MoreTab({super.key});

  Future<void> _confirmLogout(BuildContext context, bool isGuest) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(isGuest ? 'Quitter le mode invité ?' : 'Se déconnecter ?'),
        content: Text(
          isGuest
              ? 'Votre panier sera vidé.'
              : 'Vous devrez vous reconnecter pour accéder à votre compte fidélité.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(false), child: const Text('Annuler')),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.red),
            child: Text(isGuest ? 'Quitter' : 'Se déconnecter'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      await AppStateScope.of(context).logout();
      if (!context.mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const WelcomeScreen()),
        (route) => false,
      );
    }
  }

  void _push(BuildContext context, Widget screen) =>
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);
    final textTheme = Theme.of(context).textTheme;
    final unread = appState.unreadNotificationCount;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
      children: [
        FadeSlideIn(child: Text('Mon espace', style: textTheme.headlineMedium)),
        const SizedBox(height: 18),
        FadeSlideIn(
          index: 1,
          child: GlassCard(
            onTap: appState.isGuest ? () => _push(context, const LoginScreen()) : () => _push(context, const ProfileScreen()),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(colors: [AppColors.honey, AppColors.orange]),
                  ),
                  child: Text(
                    appState.isGuest ? '?' : appState.username.characters.first.toUpperCase(),
                    style: textTheme.headlineSmall?.copyWith(color: AppColors.charcoal),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(appState.isGuest ? 'Invité' : appState.username, style: textTheme.titleLarge),
                      const SizedBox(height: 2),
                      Text(
                        appState.isGuest ? 'Connectez-vous pour cumuler des points' : '${appState.points} points fidélité',
                        style: textTheme.bodySmall?.copyWith(color: appState.isGuest ? AppColors.creamMuted : AppColors.honey),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: AppColors.creamMuted),
              ],
            ),
          ),
        ),
        const SizedBox(height: 22),
        const FadeSlideIn(index: 2, child: Eyebrow('Mon compte')),
        const SizedBox(height: 10),
        FadeSlideIn(
          index: 3,
          child: _MenuGroup(
            children: [
              _MenuTile(
                icon: Icons.receipt_long_rounded,
                label: 'Mes commandes',
                onTap: () => _push(context, const OrderHistoryScreen()),
              ),
              _MenuTile(
                icon: Icons.notifications_rounded,
                label: 'Notifications',
                trailing: unread > 0
                    ? Badge(label: Text('$unread'), backgroundColor: AppColors.orange, textColor: AppColors.charcoal)
                    : null,
                onTap: () => _push(context, const NotificationsScreen()),
              ),
              if (!appState.isGuest)
                _MenuTile(
                  icon: Icons.person_rounded,
                  label: 'Mon profil',
                  onTap: () => _push(context, const ProfileScreen()),
                ),
            ],
          ),
        ),
        const SizedBox(height: 22),
        const FadeSlideIn(index: 4, child: Eyebrow('Le restaurant')),
        const SizedBox(height: 10),
        FadeSlideIn(
          index: 5,
          child: _MenuGroup(
            children: [
              _MenuTile(
                icon: Icons.call_rounded,
                label: 'Appeler le restaurant',
                subtitle: appState.restaurant.phone,
                onTap: () => callRestaurant(context, appState.restaurant),
              ),
              _MenuTile(icon: Icons.support_agent_rounded, label: 'Aide', onTap: () => showHelpDialog(context)),
            ],
          ),
        ),
        const SizedBox(height: 22),
        const FadeSlideIn(index: 6, child: Eyebrow('Informations')),
        const SizedBox(height: 10),
        FadeSlideIn(
          index: 7,
          child: _MenuGroup(
            children: [
              _MenuTile(
                icon: Icons.description_rounded,
                label: 'Conditions Générales d\'Utilisation',
                onTap: () => _push(context, const CguScreen()),
              ),
              _MenuTile(
                icon: Icons.privacy_tip_rounded,
                label: 'Politique de confidentialité',
                onTap: () => _push(context, const PrivacyScreen()),
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),
        FadeSlideIn(
          index: 8,
          child: _MenuGroup(
            children: [
              _MenuTile(
                icon: Icons.logout_rounded,
                label: appState.isGuest ? 'Quitter le mode invité' : 'Se déconnecter',
                destructive: true,
                onTap: () => _confirmLogout(context, appState.isGuest),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MenuGroup extends StatelessWidget {
  const _MenuGroup({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0) const Divider(indent: 64),
            children[i],
          ],
        ],
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.subtitle,
    this.trailing,
    this.destructive = false,
  });

  final IconData icon;
  final String label;
  final String? subtitle;
  final Widget? trailing;
  final bool destructive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final color = destructive ? AppColors.red : AppColors.orange;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            IconBadge(icon, color: color, size: 36),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: textTheme.bodyLarge?.copyWith(
                      color: destructive ? AppColors.red : AppColors.cream,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (subtitle != null) Text(subtitle!, style: textTheme.bodySmall),
                ],
              ),
            ),
            ?trailing,
            if (!destructive) ...[
              const SizedBox(width: 6),
              const Icon(Icons.chevron_right_rounded, color: AppColors.creamMuted),
            ],
          ],
        ),
      ),
    );
  }
}
