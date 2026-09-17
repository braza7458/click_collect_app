// ignore_for_file: avoid_print
// One-time seed script — pushes the restaurant's menu, locations, and
// loyalty reward tiers into Firestore so the app and the kiosk have
// something to read. Run once with:
//
//   dart run tool/seed_firestore.dart
//
// Uses the Firestore REST API directly with no auth, which only works while
// the database is in "test mode" (temporary, open rules) — exactly the
// state it's in right after being created from the Firebase console. Once
// real security rules are in place, this script needs re-authenticated
// requests, or should be deleted.
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

  client.close();
  print('Done.');
}

Future<void> _putDoc(HttpClient client, String path, Map<String, dynamic> fields) async {
  final uri = Uri.parse('$baseUrl/$path');
  final request = await client.patchUrl(uri);
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
        // Prix non communiqué à ce jour — non commandable tant qu'il n'est pas confirmé.
        'name': 'Crousty Cheddar',
        'price': null,
        'sizes': [],
        'note': 'Taille M / L — prix à confirmer',
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

final _restaurants = [
  {'name': 'Les Poulets de Mamie — Centre Ville', 'address': '12 Rue de la République', 'hours': '11h30 - 21h30', 'isOpenNow': true},
  {'name': 'Les Poulets de Mamie — Val Fleuri', 'address': '48 Avenue du Val Fleuri', 'hours': '11h30 - 22h00', 'isOpenNow': true},
  {'name': 'Les Poulets de Mamie — Gare', 'address': '3 Place de la Gare', 'hours': '11h00 - 21h00', 'isOpenNow': false},
];

final _rewardTiers = [
  {'points': 100, 'label': 'Un dessert offert', 'icon': 'dessert'},
  {'points': 200, 'label': 'Un bowl offert', 'icon': 'bowl'},
  {'points': 400, 'label': 'Un menu complet offert', 'icon': 'meal'},
];
