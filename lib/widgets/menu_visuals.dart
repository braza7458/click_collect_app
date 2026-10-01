import 'package:flutter/material.dart';

/// Icône d'une catégorie de la carte (clé `icon` des documents
/// `menuCategories`, partagée avec la borne).
IconData categoryIcon(String key) => switch (key) {
      'bowl' => Icons.ramen_dining_rounded,
      'addOn' => Icons.add_circle_outline_rounded,
      'side' => Icons.rice_bowl_rounded,
      'special' => Icons.local_fire_department_rounded,
      'dessert' => Icons.icecream_rounded,
      _ => Icons.outdoor_grill_rounded,
    };

/// Photo d'un plat, quand on en a une. Les autres plats s'affichent avec
/// l'icône de leur catégorie.
String? menuItemImage(String itemName, {String? categoryKey}) {
  final name = itemName.toLowerCase();
  if (categoryKey == 'chicken' && name.contains('poulet')) return 'assets/images/poulet.jpg';
  if (name.contains('cheddar') && !name.startsWith('cheddar')) return 'assets/images/tasty_cheddar.jpg';
  if (name.contains('tajine')) return 'assets/images/tajine.jpg';
  return null;
}
