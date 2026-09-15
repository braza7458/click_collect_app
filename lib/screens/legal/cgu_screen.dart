import 'package:flutter/material.dart';

import '../../data/menu_data.dart';
import '../../widgets/legal_document.dart';

class CguScreen extends StatelessWidget {
  const CguScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return LegalDocumentScreen(
      title: 'Conditions Générales d\'Utilisation',
      updated: '15/09/2026',
      sections: [
        const LegalSection(
          '1. Objet',
          'Les présentes Conditions Générales d\'Utilisation (CGU) régissent l\'accès et l\'utilisation de '
              'l\'application mobile $restaurantName (« l\'Application »), qui permet de consulter la carte, de '
              'commander en Click & Collect, en livraison ou en service à table, et de gérer un programme de fidélité.',
        ),
        const LegalSection(
          '2. Création de compte',
          'L\'utilisation de certaines fonctionnalités (commande, fidélité) nécessite la création d\'un compte à '
              'partir d\'un prénom, d\'une adresse e-mail et d\'un mot de passe. L\'utilisateur s\'engage à fournir '
              'des informations exactes et à préserver la confidentialité de ses identifiants.',
        ),
        const LegalSection(
          '3. Commandes',
          'Toute commande passée via l\'Application constitue une intention d\'achat. Le règlement s\'effectue '
              'actuellement sur place, à la récupération de la commande ou à la livraison ; le paiement en ligne '
              'sera proposé ultérieurement. Le restaurant se réserve le droit d\'annuler une commande en cas '
              'd\'indisponibilité d\'un produit ou de fermeture exceptionnelle.',
        ),
        const LegalSection(
          '4. Programme de fidélité',
          'Chaque euro dépensé dans le cadre d\'une commande validée sur l\'Application crédite un point sur le '
              'compte fidélité de l\'utilisateur, sous réserve d\'être connecté à un compte (hors navigation en '
              'invité). Les points peuvent être échangés contre les récompenses affichées dans l\'Application, dans '
              'la limite des stocks disponibles. Ils n\'ont pas de valeur monétaire et ne peuvent être ni remboursés '
              'ni cédés.',
        ),
        const LegalSection(
          '5. Responsabilité',
          '$restaurantName met tout en œuvre pour assurer l\'exactitude des informations affichées (carte, prix, '
              'horaires) mais ne saurait être tenu responsable d\'une indisponibilité temporaire de l\'Application '
              'ou d\'une erreur d\'affichage manifeste.',
        ),
        const LegalSection(
          '6. Données personnelles',
          'Le traitement des données personnelles collectées via l\'Application est décrit dans notre Politique de '
              'confidentialité, accessible depuis l\'onglet Plus.',
        ),
        const LegalSection(
          '7. Droit applicable',
          'Les présentes CGU sont soumises au droit français. Tout litige relève, à défaut de résolution amiable, '
              'des juridictions compétentes.',
        ),
        const LegalSection(
          '8. Contact',
          'Pour toute question relative aux présentes CGU, contactez-nous au 01 23 45 67 89 ou à '
              '[adresse e-mail de contact à renseigner].',
        ),
      ],
    );
  }
}
