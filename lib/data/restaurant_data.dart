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

  Map<String, dynamic> toMap() => {
        'name': name,
        'address': address,
        'hours': hours,
        'isOpenNow': isOpenNow,
      };

  factory RestaurantLocation.fromMap(Map<String, dynamic> map) => RestaurantLocation(
        name: map['name'] as String,
        address: map['address'] as String,
        hours: map['hours'] as String,
        isOpenNow: map['isOpenNow'] as bool? ?? true,
      );
}
