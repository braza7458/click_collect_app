import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class LegalSection {
  const LegalSection(this.heading, this.body);
  final String heading;
  final String body;
}

/// Renders a static legal document (CGU, politique de confidentialité…).
///
/// These are drafted as reasonable, complete templates for this app's
/// current feature set, not as legal advice — the banner at the top says so
/// and should stay until a lawyer has reviewed the final text.
class LegalDocumentScreen extends StatelessWidget {
  const LegalDocumentScreen({
    super.key,
    required this.title,
    required this.updated,
    required this.sections,
  });

  final String title;
  final String updated;
  final List<LegalSection> sections;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: AppColors.surfaceAlt,
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: const Border(left: BorderSide(color: AppColors.badgeAmber, width: 3)),
              ),
              child: Text(
                'Modèle à faire valider par un professionnel du droit avant publication. '
                'Dernière mise à jour : $updated.',
                style: textTheme.bodySmall,
              ),
            ),
            for (final section in sections) ...[
              Text(section.heading, style: textTheme.titleMedium),
              const SizedBox(height: 6),
              Text(section.body, style: textTheme.bodyMedium),
              const SizedBox(height: 20),
            ],
          ],
        ),
      ),
    );
  }
}
