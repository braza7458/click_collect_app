import 'package:flutter/material.dart';

/// [clickCollect], [delivery], [tableService] : les modes proposés dans
/// l'application ([appModes]). [dineIn] / [takeaway] : les modes de la
/// borne — une commande passée sur la borne avec son compte fidélité
/// apparaît aussi dans "Mes commandes".
enum OrderMode {
  clickCollect,
  delivery,
  tableService,
  dineIn,
  takeaway;

  /// Les modes qu'on peut choisir dans le panier de l'application.
  static const appModes = [clickCollect, delivery, tableService];
}

extension OrderModeInfo on OrderMode {
  String get label => switch (this) {
        OrderMode.clickCollect => 'Click & Collect',
        OrderMode.delivery => 'Livraison',
        OrderMode.tableService => 'Service à table',
        OrderMode.dineIn => 'Sur place (borne)',
        OrderMode.takeaway => 'À emporter (borne)',
      };

  String get description => switch (this) {
        OrderMode.clickCollect => 'Commandez et récupérez en boutique à l\'heure choisie',
        OrderMode.delivery => 'Faites-vous livrer directement chez vous',
        OrderMode.tableService => 'Scannez le QR code de votre table pour commander',
        OrderMode.dineIn => 'Commandé sur la borne, à manger sur place',
        OrderMode.takeaway => 'Commandé sur la borne, à emporter',
      };

  IconData get icon => switch (this) {
        OrderMode.clickCollect => Icons.storefront_outlined,
        OrderMode.delivery => Icons.delivery_dining_outlined,
        OrderMode.tableService => Icons.table_bar_outlined,
        OrderMode.dineIn => Icons.restaurant_outlined,
        OrderMode.takeaway => Icons.shopping_bag_outlined,
      };

  /// Label for the fulfillment field the cart asks for before checkout.
  String get fulfillmentLabel => switch (this) {
        OrderMode.clickCollect => 'Créneau de retrait',
        OrderMode.delivery => 'Adresse de livraison',
        OrderMode.tableService => 'Numéro de table',
        OrderMode.dineIn || OrderMode.takeaway => 'Borne',
      };
}
