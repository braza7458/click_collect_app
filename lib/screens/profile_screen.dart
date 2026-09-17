import 'package:flutter/material.dart';

import '../state/app_state.dart';
import '../theme/app_theme.dart';

/// Accounts here carry only a pseudo and a password — nothing to edit here
/// beyond what's already changeable elsewhere (favorite restaurant, in
/// Plus). Renaming the pseudo isn't supported yet: it's also the Firebase
/// Auth sign-in key, so changing it needs re-verifying the password first —
/// a small enough feature to add later, not worth the extra surface now.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Mon profil')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (appState.isGuest)
                Container(
                  padding: const EdgeInsets.all(14),
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceAlt,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: Text(
                    'Vous naviguez en tant qu\'invité. Créez un compte (pseudo + mot de passe) pour cumuler des points.',
                    style: textTheme.bodySmall,
                  ),
                ),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.charcoalSoft,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  border: Border.all(color: AppColors.divider),
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
                          Text(appState.isGuest ? 'Invité' : appState.username, style: textTheme.titleMedium),
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
              const SizedBox(height: 16),
              Text(
                'Aucun e-mail ni numéro de téléphone n\'est associé à ce compte.',
                style: textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
