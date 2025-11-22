import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/providers/shared_preferences_provider.dart';

const _onboardingCompleteKey = 'onboarding_completed';
const _prayerNotificationKey = 'prayer_notification_preferences';
const _locationPermissionKey = 'location_permission_granted';

const _defaultPrayerIds = <String>[
  'fajr',
  'shuruq',
  'zuhr',
  'asr',
  'maghrib',
  'isha',
];

final onboardingPreferencesProvider = Provider<OnboardingPreferences>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return OnboardingPreferences(prefs);
});

class OnboardingPreferences {
  OnboardingPreferences(this._prefs);

  final SharedPreferences _prefs;

  bool get isComplete => _prefs.getBool(_onboardingCompleteKey) ?? false;

  Future<void> markComplete() async {
    await _prefs.setBool(_onboardingCompleteKey, true);
  }

  Map<String, bool> prayerNotifications() {
    final raw = _prefs.getString(_prayerNotificationKey);
    if (raw == null) {
      return {for (final id in _defaultPrayerIds) id: id != 'shuruq'};
    }

    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    final values = decoded.map(
      (key, value) => MapEntry(key, value == true),
    );

    for (final id in _defaultPrayerIds) {
      values.putIfAbsent(id, () => id != 'shuruq');
    }

    return values;
  }

  Future<void> savePrayerNotifications(Map<String, bool> values) async {
    await _prefs.setString(
      _prayerNotificationKey,
      jsonEncode(values),
    );
  }

  bool get hasLocationPermission =>
      _prefs.getBool(_locationPermissionKey) ?? false;

  Future<void> setLocationPermission(bool allowed) async {
    await _prefs.setBool(_locationPermissionKey, allowed);
  }
}

