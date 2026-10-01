import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/restaurant_data.dart';

Future<void> _open(BuildContext context, Uri uri, String failure) async {
  var opened = false;
  try {
    opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
  } catch (_) {}
  if (!opened && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(failure)));
  }
}

/// Ouvre le composeur téléphonique sur le numéro du restaurant.
Future<void> callRestaurant(BuildContext context, RestaurantLocation restaurant) {
  final phone = (restaurant.phone ?? RestaurantLocation.artix.phone!).replaceAll(' ', '');
  return _open(context, Uri(scheme: 'tel', path: phone), 'Impossible de lancer l\'appel — composez le ${restaurant.phone}.');
}

/// Ouvre l'itinéraire vers le restaurant dans Google Maps (ou l'app de plans).
Future<void> openItinerary(BuildContext context, RestaurantLocation restaurant) {
  final query = Uri.encodeComponent('${restaurant.name} ${restaurant.address}');
  return _open(
    context,
    Uri.parse('https://www.google.com/maps/search/?api=1&query=$query'),
    'Impossible d\'ouvrir le plan.',
  );
}
