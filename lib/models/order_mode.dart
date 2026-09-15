import 'package:flutter/material.dart';

enum OrderMode { clickCollect, delivery, tableService }

extension OrderModeInfo on OrderMode {
  String get label => switch (this) {
        OrderMode.clickCollect => 'Click & Collect',
        OrderMode.delivery => 'Livraison',
        OrderMode.tableService => 'Service à table',
      };

  String get description => switch (this) {
        OrderMode.clickCollect => 'Commandez et récupérez en boutique à l\'heure choisie',
        OrderMode.delivery => 'Faites-vous livrer directement chez vous',
        OrderMode.tableService => 'Scannez le QR code de votre table pour commander',
      };

  IconData get icon => switch (this) {
        OrderMode.clickCollect => Icons.storefront_outlined,
        OrderMode.delivery => Icons.delivery_dining_outlined,
        OrderMode.tableService => Icons.table_bar_outlined,
      };

  /// Label for the fulfillment field the cart asks for before checkout.
  String get fulfillmentLabel => switch (this) {
        OrderMode.clickCollect => 'Créneau de retrait',
        OrderMode.delivery => 'Adresse de livraison',
        OrderMode.tableService => 'Numéro de table',
      };
}
