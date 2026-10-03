import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';

class AppLogo extends StatelessWidget {
  const AppLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180,
      height: 180,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.22),
        shape: BoxShape.circle,
      ),
      child: Image.asset(
        'assets/image/logo.png',
        fit: BoxFit.contain,
      ),
    );
  }
}