import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../auth/application/auth_controller.dart';
import 'notification_opt_in_screen.dart';

class PhoneCodeScreen extends ConsumerStatefulWidget {
  const PhoneCodeScreen({super.key, this.verificationId});

  static const routePath = '/onboarding/phone/code';

  final String? verificationId;

  @override
  ConsumerState<PhoneCodeScreen> createState() => _PhoneCodeScreenState();
}

class _PhoneCodeScreenState extends ConsumerState<PhoneCodeScreen> {
  final _codeController = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final controller = ref.read(authControllerProvider.notifier);

    final verificationId = widget.verificationId;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Подтвердите код'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Мы отправили SMS-код. Введите его ниже, чтобы завершить вход.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _codeController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              decoration: const InputDecoration(
                labelText: 'Код из SMS',
              ),
            ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  _error!,
                  style: const TextStyle(color: Colors.redAccent),
                ),
              ),
            const Spacer(),
            ElevatedButton(
              onPressed: authState.isLoading || verificationId == null
                  ? null
                  : () async {
                      try {
                        await controller.confirmSmsCode(
                          verificationId: verificationId,
                          smsCode: _codeController.text.trim(),
                        );
                        if (!context.mounted) return;
                        context.go(NotificationOptInScreen.routePath);
                      } catch (error) {
                        setState(() {
                          _error = error.toString();
                        });
                      }
                    },
              child: authState.isLoading
                  ? const CircularProgressIndicator.adaptive()
                  : const Text('Продолжить'),
            ),
          ],
        ),
      ),
    );
  }
}

