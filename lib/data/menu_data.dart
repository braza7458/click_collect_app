String formatPrice(double value) => '${value.toStringAsFixed(2).replaceAll('.', ',')} €';

class MenuItemSize {
  const MenuItemSize({required this.label, required this.price});

  final String label;
  final double price;
}

class MenuItem {
  const MenuItem({
    required this.name,
    this.price,
    this.sizes = const [],
    this.note,
    this.allowsSupplements = false,
    this.isAddOn = false,
    this.isInfoOnly = false,
    this.infoLabel,
  });

  final String name;
  final double? price;
  final List<MenuItemSize> sizes;
  final String? note;

  /// Whether this item can be customized with items from "Suppléments bowls".
  final bool allowsSupplements;

  /// Whether this item is itself a bowl supplement (its price is shown as "+X €").
  final bool isAddOn;

  /// Descriptive-only items (e.g. what a barquette includes) that aren't sold on their own.
  final bool isInfoOnly;
  final String? infoLabel;

  bool get hasSizes => sizes.isNotEmpty;

  /// False only for items whose price is genuinely unknown — kept visible on
  /// the menu but not addable to the cart until a real price is confirmed.
  bool get isOrderable => !isInfoOnly && (hasSizes || price != null);

  double get startingPrice => hasSizes ? sizes.first.price : (price ?? 0);

  String get priceLabel {
    if (isInfoOnly) return infoLabel ?? 'Inclus';
    if (hasSizes) return sizes.map((s) => formatPrice(s.price)).join(' / ');
    if (price == null) return 'Prix à définir';
    return isAddOn ? '+${formatPrice(price!)}' : formatPrice(price!);
  }
}

class MenuCategory {
  const MenuCategory({
    required this.title,
    required this.items,
  });

  final String title;
  final List<MenuItem> items;
}

const restaurantName = 'Les Poulets de Mamie';
const restaurantTagline = 'Rôtisserie artisanale — Poulet Fermier Label Rouge';

const menuCategories = [
  MenuCategory(
    title: 'Poulets rôtis',
    items: [
      MenuItem(name: 'Le Poulet Rôti', price: 20.50),
      MenuItem(name: 'Le Demi-Poulet', price: 11.50),
      MenuItem(name: 'La Cuisse de Dinde', price: 21.00),
      MenuItem(name: 'Formule 1/4 de poulet + pomme de terre', price: 10.50),
    ],
  ),
  MenuCategory(
    title: 'Nos Bowls',
    items: [
      MenuItem(
        name: 'Poulet Tandoori',
        sizes: [MenuItemSize(label: 'M', price: 9.00), MenuItemSize(label: 'L', price: 10.50)],
        allowsSupplements: true,
      ),
      MenuItem(
        name: 'Curry Coco',
        sizes: [MenuItemSize(label: 'M', price: 9.00), MenuItemSize(label: 'L', price: 10.50)],
        allowsSupplements: true,
      ),
      // Prix non communiqué à ce jour — non commandable tant qu'il n'est pas confirmé.
      MenuItem(
        name: 'Crousty Cheddar',
        note: 'Taille M / L — prix à confirmer',
        allowsSupplements: true,
      ),
      MenuItem(
        name: 'Crousty Tenders',
        sizes: [MenuItemSize(label: 'M', price: 8.50), MenuItemSize(label: 'L', price: 10.00)],
        allowsSupplements: true,
      ),
    ],
  ),
  MenuCategory(
    title: 'Suppléments bowls',
    items: [
      MenuItem(name: 'Cheddar', price: 0.50, isAddOn: true),
      MenuItem(name: 'Oignons crispy', price: 0.50, isAddOn: true),
      MenuItem(name: 'Tenders', price: 1.50, isAddOn: true),
      MenuItem(name: 'Poulet mariné', price: 1.50, isAddOn: true),
    ],
  ),
  MenuCategory(
    title: 'Accompagnements',
    items: [
      MenuItem(name: 'Barquette grande', price: 5.50),
      MenuItem(name: 'Barquette petite', price: 4.00),
      MenuItem(name: 'Haricots verts & pommes de terre', isInfoOnly: true, infoLabel: 'Inclus barquette'),
      MenuItem(name: 'Frites maison', isInfoOnly: true, infoLabel: 'Inclus barquette'),
      MenuItem(name: 'Riz pilaf', isInfoOnly: true, infoLabel: 'Inclus barquette'),
    ],
  ),
  MenuCategory(
    title: 'Spéciaux de la semaine',
    items: [
      MenuItem(name: 'Couscous', price: 11.50, note: 'Vendredi uniquement'),
      MenuItem(name: 'Tajine', price: 11.50, note: 'Mercredi'),
    ],
  ),
  MenuCategory(
    title: 'Desserts & Boissons',
    items: [
      MenuItem(name: 'Tiramisu', price: 3.50),
      // Prix non communiqué à ce jour — non commandable tant qu'il n'est pas confirmé.
      MenuItem(name: 'Canette 33cl au choix', note: 'Prix à confirmer'),
    ],
  ),
];

/// The "Suppléments bowls" items, exposed flat for the bowl customization sheet.
final List<MenuItem> bowlSupplements =
    menuCategories.firstWhere((c) => c.title == 'Suppléments bowls').items;
