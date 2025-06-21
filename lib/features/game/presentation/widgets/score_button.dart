import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class ScoreButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const ScoreButton({super.key, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF2A3B34),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 36,
          height: 36,
          child: Icon(icon, color: AppColors.greyB3, size: 24),
        ),
      ),
    );
  }
}
