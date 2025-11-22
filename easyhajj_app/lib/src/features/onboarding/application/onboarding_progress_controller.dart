import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/onboarding_preferences.dart';

final onboardingProgressProvider = StateNotifierProvider<
    OnboardingProgressController, OnboardingProgress>((ref) {
  final prefs = ref.watch(onboardingPreferencesProvider);
  return OnboardingProgressController(prefs);
});

class OnboardingProgressController
    extends StateNotifier<OnboardingProgress> {
  OnboardingProgressController(this._preferences)
      : super(
          OnboardingProgress(
            isComplete: _preferences.isComplete,
            prayerNotifications: _preferences.prayerNotifications(),
            hasLocationPermission: _preferences.hasLocationPermission,
          ),
        );

  final OnboardingPreferences _preferences;

  Future<void> complete() async {
    await _preferences.markComplete();
    state = state.copyWith(isComplete: true);
  }

  Future<void> updatePrayerNotifications(
    Map<String, bool> values,
  ) async {
    await _preferences.savePrayerNotifications(values);
    state = state.copyWith(prayerNotifications: values);
  }

  Future<void> setLocationPermission(bool allowed) async {
    await _preferences.setLocationPermission(allowed);
    state = state.copyWith(hasLocationPermission: allowed);
  }
}

class OnboardingProgress {
  const OnboardingProgress({
    required this.isComplete,
    required this.prayerNotifications,
    required this.hasLocationPermission,
  });

  final bool isComplete;
  final Map<String, bool> prayerNotifications;
  final bool hasLocationPermission;

  OnboardingProgress copyWith({
    bool? isComplete,
    Map<String, bool>? prayerNotifications,
    bool? hasLocationPermission,
  }) {
    return OnboardingProgress(
      isComplete: isComplete ?? this.isComplete,
      prayerNotifications: prayerNotifications ?? this.prayerNotifications,
      hasLocationPermission:
          hasLocationPermission ?? this.hasLocationPermission,
    );
  }
}

