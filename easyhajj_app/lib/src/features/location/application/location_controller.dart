import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import '../data/location_repository.dart';
import '../domain/user_location.dart';

final locationBoxProvider = Provider<Box<UserLocation>>((ref) {
  return Hive.box<UserLocation>(locationBoxName);
});

final locationRepositoryProvider = Provider<LocationRepository>((ref) {
  final box = ref.watch(locationBoxProvider);
  return LocationRepository(box);
});

final locationControllerProvider =
    StateNotifierProvider<LocationController, AsyncValue<UserLocation?>>(
  (ref) {
    final repo = ref.watch(locationRepositoryProvider);
    return LocationController(repo)..loadCached();
  },
);

class LocationController extends StateNotifier<AsyncValue<UserLocation?>> {
  LocationController(this._repository)
      : super(const AsyncValue.loading());

  final LocationRepository _repository;

  void loadCached() {
    final cached = _repository.cachedLocation;
    if (cached != null) {
      state = AsyncValue.data(cached);
    } else {
      state = const AsyncValue.data(null);
    }
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    try {
      final location = await _repository.refreshCurrentLocation();
      state = AsyncValue.data(location);
    } on LocationException catch (error, stack) {
      state = AsyncValue.error(error, stack);
    } catch (error, stack) {
      state = AsyncValue.error(
        LocationException('Не удалось определить местоположение. $error'),
        stack,
      );
    }
  }
}

