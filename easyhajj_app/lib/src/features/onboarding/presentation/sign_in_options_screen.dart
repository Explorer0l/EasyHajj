import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/presentation/widgets/easyhajj_logo.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/application/auth_controller.dart';
import 'phone_entry_screen.dart';

class SignInOptionsScreen extends ConsumerStatefulWidget {
  const SignInOptionsScreen({super.key});

  static const routePath = '/onboarding/sign-in';

  @override
  ConsumerState<SignInOptionsScreen> createState() =>
      _SignInOptionsScreenState();
}

class _SignInOptionsScreenState
    extends ConsumerState<SignInOptionsScreen> {
  bool consentAccepted = true;

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final controller = ref.read(authControllerProvider.notifier);
    final isLoading = authState.isLoading;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const EasyHajjLogo(),
              const SizedBox(height: 48),
              Text(
                'Выберите способ входа',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 32),
              _AuthButton(
                icon: Icons.g_mobiledata,
                label: 'Войти с помощью Google',
                enabled: consentAccepted && !isLoading,
                onPressed: () async {
                  await controller.signInWithGoogle();
                },
              ),
              const SizedBox(height: 12),
              _AuthButton(
                icon: Icons.phone,
                label: 'Использовать номер телефона',
                enabled: consentAccepted && !isLoading,
                onPressed: () =>
                    context.push(PhoneEntryScreen.routePath),
              ),
              const SizedBox(height: 12),
              _AuthButton(
                icon: Icons.notifications_active_outlined,
                label: 'Получать напоминания как гость',
                variant: _AuthButtonVariant.ghost,
                enabled: !isLoading,
                onPressed: () => controller.continueAsGuest(),
              ),
              const Spacer(),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Checkbox.adaptive(
                    value: consentAccepted,
                    onChanged: (value) {
                      setState(() {
                        consentAccepted = value ?? false;
                      });
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'Я согласен с обработкой информации, как указано в Политике конфиденциальности.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
              if (authState.hasError)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    authState.error.toString(),
                    style: const TextStyle(color: Colors.redAccent),
                  ),
                ),
              Align(
                alignment: Alignment.center,
                child: TextButton(
                  onPressed: isLoading
                      ? null
                      : () async {
                          await controller.continueAsGuest();
                        },
                  child: const Text('Пропустить'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum _AuthButtonVariant { filled, outlined, ghost }

class _AuthButton extends StatelessWidget {
  const _AuthButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.enabled = true,
    this.variant = _AuthButtonVariant.filled,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final bool enabled;
  final _AuthButtonVariant variant;

  @override
  Widget build(BuildContext context) {
    final ButtonStyle style;
    switch (variant) {
      case _AuthButtonVariant.outlined:
        style = OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          side: const BorderSide(color: AppColors.textSecondary),
        );
      case _AuthButtonVariant.ghost:
        style = TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        );
      case _AuthButtonVariant.filled:
        style = ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        );
    }

    final child = Row(
      children: [
        Icon(icon, color: AppColors.textPrimary),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
      ],
    );

    return switch (variant) {
      _AuthButtonVariant.filled => ElevatedButton(
          style: style,
          onPressed: enabled ? onPressed : null,
          child: child,
        ),
      _AuthButtonVariant.outlined => OutlinedButton(
          style: style,
          onPressed: enabled ? onPressed : null,
          child: child,
        ),
      _AuthButtonVariant.ghost => TextButton(
          style: style,
          onPressed: enabled ? onPressed : null,
          child: child,
        ),
    };
  }
}

