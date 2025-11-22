import 'package:easyhajj_app/src/features/onboarding/data/onboarding_preferences.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('OnboardingPreferences', () {
    test('provides default prayer toggles', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final store = OnboardingPreferences(prefs);

      final notifications = store.prayerNotifications();

      expect(store.isComplete, isFalse);
      expect(notifications['fajr'], isTrue);
      expect(notifications.containsKey('isha'), isTrue);
    });

    test('persists completion flag', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final store = OnboardingPreferences(prefs);

      await store.markComplete();

      expect(store.isComplete, isTrue);
    });
  });
}

