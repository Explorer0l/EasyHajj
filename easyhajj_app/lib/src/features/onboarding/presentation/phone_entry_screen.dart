import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../auth/application/auth_controller.dart';
import 'notification_opt_in_screen.dart';
import 'phone_code_screen.dart';

class PhoneEntryScreen extends ConsumerStatefulWidget {
  const PhoneEntryScreen({super.key});

  static const routePath = '/onboarding/phone';

  @override
  ConsumerState<PhoneEntryScreen> createState() => _PhoneEntryScreenState();
}

class _PhoneEntryScreenState extends ConsumerState<PhoneEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();

  String? _error;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final controller = ref.read(authControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Вход по номеру'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Введите номер телефона для отправки SMS-кода.',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Номер телефона',
                  prefixText: '+',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Введите номер телефона';
                  }
                  if (value.length < 10) {
                    return 'Проверьте корректность номера';
                  }
                  return null;
                },
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
                onPressed: authState.isLoading
                    ? null
                    : () async {
                        final isValid = _formKey.currentState?.validate() ?? false;
                        if (!isValid) return;
                        try {
                          final verificationId = await controller.requestPhoneCode(
                            '+${_phoneController.text.trim()}',
                          );
                          if (!context.mounted) return;
                          if (verificationId.isEmpty) {
                            context.go(NotificationOptInScreen.routePath);
                            return;
                          }
                          context.push(
                            PhoneCodeScreen.routePath,
                            extra: verificationId,
                          );
                        } catch (error) {
                          setState(() {
                            _error = error.toString();
                          });
                        }
                      },
                child: authState.isLoading
                    ? const CircularProgressIndicator.adaptive()
                    : const Text('Получить код'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

