import 'dart:async';

import 'package:easyhajj_app/firebase_options.dart';
import 'package:easyhajj_app/src/app.dart';
import 'package:easyhajj_app/src/core/providers/shared_preferences_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await runZonedGuarded(
    () async {
      final prefs = await SharedPreferences.getInstance();
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
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

