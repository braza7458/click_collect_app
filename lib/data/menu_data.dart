class MenuItem {
  const MenuItem({
    required this.name,
    required this.price,
    this.note,
  });

  final String name;
  final String price;
  final String? note;
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
      MenuItem(name: 'Le Poulet Rôti', price: '20,50 €'),
      MenuItem(name: 'Le Demi-Poulet', price: '11,50 €'),
      MenuItem(name: 'La Cuisse de Dinde', price: '21,00 €'),
      MenuItem(
        name: 'Formule 1/4 de poulet + pomme de terre',
        price: '10,50 €',
      ),
    ],
  ),
  MenuCategory(
    title: 'Nos Bowls',
    items: [
      MenuItem(name: 'Poulet Tandoori', price: '9,00 € / 10,50 €', note: 'Taille M / L'),
      MenuItem(name: 'Curry Coco', price: '9,00 € / 10,50 €', note: 'Taille M / L'),
      MenuItem(name: 'Crousty Cheddar', price: 'Prix à confirmer', note: 'Taille M / L'),
      MenuItem(name: 'Crousty Tenders', price: '8,50 € / 10,00 €', note: 'Taille M / L'),
    ],
  ),
  MenuCategory(
    title: 'Suppléments bowls',
    items: [
      MenuItem(name: 'Cheddar', price: '+0,50 €'),
      MenuItem(name: 'Oignons crispy', price: '+0,50 €'),
      MenuItem(name: 'Tenders', price: '+1,50 €'),
      MenuItem(name: 'Poulet mariné', price: '+1,50 €'),
    ],
  ),
  MenuCategory(
    title: 'Accompagnements',
    items: [
      MenuItem(name: 'Barquette grande', price: '5,50 €'),
      MenuItem(name: 'Barquette petite', price: '4,00 €'),
      MenuItem(name: 'Haricots verts & pommes de terre', price: 'Inclus barquette'),
      MenuItem(name: 'Frites maison', price: 'Inclus barquette'),
      MenuItem(name: 'Riz pilaf', price: 'Inclus barquette'),
    ],
  ),
  MenuCategory(
    title: 'Spéciaux de la semaine',
    items: [
      MenuItem(name: 'Couscous', price: '11,50 €', note: 'Vendredi uniquement'),
      MenuItem(name: 'Tajine', price: '11,50 €', note: 'Mercredi'),
    ],
  ),
  MenuCategory(
    title: 'Desserts & Boissons',
    items: [
      MenuItem(name: 'Tiramisu', price: '3,50 €'),
      MenuItem(name: 'Canette 33cl au choix', price: 'Prix à confirmer'),
    ],
  ),
];
