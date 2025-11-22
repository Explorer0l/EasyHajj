import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../auth/data/auth_repository.dart';
import '../../location/application/location_controller.dart';
import '../../location/domain/user_location.dart';
import '../../onboarding/presentation/location_permission_screen.dart';
import '../../prayer_times/application/prayer_times_controller.dart';
import '../../prayer_times/domain/prayer_entities.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  static const routePath = '/home';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateChangesProvider);
    final user = authState.valueOrNull;
    final locationState = ref.watch(locationControllerProvider);
    final prayerState = ref.watch(prayerTimesControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Сегодня'),
        actions: [
          IconButton(
            onPressed: () => ref.read(authRepositoryProvider).signOut(),
            icon: const Icon(Icons.logout),
            tooltip: 'Выйти',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Ассаляму алейкум!',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                user == null
                    ? 'Гостевой режим'
                    : user.isAnonymous
                        ? 'Гостевой аккаунт'
                        : user.displayName ?? 'Пользователь',
              ),
              const SizedBox(height: 24),
              _LocationSummary(
                locationState: locationState,
                onRequestLocationPermission: () =>
                    GoRouter.of(context).push(LocationPermissionScreen.routePath),
                onRefreshLocation: () =>
                    ref.read(locationControllerProvider.notifier).refresh(),
              ),
              const SizedBox(height: 24),
              _PrayerSummary(
                state: prayerState,
                onRefresh: () =>
                    ref.read(prayerTimesControllerProvider.notifier).refresh(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LocationSummary extends StatelessWidget {
  const _LocationSummary({
    required this.locationState,
    required this.onRequestLocationPermission,
    required this.onRefreshLocation,
  });

  final AsyncValue<UserLocation?> locationState;
  final VoidCallback onRequestLocationPermission;
  final VoidCallback onRefreshLocation;

  @override
  Widget build(BuildContext context) {
    final location = locationState.value;
    if (location == null) {
      return Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Местоположение не определено',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Включите геолокацию, чтобы видеть точное расписание молитв.',
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: onRequestLocationPermission,
                child: const Text('Определить местоположение'),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            Icons.location_on_outlined,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  location.displayName,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  'Обновлено: ${TimeOfDay.fromDateTime(location.collectedAt).format(context)}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onRefreshLocation,
            icon: const Icon(Icons.refresh),
            tooltip: 'Обновить локацию',
          ),
        ],
      ),
    );
  }
}

class _PrayerSummary extends StatelessWidget {
  const _PrayerSummary({
    required this.state,
    required this.onRefresh,
  });

  final AsyncValue<PrayerDayTimes?> state;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return state.when(
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: CircularProgressIndicator(),
        ),
      ),
      error: (error, _) => Column(
        children: [
          Text(
            error.toString(),
            style: const TextStyle(color: Colors.redAccent),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: onRefresh,
            child: const Text('Повторить'),
          ),
        ],
      ),
      data: (data) {
        if (data == null) {
          return Column(
            children: [
              const Text('Нет данных. Определите местоположение.'),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: onRefresh,
                child: const Text('Обновить'),
              ),
            ],
          );
        }
        final now = DateTime.now();
        final next = data.nextPrayer(now);
        final duration = data.timeUntilNext(now);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF8C6FF7),
                    Color(0xFF50C5B7),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Следующая молитва',
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: Colors.white70),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    next != null
                        ? '${next.label} — ${_formatTime(context, next.time)}'
                        : 'День завершён',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  if (duration != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        'Осталось ${_formatDuration(duration)}',
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: data.prayers.length,
              separatorBuilder: (context, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final entry = data.prayers[index];
                final isNext = next?.id == entry.id;
                final isPast = entry.time.isBefore(now);
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color: isNext
                        ? Theme.of(context)
                            .colorScheme
                            .primary
                            .withValues(alpha: 0.1)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isNext
                          ? Theme.of(context).colorScheme.primary
                          : Colors.black12,
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              entry.label,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight: isNext
                                        ? FontWeight.bold
                                        : FontWeight.w500,
                                  ),
                            ),
                            if (isPast && !isNext)
                              const Text(
                                'Прочитано',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                          ],
                        ),
                      ),
                      Text(
                        _formatTime(context, entry.time),
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  String _formatTime(BuildContext context, DateTime time) {
    final timeOfDay = TimeOfDay.fromDateTime(time);
    return timeOfDay.format(context);
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    if (hours <= 0) {
      return '$minutes мин.';
    }
    return '$hours ч ${minutes.toString().padLeft(2, '0')} мин.';
  }
}

