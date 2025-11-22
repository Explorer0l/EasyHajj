import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

class EasyHajjLogo extends StatelessWidget {
  const EasyHajjLogo({super.key, this.size = 48});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Text(
      'EASYHAJJ',
      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            letterSpacing: 4,
            fontWeight: FontWeight.w800,
            color: AppColors.primaryTeal,
            fontSize: size * 0.5,
          ),
    );
  }
}

