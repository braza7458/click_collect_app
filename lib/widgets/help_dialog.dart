import 'package:flutter/material.dart';

Future<void> showHelpDialog(BuildContext context) {
  return showDialog(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Besoin d\'aide ?'),
      content: const Text(
        'Contactez-nous au 01 23 45 67 89 ou directement en boutique. Notre équipe vous répond du mardi au dimanche.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(),
          child: const Text('Fermer'),
        ),
      ],
    ),
  );
}
