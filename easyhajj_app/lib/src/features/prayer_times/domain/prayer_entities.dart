import 'package:hive/hive.dart';

import '../../location/domain/user_location.dart';

const prayerTimesBoxName = 'prayer_times_box';

class PrayerTimeEntry {
  const PrayerTimeEntry({
    required this.id,
    required this.label,
    required this.time,
  });

  final String id;
  final String label;
  final DateTime time;

  PrayerTimeEntry copyWith({
    String? id,
    String? label,
    DateTime? time,
  }) {
    return PrayerTimeEntry(
      id: id ?? this.id,
      label: label ?? this.label,
      time: time ?? this.time,
    );
  }
}

class PrayerTimeEntryAdapter extends TypeAdapter<PrayerTimeEntry> {
  @override
  final int typeId = 2;

  @override
  PrayerTimeEntry read(BinaryReader reader) {
    final id = reader.readString();
    final label = reader.readString();
    final millis = reader.readInt();
    return PrayerTimeEntry(
      id: id,
      label: label,
      time: DateTime.fromMillisecondsSinceEpoch(millis),
    );
  }

  @override
  void write(BinaryWriter writer, PrayerTimeEntry obj) {
    writer
      ..writeString(obj.id)
      ..writeString(obj.label)
      ..writeInt(obj.time.millisecondsSinceEpoch);
  }
}

class PrayerDayTimes {
  const PrayerDayTimes({
    required this.dateKey,
    required this.timezone,
    required this.locationKey,
    required this.prayers,
    required this.generatedAt,
  });

  final String dateKey; // yyyy-MM-dd
  final String timezone;
  final String locationKey;
  final List<PrayerTimeEntry> prayers;
  final DateTime generatedAt;

  PrayerTimeEntry? nextPrayer(DateTime now) {
    for (final entry in prayers) {
      if (entry.time.isAfter(now)) {
        return entry;
      }
    }
    return null;
  }

  PrayerTimeEntry? currentPrayer(DateTime now) {
    PrayerTimeEntry? current;
    for (final entry in prayers) {
      if (entry.time.isBefore(now)) {
        current = entry;
      } else {
        break;
      }
    }
    return current;
  }

  Duration? timeUntilNext(DateTime now) {
    final next = nextPrayer(now);
    if (next == null) return null;
    return next.time.difference(now);
  }
}

class PrayerDayTimesAdapter extends TypeAdapter<PrayerDayTimes> {
  @override
  final int typeId = 3;

  @override
  PrayerDayTimes read(BinaryReader reader) {
    final dateKey = reader.readString();
    final timezone = reader.readString();
    final locationKey = reader.readString();
    final generatedAt =
        DateTime.fromMillisecondsSinceEpoch(reader.readInt());
    final count = reader.readInt();
    final prayers = <PrayerTimeEntry>[];
    for (var i = 0; i < count; i++) {
      prayers.add(PrayerTimeEntryAdapter().read(reader));
    }
    return PrayerDayTimes(
      dateKey: dateKey,
      timezone: timezone,
      locationKey: locationKey,
      prayers: prayers,
      generatedAt: generatedAt,
    );
  }

  @override
  void write(BinaryWriter writer, PrayerDayTimes obj) {
    writer
      ..writeString(obj.dateKey)
      ..writeString(obj.timezone)
      ..writeString(obj.locationKey)
      ..writeInt(obj.generatedAt.millisecondsSinceEpoch)
      ..writeInt(obj.prayers.length);
    for (final prayer in obj.prayers) {
      PrayerTimeEntryAdapter().write(writer, prayer);
    }
  }
}

String buildLocationKey(UserLocation location) {
  return '${location.latitude.toStringAsFixed(3)}:${location.longitude.toStringAsFixed(3)}';
}

