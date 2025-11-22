import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../home/presentation/home_screen.dart';
import '../../location/application/location_controller.dart';
import '../application/onboarding_progress_controller.dart';

class LocationPermissionScreen extends ConsumerWidget {
  const LocationPermissionScreen({super.key});

  static const routePath = '/onboarding/location';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(onboardingProgressProvider.notifier);
    final locationState = ref.watch(locationControllerProvider);
    final locationController =
        ref.read(locationControllerProvider.notifier);

    Future<void> completeFlow(bool allowLocation) async {
      await controller.setLocationPermission(allowLocation);
      await controller.complete();
      if (context.mounted) {
        context.go(HomeScreen.routePath);
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Местоположение'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Spacer(),
            Icon(
              Icons.location_on_outlined,
              size: 96,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 24),
            Text(
              'Включить местоположение',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              locationState.value != null
                  ? 'Определено: ${locationState.value!.displayName}'
                  : 'Мы будем определять ваш город, чтобы показывать точное время молитв и ближайшую мечеть.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            if (locationState.hasError)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text(
                  locationState.error.toString(),
                  style: const TextStyle(color: Colors.redAccent),
                  textAlign: TextAlign.center,
                ),
              ),
            const Spacer(),
            ElevatedButton(
              onPressed: locationState.isLoading
                  ? null
                  : () async {
                      await locationController.refresh();
                      final updated =
                          ref.read(locationControllerProvider);
                      if (updated.hasError) {
                        return;
                      }
                      if (updated.value != null) {
                        await completeFlow(true);
                      }
                    },
              child: locationState.isLoading
                  ? const CircularProgressIndicator.adaptive()
                  : const Text('Моё местоположение'),
            ),
            TextButton(
              onPressed: () => completeFlow(false),
              child: const Text('Пропустить'),
            ),
          ],
        ),
      ),
    );
  }
}

