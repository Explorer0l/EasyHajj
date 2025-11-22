import 'dart:async';

import 'package:easyhajj_app/firebase_options.dart';
import 'package:easyhajj_app/src/app.dart';
import 'package:easyhajj_app/src/core/providers/shared_preferences_provider.dart';
import 'package:easyhajj_app/src/features/location/data/location_repository.dart';
import 'package:easyhajj_app/src/features/location/domain/user_location.dart';
import 'package:easyhajj_app/src/features/prayer_times/data/prayer_times_repository.dart';
import 'package:easyhajj_app/src/features/prayer_times/domain/prayer_entities.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await runZonedGuarded(
    () async {
      await Hive.initFlutter();
      _registerHiveAdapters();
      await Hive.openBox<UserLocation>(locationBoxName);
      await Hive.openBox<PrayerDayTimes>(prayerTimesBoxName);

      final prefs = await SharedPreferences.getInstance();
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      await Workmanager().initialize(
        workmanagerCallbackDispatcher,
      );
      await Workmanager().registerPeriodicTask(
        'prayer_refresh_task',
        'prayer_refresh_task',
        frequency: const Duration(hours: 12),
        existingWorkPolicy: ExistingPeriodicWorkPolicy.keep,
      );

      runApp(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
          ],
          child: const EasyHajjApp(),
        ),
      );
    },
    (error, stackTrace) {
      debugPrint('EasyHajj failed to start: $error');
      debugPrint('$stackTrace');
    },
  );
}

void _registerHiveAdapters() {
  if (!Hive.isAdapterRegistered(1)) {
    Hive.registerAdapter(UserLocationAdapter());
  }
  if (!Hive.isAdapterRegistered(2)) {
    Hive.registerAdapter(PrayerTimeEntryAdapter());
  }
  if (!Hive.isAdapterRegistered(3)) {
    Hive.registerAdapter(PrayerDayTimesAdapter());
  }
}

@pragma('vm:entry-point')
void workmanagerCallbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    WidgetsFlutterBinding.ensureInitialized();
    await Hive.initFlutter();
    _registerHiveAdapters();
    final locationBox =
        await Hive.openBox<UserLocation>(locationBoxName);
    final location = locationBox.get(currentLocationStorageKey);
    if (location == null) {
      return true;
    }
    final prayerBox =
        await Hive.openBox<PrayerDayTimes>(prayerTimesBoxName);
    final prefs = await SharedPreferences.getInstance();
    final repo = PrayerTimesRepository(prayerBox, prefs);
    await repo.loadForDate(location, DateTime.now());
    await repo.loadForDate(
      location,
      DateTime.now().add(const Duration(days: 1)),
    );
    await locationBox.close();
    await prayerBox.close();
    return true;
  });
}

