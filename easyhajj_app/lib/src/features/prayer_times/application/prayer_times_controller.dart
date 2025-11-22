import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import '../../../core/providers/shared_preferences_provider.dart';
import '../../location/application/location_controller.dart';
import '../data/prayer_times_repository.dart';
import '../domain/prayer_entities.dart';

final prayerTimesBoxProvider = Provider<Box<PrayerDayTimes>>((ref) {
  return Hive.box<PrayerDayTimes>(prayerTimesBoxName);
});

final prayerTimesRepositoryProvider = Provider<PrayerTimesRepository>((ref) {
  final box = ref.watch(prayerTimesBoxProvider);
  final prefs = ref.watch(sharedPreferencesProvider);
  return PrayerTimesRepository(box, prefs);
});

final prayerTimesControllerProvider =
    AsyncNotifierProvider<PrayerTimesController, PrayerDayTimes?>(
  PrayerTimesController.new,
);

class PrayerTimesController extends AsyncNotifier<PrayerDayTimes?> {
  @override
  Future<PrayerDayTimes?> build() async {
    final locationState = ref.watch(locationControllerProvider);
    final location = locationState.value;
    if (location == null) return null;
    final repo = ref.watch(prayerTimesRepositoryProvider);
    return repo.loadForDate(location, DateTime.now());
  }

  Future<void> refresh() async {
    final locationState = ref.read(locationControllerProvider);
    final location = locationState.value;
    if (location == null) return;
    state = const AsyncValue.loading();
    try {
      final repo = ref.read(prayerTimesRepositoryProvider);
      final result = await repo.loadForDate(location, DateTime.now());
      state = AsyncValue.data(result);
    } catch (error, stack) {
      state = AsyncValue.error(error, stack);
    }
  }
}

