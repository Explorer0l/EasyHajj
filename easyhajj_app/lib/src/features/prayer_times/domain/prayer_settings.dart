import 'dart:convert';

import 'package:adhan/adhan.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _settingsKey = 'prayer_calc_settings';

class PrayerCalculationSettings {
  const PrayerCalculationSettings({
    required this.method,
    required this.madhab,
    required this.highLatitudeRule,
    required this.adjustments,
  });

  final String method;
  final String madhab;
  final String highLatitudeRule;
  final Map<String, int> adjustments;

  CalculationParameters toAdhanParams() {
    final parameters = _methodFromString(method).getParameters();
    parameters.madhab = _madhabFromString(madhab);
    parameters.highLatitudeRule = _highLatitudeFromString(highLatitudeRule);
    parameters.adjustments = PrayerAdjustments()
      ..fajr = adjustments['fajr'] ?? 0
      ..sunrise = adjustments['sunrise'] ?? 0
      ..dhuhr = adjustments['dhuhr'] ?? 0
      ..asr = adjustments['asr'] ?? 0
      ..maghrib = adjustments['maghrib'] ?? 0
      ..isha = adjustments['isha'] ?? 0;
    return parameters;
  }

  PrayerCalculationSettings copyWith({
    String? method,
    String? madhab,
    String? highLatitudeRule,
    Map<String, int>? adjustments,
  }) {
    return PrayerCalculationSettings(
      method: method ?? this.method,
      madhab: madhab ?? this.madhab,
      highLatitudeRule: highLatitudeRule ?? this.highLatitudeRule,
      adjustments: adjustments ?? this.adjustments,
    );
  }

  Map<String, dynamic> toJson() => {
        'method': method,
        'madhab': madhab,
        'hlr': highLatitudeRule,
        'adj': adjustments,
      };

  static PrayerCalculationSettings fromJson(Map<String, dynamic> json) {
    return PrayerCalculationSettings(
      method: json['method'] as String? ?? 'muslim_world_league',
      madhab: json['madhab'] as String? ?? 'shafi',
      highLatitudeRule: json['hlr'] as String? ?? 'middle_of_the_night',
      adjustments: (json['adj'] as Map<String, dynamic>?)
              ?.map((key, value) => MapEntry(key, value as int)) ??
          const {},
    );
  }
}

CalculationMethod _methodFromString(String value) {
  switch (value) {
    case 'egyptian':
      return CalculationMethod.egyptian;
    case 'karachi':
      return CalculationMethod.karachi;
    case 'umm_al_qura':
      return CalculationMethod.umm_al_qura;
    default:
      return CalculationMethod.muslim_world_league;
  }
}

Madhab _madhabFromString(String value) {
  return value == 'hanafi' ? Madhab.hanafi : Madhab.shafi;
}

HighLatitudeRule _highLatitudeFromString(String value) {
  switch (value) {
    case 'seventh_of_the_night':
      return HighLatitudeRule.seventh_of_the_night;
    case 'twilight_angle':
      return HighLatitudeRule.twilight_angle;
    default:
      return HighLatitudeRule.middle_of_the_night;
  }
}

Future<PrayerCalculationSettings> loadPrayerSettings(
  SharedPreferences prefs,
) async {
  final raw = prefs.getString(_settingsKey);
  if (raw == null) {
    return const PrayerCalculationSettings(
      method: 'muslim_world_league',
      madhab: 'shafi',
      highLatitudeRule: 'middle_of_the_night',
      adjustments: {},
    );
  }
  return PrayerCalculationSettings.fromJson(
    jsonDecode(raw) as Map<String, dynamic>,
  );
}

Future<void> savePrayerSettings(
  SharedPreferences prefs,
  PrayerCalculationSettings settings,
) async {
  await prefs.setString(_settingsKey, jsonEncode(settings.toJson()));
}

