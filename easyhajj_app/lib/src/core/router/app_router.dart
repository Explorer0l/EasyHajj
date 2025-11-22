import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/data/auth_repository.dart';
import '../../features/auth/domain/app_user.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/onboarding/application/onboarding_progress_controller.dart';
import '../../features/onboarding/presentation/location_permission_screen.dart';
import '../../features/onboarding/presentation/notification_opt_in_screen.dart';
import '../../features/onboarding/presentation/phone_code_screen.dart';
import '../../features/onboarding/presentation/phone_entry_screen.dart';
import '../../features/onboarding/presentation/sign_in_options_screen.dart';
import '../../features/onboarding/presentation/splash_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final notifier = RouterNotifier(ref);
  return GoRouter(
    initialLocation: SplashScreen.routePath,
    debugLogDiagnostics: false,
    refreshListenable: notifier,
    redirect: notifier.handleRedirect,
    routes: [
      GoRoute(
        path: SplashScreen.routePath,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: SignInOptionsScreen.routePath,
        builder: (context, state) => const SignInOptionsScreen(),
      ),
      GoRoute(
        path: PhoneEntryScreen.routePath,
        builder: (context, state) => const PhoneEntryScreen(),
      ),
      GoRoute(
        path: PhoneCodeScreen.routePath,
        builder: (context, state) => PhoneCodeScreen(
          verificationId: state.extra as String?,
        ),
      ),
      GoRoute(
        path: NotificationOptInScreen.routePath,
        builder: (context, state) => const NotificationOptInScreen(),
      ),
      GoRoute(
        path: LocationPermissionScreen.routePath,
        builder: (context, state) => const LocationPermissionScreen(),
      ),
      GoRoute(
        path: HomeScreen.routePath,
        builder: (context, state) => const HomeScreen(),
      ),
    ],
  );
});

class RouterNotifier extends ChangeNotifier {
  RouterNotifier(this.ref) {
    _authSub = ref.listen<AsyncValue<AppUser?>>(
      authStateChangesProvider,
      (previousValue, nextValue) => notifyListeners(),
      fireImmediately: true,
    );
    _onboardingSub = ref.listen<OnboardingProgress>(
      onboardingProgressProvider,
      (previousValue, nextValue) => notifyListeners(),
      fireImmediately: true,
    );
  }

  final Ref ref;
  late final ProviderSubscription<AsyncValue<AppUser?>> _authSub;
  late final ProviderSubscription<OnboardingProgress> _onboardingSub;

  String? handleRedirect(BuildContext context, GoRouterState state) {
    final auth = ref.read(authStateChangesProvider);
    final onboarding = ref.read(onboardingProgressProvider);

    final isSplash = state.uri.path == SplashScreen.routePath;
    final isOnboardingRoute =
        state.uri.path.startsWith('/onboarding');
    final isPhoneRoute = state.uri.path == PhoneEntryScreen.routePath ||
        state.uri.path == PhoneCodeScreen.routePath;

    if (auth.isLoading) {
      return isSplash ? null : SplashScreen.routePath;
    }

    final user = auth.valueOrNull;

    if (user == null && !isOnboardingRoute && !isSplash) {
      return SignInOptionsScreen.routePath;
    }

    if (user == null) {
      return null;
    }

    if (!onboarding.isComplete) {
      if (state.uri.path == LocationPermissionScreen.routePath ||
          state.uri.path == NotificationOptInScreen.routePath ||
          isPhoneRoute ||
          state.uri.path == SignInOptionsScreen.routePath) {
        return null;
      }
      return NotificationOptInScreen.routePath;
    }

    final goingToOnboarding = isOnboardingRoute || isSplash;
    if (goingToOnboarding) {
      return HomeScreen.routePath;
    }

    return null;
  }

  @override
  void dispose() {
    _authSub.close();
    _onboardingSub.close();
    super.dispose();
  }
}

