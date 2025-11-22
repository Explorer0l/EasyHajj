// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'dart:async';

import 'package:easyhajj_app/src/app.dart';
import 'package:easyhajj_app/src/core/providers/shared_preferences_provider.dart';
import 'package:easyhajj_app/src/features/auth/data/auth_repository.dart';
import 'package:easyhajj_app/src/features/auth/domain/app_user.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('EasyHajjApp renders splash logo', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          authRepositoryProvider.overrideWithValue(const _FakeAuthRepository()),
        ],
        child: const EasyHajjApp(),
      ),
    );

    await tester.pump();

    expect(find.text('EASYHAJJ'), findsOneWidget);
  });
}

class _FakeAuthRepository implements AuthRepository {
  const _FakeAuthRepository();

  @override
  Stream<AppUser?> authStateChanges() => const Stream.empty();

  @override
  Future<void> confirmSmsCode({
    required String verificationId,
    required String smsCode,
  }) async {}

  @override
  Future<void> signInAsGuest() async {}

  @override
  Future<void> signInWithGoogle() async {}

  @override
  Future<String> startPhoneNumberVerification(String phoneNumber) async =>
      '';

  @override
  Future<void> signOut() async {}
}
