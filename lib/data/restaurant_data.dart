/// Un créneau d'ouverture dans une journée, en minutes depuis minuit.
class OpeningSlot {
  const OpeningSlot(this.openMinute, this.closeMinute);

  final int openMinute;
  final int closeMinute;

  bool contains(int minuteOfDay) => minuteOfDay >= openMinute && minuteOfDay < closeMinute;

  String get label => '${formatMinute(openMinute)} – ${formatMinute(closeMinute)}';

  Map<String, dynamic> toMap() => {'open': _toHhMm(openMinute), 'close': _toHhMm(closeMinute)};

  factory OpeningSlot.fromMap(Map<String, dynamic> map) =>
      OpeningSlot(_parseHhMm(map['open'] as String), _parseHhMm(map['close'] as String));
}

int _parseHhMm(String raw) {
  final parts = raw.split(':');
  return int.parse(parts[0]) * 60 + int.parse(parts[1]);
}

String _toHhMm(int minutes) =>
    '${(minutes ~/ 60).toString().padLeft(2, '0')}:${(minutes % 60).toString().padLeft(2, '0')}';

/// "9h30", "18h", "14h30" — la façon dont on écrit les horaires en France.
String formatMinute(int minutes) {
  final h = minutes ~/ 60;
  final m = minutes % 60;
  return m == 0 ? '${h}h' : '${h}h${m.toString().padLeft(2, '0')}';
}

const weekdayNames = ['Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi', 'Dimanche'];

/// Où en est le restaurant à un instant donné — calculé à partir de
/// l'emploi du temps, jamais stocké.
class OpeningStatus {
  const OpeningStatus({required this.isOpen, required this.headline, required this.detail});

  final bool isOpen;

  /// "Ouvert" / "Fermé" / "Ferme bientôt".
  final String headline;

  /// "jusqu'à 14h30" / "ouvre mercredi à 9h30".
  final String detail;
}

class RestaurantLocation {
  const RestaurantLocation({
    required this.name,
    required this.address,
    required this.schedule,
    this.phone,
  });

  final String name;
  final String address;
  final String? phone;

  /// Index 0 = lundi … 6 = dimanche (soit `DateTime.weekday - 1`). Une liste
  /// vide = fermé ce jour-là.
  final List<List<OpeningSlot>> schedule;

  /// Le seul restaurant de l'enseigne — sert aussi de valeur par défaut si
  /// Firestore n'est pas joignable ou pas encore à jour.
  static const artix = RestaurantLocation(
    name: 'Les Poulets de Mamie',
    address: '250 Rue du Galupe, 64170 Artix',
    phone: '07 61 85 18 31',
    schedule: [
      [],
      [],
      [OpeningSlot(570, 870), OpeningSlot(1080, 1260)],
      [OpeningSlot(570, 870), OpeningSlot(1080, 1260)],
      [OpeningSlot(570, 870), OpeningSlot(1080, 1260)],
      [OpeningSlot(570, 870), OpeningSlot(1080, 1260)],
      [OpeningSlot(570, 870)],
    ],
  );

  List<OpeningSlot> slotsFor(DateTime day) => schedule[day.weekday - 1];

  bool isOpenAt(DateTime t) => slotsFor(t).any((s) => s.contains(t.hour * 60 + t.minute));

  bool get isOpenNow => isOpenAt(DateTime.now());

  /// Résumé d'un jour : "9h30 – 14h30 · 18h – 21h" ou "Fermé".
  String hoursLabelFor(int weekdayIndex) {
    final slots = schedule[weekdayIndex];
    return slots.isEmpty ? 'Fermé' : slots.map((s) => s.label).join('  ·  ');
  }

  String get todayHoursLabel => hoursLabelFor(DateTime.now().weekday - 1);

  OpeningStatus statusAt(DateTime now) {
    final minute = now.hour * 60 + now.minute;
    for (final slot in slotsFor(now)) {
      if (slot.contains(minute)) {
        final left = slot.closeMinute - minute;
        return OpeningStatus(
          isOpen: true,
          headline: left <= 30 ? 'Ferme bientôt' : 'Ouvert',
          detail: 'jusqu\'à ${formatMinute(slot.closeMinute)}',
        );
      }
    }
    final next = nextOpening(now);
    if (next == null) {
      return const OpeningStatus(isOpen: false, headline: 'Fermé', detail: 'horaires à venir');
    }
    final sameDay = next.year == now.year && next.month == now.month && next.day == now.day;
    final tomorrow = now.add(const Duration(days: 1));
    final isTomorrow = next.year == tomorrow.year && next.month == tomorrow.month && next.day == tomorrow.day;
    final when = sameDay
        ? 'à ${formatMinute(next.hour * 60 + next.minute)}'
        : isTomorrow
            ? 'demain à ${formatMinute(next.hour * 60 + next.minute)}'
            : '${weekdayNames[next.weekday - 1].toLowerCase()} à ${formatMinute(next.hour * 60 + next.minute)}';
    return OpeningStatus(isOpen: false, headline: 'Fermé', detail: 'ouvre $when');
  }

  /// Prochaine ouverture strictement après [from] (dans les 7 jours).
  DateTime? nextOpening(DateTime from) {
    for (var d = 0; d < 8; d++) {
      final day = DateTime(from.year, from.month, from.day).add(Duration(days: d));
      for (final slot in slotsFor(day)) {
        final open = day.add(Duration(minutes: slot.openMinute));
        if (open.isAfter(from)) return open;
      }
    }
    return null;
  }

  /// Créneaux de retrait proposés : toutes les 15 min dans les heures
  /// d'ouverture, au plus tôt [leadTime] après maintenant, jusqu'à 15 min
  /// avant la fermeture.
  List<DateTime> pickupSlots(DateTime now, {Duration leadTime = const Duration(minutes: 20), int count = 6}) {
    final earliest = now.add(leadTime);
    final result = <DateTime>[];
    for (var d = 0; d < 8 && result.length < count; d++) {
      final day = DateTime(now.year, now.month, now.day).add(Duration(days: d));
      for (final slot in slotsFor(day)) {
        for (var m = slot.openMinute; m <= slot.closeMinute - 15 && result.length < count; m += 15) {
          final t = day.add(Duration(minutes: m));
          if (!t.isBefore(earliest)) result.add(t);
        }
      }
    }
    return result;
  }

  /// Un retrait est possible à [t] s'il tombe dans un créneau et au moins
  /// 15 min avant sa fermeture.
  bool acceptsPickupAt(DateTime t) {
    final minute = t.hour * 60 + t.minute;
    return slotsFor(t).any((s) => minute >= s.openMinute && minute <= s.closeMinute - 15);
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'address': address,
        'phone': phone,
        'schedule': [
          for (var i = 0; i < 7; i++)
            {'day': i + 1, 'slots': schedule[i].map((s) => s.toMap()).toList()},
        ],
      };

  /// Lit un document `restaurants/*`. Les documents d'avant le restaurant
  /// unique n'ont ni `schedule` ni `phone` : on les écarte (null) pour
  /// retomber sur [artix].
  static RestaurantLocation? fromMap(Map<String, dynamic> map) {
    final rawSchedule = map['schedule'] as List<dynamic>?;
    if (rawSchedule == null) return null;
    final schedule = List<List<OpeningSlot>>.generate(7, (_) => []);
    for (final entry in rawSchedule) {
      final day = Map<String, dynamic>.from(entry as Map);
      final index = ((day['day'] as num).toInt() - 1).clamp(0, 6);
      schedule[index] = ((day['slots'] as List<dynamic>?) ?? [])
          .map((s) => OpeningSlot.fromMap(Map<String, dynamic>.from(s as Map)))
          .toList();
    }
    return RestaurantLocation(
      name: map['name'] as String? ?? artix.name,
      address: map['address'] as String? ?? artix.address,
      phone: map['phone'] as String?,
      schedule: schedule,
    );
  }
}
