import 'dart:io';

import 'package:easyhajj_app/src/features/location/domain/user_location.dart';
import 'package:easyhajj_app/src/features/prayer_times/data/prayer_times_repository.dart';
import 'package:easyhajj_app/src/features/prayer_times/domain/prayer_entities.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;
  late Box<PrayerDayTimes> box;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp();
    Hive
      ..init(tempDir.path)
      ..registerAdapter(UserLocationAdapter())
      ..registerAdapter(PrayerTimeEntryAdapter())
      ..registerAdapter(PrayerDayTimesAdapter());
    box = await Hive.openBox<PrayerDayTimes>('test_prayers');
    SharedPreferences.setMockInitialValues({});
  });

  tearDown(() async {
    await box.clear();
    await box.close();
    await Hive.deleteFromDisk();
    await tempDir.delete(recursive: true);
  });

  test('calculates and caches prayer times for a location', () async {
    final prefs = await SharedPreferences.getInstance();
    final repo = PrayerTimesRepository(box, prefs);
    final location = UserLocation(
      latitude: 21.4225,
      longitude: 39.8262,
      city: 'Мекка',
      country: 'Саудовская Аравия',
      timezone: 'Asia/Riyadh',
      collectedAt: DateTime.utc(2025, 1, 1),
    );
    final date = DateTime(2025, 1, 1);
    final result = await repo.loadForDate(location, date);

    expect(result.prayers, hasLength(6));
    final cacheKey = '${buildLocationKey(location)}_${formatDateKey(date)}';
    final cached = box.get(cacheKey);
    expect(cached, isNotNull);
    expect(cached!.prayers.first.label, 'Фаджр');
  });
}

