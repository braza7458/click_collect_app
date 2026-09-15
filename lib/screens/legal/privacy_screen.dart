import 'package:flutter/material.dart';

import '../../data/menu_data.dart';
import '../../widgets/legal_document.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return LegalDocumentScreen(
      title: 'Politique de confidentialité',
      updated: '15/09/2026',
      sections: [
        const LegalSection(
          '1. Responsable de traitement',
          '$restaurantName est responsable du traitement des données collectées via l\'Application. '
              '[Raison sociale, adresse et SIRET du responsable de traitement à compléter.]',
        ),
        const LegalSection(
          '2. Données collectées',
          'Lors de la création de compte et de l\'utilisation de l\'Application, nous collectons : prénom, '
              'adresse e-mail, date de naissance, numéro de téléphone (facultatif), mot de passe (stocké de façon '
              'sécurisée), restaurant favori, historique de commandes et solde de points fidélité.',
        ),
        const LegalSection(
          '3. Finalités',
          'Ces données sont utilisées pour créer et gérer votre compte, traiter vos commandes, faire fonctionner '
              'le programme de fidélité, vous adresser des communications si vous y avez consenti (e-mail, SMS), '
              'et améliorer nos services.',
        ),
        const LegalSection(
          '4. Base légale',
          'Le traitement repose sur l\'exécution du contrat qui vous lie à $restaurantName (gestion du compte et '
              'des commandes) et, pour les communications marketing, sur votre consentement — que vous pouvez '
              'retirer à tout moment depuis Notifications > Préférences.',
        ),
        const LegalSection(
          '5. Durée de conservation',
          'Les données de compte sont conservées pendant la durée d\'utilisation active de l\'Application, puis '
              'archivées ou supprimées conformément aux obligations légales. [Durées précises à définir.]',
        ),
        const LegalSection(
          '6. Vos droits',
          'Conformément au RGPD, vous disposez d\'un droit d\'accès, de rectification, d\'effacement, de '
              'limitation et d\'opposition sur vos données, ainsi que du droit à la portabilité. Vous pouvez '
              'exercer ces droits depuis Mon profil ou en nous contactant. Vous disposez également du droit '
              'd\'introduire une réclamation auprès de la CNIL (www.cnil.fr).',
        ),
        const LegalSection(
          '7. Stockage et sécurité',
          'À ce jour, les données de session (identifiant, points, historique de commandes) sont stockées '
              'localement sur votre appareil, sans synchronisation avec un serveur. Une fois l\'Application '
              'connectée à un backend sécurisé, elles seront hébergées et protégées conformément aux standards de '
              'sécurité en vigueur.',
        ),
        const LegalSection(
          '8. Cookies et traceurs',
          'L\'Application elle-même ne dépose pas de cookies publicitaires. Un futur site web associé pourrait '
              'faire l\'objet d\'une politique de cookies distincte.',
        ),
        const LegalSection(
          '9. Contact',
          'Pour toute question relative à vos données personnelles : [adresse e-mail dédiée à la protection des '
              'données à renseigner].',
        ),
      ],
    );
  }
}
