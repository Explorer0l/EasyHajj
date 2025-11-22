import 'package:adhan/adhan.dart';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../location/domain/user_location.dart';
import '../domain/prayer_entities.dart';
import '../domain/prayer_settings.dart';

class PrayerTimesRepository {
  PrayerTimesRepository(this._box, this._prefs);

  final Box<PrayerDayTimes> _box;
  final SharedPreferences _prefs;

  Future<PrayerDayTimes> loadForDate(
    UserLocation location,
    DateTime date,
  ) async {
    final key = _buildCacheKey(location, date);
    final cached = _box.get(key);
    if (cached != null) {
      return cached;
    }
    final settings = await loadPrayerSettings(_prefs);
    final parameters = settings.toAdhanParams();
    final coordinates = Coordinates(location.latitude, location.longitude);
    final components = DateComponents(date.year, date.month, date.day);

    final prayerTimes = PrayerTimes(coordinates, components, parameters);

    final prayers = [
      PrayerTimeEntry(id: 'fajr', label: 'Фаджр', time: prayerTimes.fajr.toLocal()),
      PrayerTimeEntry(id: 'sunrise', label: 'Шурук', time: prayerTimes.sunrise.toLocal()),
      PrayerTimeEntry(id: 'dhuhr', label: 'Зухр', time: prayerTimes.dhuhr.toLocal()),
      PrayerTimeEntry(id: 'asr', label: 'Аср', time: prayerTimes.asr.toLocal()),
      PrayerTimeEntry(id: 'maghrib', label: 'Магриб', time: prayerTimes.maghrib.toLocal()),
      PrayerTimeEntry(id: 'isha', label: 'Иша', time: prayerTimes.isha.toLocal()),
    ];

    final payload = PrayerDayTimes(
      dateKey: formatDateKey(date),
      timezone: location.timezone,
      locationKey: buildLocationKey(location),
      prayers: prayers,
      generatedAt: DateTime.now(),
    );
    await _box.put(key, payload);
    return payload;
  }
}

String _buildCacheKey(UserLocation location, DateTime date) {
  return '${buildLocationKey(location)}_${formatDateKey(date)}';
}

String formatDateKey(DateTime date) {
  return '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}

