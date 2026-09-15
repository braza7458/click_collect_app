import 'package:flutter/material.dart';

import '../../state/app_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/help_dialog.dart';
import '../choose_restaurant_screen.dart';
import '../legal/cgu_screen.dart';
import '../legal/privacy_screen.dart';
import '../notifications_screen.dart';
import '../order_history_screen.dart';
import '../profile_screen.dart';
import '../welcome_screen.dart';

class MoreTab extends StatelessWidget {
  const MoreTab({super.key});

  Future<void> _confirmLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Se déconnecter ?'),
        content: const Text('Vous devrez vous reconnecter pour accéder à votre compte fidélité.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.red),
            child: const Text('Se déconnecter'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      AppStateScope.of(context).logout();
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const WelcomeScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);
    final textTheme = Theme.of(context).textTheme;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      children: [
        Text('Plus', style: textTheme.headlineSmall),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.charcoalSoft,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: AppColors.divider),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.4),
                blurRadius: 2,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: AppColors.orange,
                child: Icon(Icons.person_outline, color: AppColors.charcoal, size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      appState.isGuest ? 'Invité' : appState.firstName,
                      style: textTheme.titleMedium,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      appState.isGuest ? 'Non connecté' : '${appState.points} points',
                      style: textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        _MenuTile(
          icon: Icons.person_outline,
          label: 'Mon profil',
          onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ProfileScreen())),
        ),
        const SizedBox(height: 10),
        _MenuTile(
          icon: Icons.receipt_long_outlined,
          label: 'Mes commandes',
          onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const OrderHistoryScreen())),
        ),
        const SizedBox(height: 10),
        _MenuTile(
          icon: Icons.storefront_outlined,
          label: 'Mon restaurant favori',
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const ChooseRestaurantScreen(isOnboarding: false)),
          ),
        ),
        const SizedBox(height: 10),
        _MenuTile(
          icon: Icons.notifications_outlined,
          label: appState.unreadNotificationCount > 0
              ? 'Notifications (${appState.unreadNotificationCount})'
              : 'Notifications',
          onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const NotificationsScreen())),
        ),
        const SizedBox(height: 10),
        _MenuTile(
          icon: Icons.help_outline,
          label: 'Aide',
          onTap: () => showHelpDialog(context),
        ),
        const SizedBox(height: 10),
        _MenuTile(
          icon: Icons.description_outlined,
          label: 'Conditions Générales d\'Utilisation',
          onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CguScreen())),
        ),
        const SizedBox(height: 10),
        _MenuTile(
          icon: Icons.privacy_tip_outlined,
          label: 'Politique de confidentialité',
          onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PrivacyScreen())),
        ),
        const SizedBox(height: 16),
        const Divider(height: 1),
        const SizedBox(height: 16),
        _MenuTile(
          icon: Icons.logout,
          label: 'Se déconnecter',
          destructive: true,
          onTap: () => _confirmLogout(context),
        ),
      ],
    );
  }
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({required this.icon, required this.label, this.destructive = false, this.onTap});

  final IconData icon;
  final String label;
  final bool destructive;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = destructive ? AppColors.red : AppColors.cream;
    return Material(
      color: AppColors.charcoalSoft,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        onTap: onTap ??
            () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Fonctionnalité à venir.')),
                ),
        child: Container(
          constraints: const BoxConstraints(minHeight: 56),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: AppColors.divider),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.4),
                blurRadius: 2,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.copyWith(color: color, fontWeight: FontWeight.w500),
                ),
              ),
              if (!destructive)
                const Icon(Icons.chevron_right, color: AppColors.creamMuted, size: 24),
            ],
          ),
        ),
      ),
    );
  }
}
