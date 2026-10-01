// ignore_for_file: avoid_print
// One-time seed script — pushes the restaurant's menu, locations, and
// loyalty reward tiers into Firestore so the app and the kiosk have
// something to read. Run once with:
//
//   dart run tool/seed_firestore.dart
//
// Uses the Firestore REST API directly. The security rules forbid client
// writes to the catalog, so either:
//  - pass an OAuth access token of a project owner in the FIRESTORE_TOKEN
//    environment variable (IAM-authenticated requests bypass the rules), or
//  - temporarily allow writes on menuCategories/restaurants/rewardTiers in
//    firestore.rules, run this script, then restore the rules.
//
// This is plain Dart (no Flutter, no pub packages) — it does not read
// firebase_options.dart, so update `projectId` below if the project changes.
import 'dart:convert';
import 'dart:io';

const projectId = 'les-poulets-de-mamie';
final baseUrl = 'https://firestore.googleapis.com/v1/projects/$projectId/databases/(default)/documents';

Future<void> main() async {
  final client = HttpClient();

  print('Seeding menuCategories…');
  for (var i = 0; i < _menuCategories.length; i++) {
    await _putDoc(client, 'menuCategories/cat-$i', {..._menuCategories[i], 'order': i});
  }

  print('Seeding restaurants…');
  for (var i = 0; i < _restaurants.length; i++) {
    await _putDoc(client, 'restaurants/restaurant-$i', {..._restaurants[i], 'order': i});
  }

  print('Seeding rewardTiers…');
  for (var i = 0; i < _rewardTiers.length; i++) {
    await _putDoc(client, 'rewardTiers/reward-$i', {..._rewardTiers[i], 'order': i});
  }

  print('Removing obsolete documents…');
  for (final path in _obsoleteDocs) {
    await _deleteDoc(client, path);
  }

  client.close();
  print('Done.');
}

Future<void> _putDoc(HttpClient client, String path, Map<String, dynamic> fields) async {
  final uri = Uri.parse('$baseUrl/$path');
  final request = await client.patchUrl(uri);
  _authorize(request);
  request.headers.contentType = ContentType.json;
  request.write(jsonEncode({'fields': _encodeFields(fields)}));
  final response = await request.close();
  final body = await response.transform(utf8.decoder).join();
  if (response.statusCode >= 300) {
    stderr.writeln('FAILED $path (${response.statusCode}): $body');
  } else {
    print('  OK $path');
  }
}

Future<void> _deleteDoc(HttpClient client, String path) async {
  final request = await client.deleteUrl(Uri.parse('$baseUrl/$path'));
  _authorize(request);
  final response = await request.close();
  await response.drain<void>();
  print(response.statusCode < 300 ? '  DELETED $path' : '  FAILED delete $path (${response.statusCode})');
}

void _authorize(HttpClientRequest request) {
  final token = Platform.environment['FIRESTORE_TOKEN'];
  if (token != null && token.isNotEmpty) {
    request.headers.set(HttpHeaders.authorizationHeader, 'Bearer $token');
  }
}

Map<String, dynamic> _encodeFields(Map<String, dynamic> fields) =>
    fields.map((key, value) => MapEntry(key, _encodeValue(value)));

dynamic _encodeValue(dynamic value) {
  if (value == null) return {'nullValue': null};
  if (value is String) return {'stringValue': value};
  if (value is bool) return {'booleanValue': value};
  if (value is int) return {'integerValue': value.toString()};
  if (value is double) return {'doubleValue': value};
  if (value is List) {
    return {
      'arrayValue': {
        'values': value.map(_encodeValue).toList(),
      },
    };
  }
  if (value is Map<String, dynamic>) {
    return {
      'mapValue': {'fields': _encodeFields(value)},
    };
  }
  throw ArgumentError('Unsupported type: ${value.runtimeType}');
}

// --- Seed data — mirrors what used to be hardcoded in menu_data.dart,
// restaurant_data.dart and loyalty_data.dart before both apps switched to
// reading this from Firestore. ---

final _menuCategories = [
  {
    'title': 'Poulets rôtis',
    'icon': 'chicken',
    'items': [
      {'name': 'Le Poulet Rôti', 'price': 20.50, 'sizes': [], 'note': null, 'allowsSupplements': false, 'isAddOn': false, 'isInfoOnly': false, 'infoLabel': null},
      {'name': 'Le Demi-Poulet', 'price': 11.50, 'sizes': [], 'note': null, 'allowsSupplements': false, 'isAddOn': false, 'isInfoOnly': false, 'infoLabel': null},
      {'name': 'La Cuisse de Dinde', 'price': 21.00, 'sizes': [], 'note': null, 'allowsSupplements': false, 'isAddOn': false, 'isInfoOnly': false, 'infoLabel': null},
      {'name': 'Formule 1/4 de poulet + pomme de terre', 'price': 10.50, 'sizes': [], 'note': null, 'allowsSupplements': false, 'isAddOn': false, 'isInfoOnly': false, 'infoLabel': null},
    ],
  },
  {
    'title': 'Nos Bowls',
    'icon': 'bowl',
    'items': [
      {
        'name': 'Poulet Tandoori',
        'price': null,
        'sizes': [
          {'label': 'M', 'price': 9.00},
          {'label': 'L', 'price': 10.50},
        ],
        'note': null,
        'allowsSupplements': true,
        'isAddOn': false,
        'isInfoOnly': false,
        'infoLabel': null,
      },
      {
        'name': 'Curry Coco',
        'price': null,
        'sizes': [
          {'label': 'M', 'price': 9.00},
          {'label': 'L', 'price': 10.50},
        ],
        'note': null,
        'allowsSupplements': true,
        'isAddOn': false,
        'isInfoOnly': false,
        'infoLabel': null,
      },
      {
        'name': 'Crousty Cheddar',
        'price': null,
        'sizes': [
          {'label': 'M', 'price': 8.50},
          {'label': 'L', 'price': 10.00},
        ],
        'note': null,
        'allowsSupplements': true,
        'isAddOn': false,
        'isInfoOnly': false,
        'infoLabel': null,
      },
      {
        'name': 'Crousty Tenders',
        'price': null,
        'sizes': [
          {'label': 'M', 'price': 8.50},
          {'label': 'L', 'price': 10.00},
        ],
        'note': null,
        'allowsSupplements': true,
        'isAddOn': false,
        'isInfoOnly': false,
        'infoLabel': null,
      },
    ],
  },
  {
    'title': 'Suppléments bowls',
    'icon': 'addOn',
    'items': [
      {'name': 'Cheddar', 'price': 0.50, 'sizes': [], 'note': null, 'allowsSupplements': false, 'isAddOn': true, 'isInfoOnly': false, 'infoLabel': null},
      {'name': 'Oignons crispy', 'price': 0.50, 'sizes': [], 'note': null, 'allowsSupplements': false, 'isAddOn': true, 'isInfoOnly': false, 'infoLabel': null},
      {'name': 'Tenders', 'price': 1.50, 'sizes': [], 'note': null, 'allowsSupplements': false, 'isAddOn': true, 'isInfoOnly': false, 'infoLabel': null},
      {'name': 'Poulet mariné', 'price': 1.50, 'sizes': [], 'note': null, 'allowsSupplements': false, 'isAddOn': true, 'isInfoOnly': false, 'infoLabel': null},
    ],
  },
  {
    'title': 'Accompagnements',
    'icon': 'side',
    'items': [
      {'name': 'Barquette grande', 'price': 5.50, 'sizes': [], 'note': null, 'allowsSupplements': false, 'isAddOn': false, 'isInfoOnly': false, 'infoLabel': null},
      {'name': 'Barquette petite', 'price': 4.00, 'sizes': [], 'note': null, 'allowsSupplements': false, 'isAddOn': false, 'isInfoOnly': false, 'infoLabel': null},
      {'name': 'Haricots verts & pommes de terre', 'price': null, 'sizes': [], 'note': null, 'allowsSupplements': false, 'isAddOn': false, 'isInfoOnly': true, 'infoLabel': 'Inclus barquette'},
      {'name': 'Frites maison', 'price': null, 'sizes': [], 'note': null, 'allowsSupplements': false, 'isAddOn': false, 'isInfoOnly': true, 'infoLabel': 'Inclus barquette'},
      {'name': 'Riz pilaf', 'price': null, 'sizes': [], 'note': null, 'allowsSupplements': false, 'isAddOn': false, 'isInfoOnly': true, 'infoLabel': 'Inclus barquette'},
    ],
  },
  {
    'title': 'Spéciaux de la semaine',
    'icon': 'special',
    'items': [
      {'name': 'Couscous', 'price': 11.50, 'sizes': [], 'note': 'Vendredi uniquement', 'allowsSupplements': false, 'isAddOn': false, 'isInfoOnly': false, 'infoLabel': null},
      {'name': 'Tajine', 'price': 11.50, 'sizes': [], 'note': 'Mercredi', 'allowsSupplements': false, 'isAddOn': false, 'isInfoOnly': false, 'infoLabel': null},
    ],
  },
  {
    'title': 'Desserts & Boissons',
    'icon': 'dessert',
    'items': [
      {'name': 'Tiramisu', 'price': 3.50, 'sizes': [], 'note': null, 'allowsSupplements': false, 'isAddOn': false, 'isInfoOnly': false, 'infoLabel': null},
      // Prix non communiqué à ce jour — non commandable tant qu'il n'est pas confirmé.
      {'name': 'Canette 33cl au choix', 'price': null, 'sizes': [], 'note': 'Prix à confirmer', 'allowsSupplements': false, 'isAddOn': false, 'isInfoOnly': false, 'infoLabel': null},
    ],
  },
];

// Un seul restaurant. `schedule` est la source de vérité des horaires (un
// élément par jour, `day` = DateTime.weekday : 1 = lundi … 7 = dimanche) ;
// `hours` (texte résumé) et `isOpenNow` ne restent que pour les anciennes
// versions de l'application, qui les lisaient directement.
const _lunch = {'open': '09:30', 'close': '14:30'};
const _dinner = {'open': '18:00', 'close': '21:00'};

final _restaurants = [
  {
    'name': 'Les Poulets de Mamie',
    'address': '250 Rue du Galupe, 64170 Artix',
    'phone': '07 61 85 18 31',
    'hours': 'Mer–Sam 9h30–14h30 / 18h–21h · Dim 9h30–14h30',
    'isOpenNow': true,
    'schedule': [
      {'day': 1, 'slots': []},
      {'day': 2, 'slots': []},
      {'day': 3, 'slots': [_lunch, _dinner]},
      {'day': 4, 'slots': [_lunch, _dinner]},
      {'day': 5, 'slots': [_lunch, _dinner]},
      {'day': 6, 'slots': [_lunch, _dinner]},
      {'day': 7, 'slots': [_lunch]},
    ],
  },
];

/// Documents d'anciennes versions du catalogue à supprimer (les 3 restaurants
/// fictifs d'origine, remplacés par l'unique restaurant d'Artix).
const _obsoleteDocs = ['restaurants/restaurant-1', 'restaurants/restaurant-2'];

final _rewardTiers = [
  {'points': 100, 'label': 'Un dessert offert', 'icon': 'dessert'},
  {'points': 200, 'label': 'Un bowl offert', 'icon': 'bowl'},
  {'points': 400, 'label': 'Un menu complet offert', 'icon': 'meal'},
];
