import 'package:cloud_firestore/cloud_firestore.dart';

import 'loyalty_data.dart';
import 'menu_data.dart';
import 'restaurant_data.dart';

/// Reads the shared catalog from Firestore — the same `menuCategories`
/// collection the kiosk reads, plus the restaurant and loyalty reward tiers,
/// so both surfaces stay in sync without republishing the app.
class CatalogRepository {
  const CatalogRepository._();

  static Future<List<MenuCategory>> fetchMenu() async {
    final snapshot = await FirebaseFirestore.instance.collection('menuCategories').orderBy('order').get();
    return snapshot.docs.map((doc) => MenuCategory.fromMap(doc.data())).toList();
  }

  /// L'enseigne n'a qu'un restaurant : on prend le premier document au
  /// format actuel (avec `schedule`), sinon la valeur intégrée à l'app.
  static Future<RestaurantLocation> fetchRestaurant() async {
    final snapshot = await FirebaseFirestore.instance.collection('restaurants').orderBy('order').get();
    for (final doc in snapshot.docs) {
      final restaurant = RestaurantLocation.fromMap(doc.data());
      if (restaurant != null) return restaurant;
    }
    return RestaurantLocation.artix;
  }

  static Future<List<RewardTier>> fetchRewardTiers() async {
    final snapshot = await FirebaseFirestore.instance.collection('rewardTiers').orderBy('order').get();
    return snapshot.docs.map((doc) => RewardTier.fromMap(doc.data())).toList();
  }
}
