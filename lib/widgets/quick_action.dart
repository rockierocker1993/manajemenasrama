import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';

class QuickAction extends StatelessWidget {

  final IconData icon;
  final String label;

  const QuickAction({
    super.key,
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {

    return Column(
      children: [

        Container(
          width: 62,
          height: 62,

          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(.1),
            borderRadius: BorderRadius.circular(18),
          ),

          child: Icon(icon, color: AppColors.primary),
        ),

        const SizedBox(height: 8),

        Text(label),
      ],
    );
  }
}