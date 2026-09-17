import 'package:cloud_firestore/cloud_firestore.dart';

import 'loyalty_data.dart';
import 'menu_data.dart';
import 'restaurant_data.dart';

/// Reads the shared catalog from Firestore — the same `menuCategories`
/// collection the kiosk reads, plus the restaurant list and loyalty reward
/// tiers, so both surfaces (and, eventually, whoever edits the menu) stay in
/// sync without republishing the app.
class CatalogRepository {
  const CatalogRepository._();

  static Future<List<MenuCategory>> fetchMenu() async {
    final snapshot = await FirebaseFirestore.instance.collection('menuCategories').orderBy('order').get();
    return snapshot.docs.map((doc) => MenuCategory.fromMap(doc.data())).toList();
  }

  static Future<List<RestaurantLocation>> fetchRestaurants() async {
    final snapshot = await FirebaseFirestore.instance.collection('restaurants').orderBy('order').get();
    return snapshot.docs.map((doc) => RestaurantLocation.fromMap(doc.data())).toList();
  }

  static Future<List<RewardTier>> fetchRewardTiers() async {
    final snapshot = await FirebaseFirestore.instance.collection('rewardTiers').orderBy('order').get();
    return snapshot.docs.map((doc) => RewardTier.fromMap(doc.data())).toList();
  }
}
