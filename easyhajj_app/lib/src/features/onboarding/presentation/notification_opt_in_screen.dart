import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../application/onboarding_progress_controller.dart';
import 'location_permission_screen.dart';

class NotificationOptInScreen extends ConsumerStatefulWidget {
  const NotificationOptInScreen({super.key});

  static const routePath = '/onboarding/notifications';

  @override
  ConsumerState<NotificationOptInScreen> createState() =>
      _NotificationOptInScreenState();
}

class _NotificationOptInScreenState
    extends ConsumerState<NotificationOptInScreen> {
  late Map<String, bool> toggles;

  @override
  void initState() {
    super.initState();
    final prefs =
        ref.read(onboardingProgressProvider).prayerNotifications;
    toggles = Map<String, bool>.from(prefs);
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.read(onboardingProgressProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Уведомления'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Включить уведомления для каждой молитвы',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 24),
            Expanded(
              child: ListView.separated(
                itemBuilder: (context, index) {
                  final tile = _prayerToggles[index];
                  final value = toggles[tile.id] ?? false;
                  return SwitchListTile.adaptive(
                    title: Text(tile.label),
                    subtitle:
                        tile.timeLabel == null ? null : Text(tile.timeLabel!),
                    value: value,
                    onChanged: (enabled) {
                      setState(() {
                        toggles[tile.id] = enabled;
                      });
                    },
                  );
                },
                separatorBuilder: (_, index) => const Divider(),
                itemCount: _prayerToggles.length,
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () async {
                await controller.updatePrayerNotifications(toggles);
                if (!context.mounted) return;
                context.go(LocationPermissionScreen.routePath);
              },
              child: const Text('Включить уведомления'),
            ),
            TextButton(
              onPressed: () {
                context.go(LocationPermissionScreen.routePath);
              },
              child: const Text('Пропустить'),
            ),
          ],
        ),
      ),
    );
  }
}

class _PrayerToggleData {
  const _PrayerToggleData({
    required this.id,
    required this.label,
    this.timeLabel,
  });

  final String id;
  final String label;
  final String? timeLabel;
}

const _prayerToggles = <_PrayerToggleData>[
  _PrayerToggleData(id: 'fajr', label: 'Фаджр', timeLabel: '05:25'),
  _PrayerToggleData(id: 'shuruq', label: 'Шурук', timeLabel: '07:33'),
  _PrayerToggleData(id: 'zuhr', label: 'Зухр', timeLabel: '13:20'),
  _PrayerToggleData(id: 'asr', label: 'Аср', timeLabel: '16:00'),
  _PrayerToggleData(id: 'maghrib', label: 'Магриб', timeLabel: '18:10'),
  _PrayerToggleData(id: 'isha', label: 'Иша', timeLabel: '21:30'),
];

