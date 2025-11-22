import 'package:flutter/material.dart';

import '../../../core/presentation/widgets/easyhajj_logo.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  static const routePath = '/splash';

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            EasyHajjLogo(size: 56),
            SizedBox(height: 24),
            CircularProgressIndicator.adaptive(),
          ],
        ),
      ),
    );
  }
}

