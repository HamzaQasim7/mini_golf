import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class PlayerCountSelector extends StatelessWidget {
  final int selectedPlayerCount;
  final ValueChanged<int> onPlayerCountChanged;

  const PlayerCountSelector({
    super.key,
    required this.selectedPlayerCount,
    required this.onPlayerCountChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: List.generate(6, (index) {
        final count = index + 1;
        final isSelected = selectedPlayerCount == count;
        return GestureDetector(
          onTap: () => onPlayerCountChanged(count),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 100,
            padding: const EdgeInsets.symmetric(
              vertical: 12,
              horizontal: 12,
            ),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary : Colors.transparent,
              border: Border.all(
                color: isSelected ? AppColors.primary : AppColors.greyB3,
                width: 1,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: Text(
              '$count Player${count > 1 ? 's' : ''}',
              style: TextStyle(
                color: isSelected ? Colors.black : Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: isSelected ? 14 : 12,
              ),
            ),
          ),
        );
      }),
    );
  }
}