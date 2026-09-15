class RestaurantLocation {
  const RestaurantLocation({
    required this.name,
    required this.address,
    required this.hours,
    this.isOpenNow = true,
  });

  final String name;
  final String address;
  final String hours;
  final bool isOpenNow;
}

const restaurantLocations = [
  RestaurantLocation(
    name: 'Les Poulets de Mamie — Centre Ville',
    address: '12 Rue de la République',
    hours: '11h30 - 21h30',
  ),
  RestaurantLocation(
    name: 'Les Poulets de Mamie — Val Fleuri',
    address: '48 Avenue du Val Fleuri',
    hours: '11h30 - 22h00',
  ),
  RestaurantLocation(
    name: 'Les Poulets de Mamie — Gare',
    address: '3 Place de la Gare',
    hours: '11h00 - 21h00',
    isOpenNow: false,
  ),
];
