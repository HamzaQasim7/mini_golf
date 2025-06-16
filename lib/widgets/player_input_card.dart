import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import 'ball_color_option.dart';

class PlayerInputCard extends StatelessWidget {
  final int index;
  final Function(String) onNameChanged;
  final Color? selectedColor;
  final List<Color> availableColors;
  final Function(Color) onColorSelected;
  final TextEditingController controller;

  const PlayerInputCard({
    super.key,
    required this.index,
    required this.onNameChanged,
    required this.selectedColor,
    required this.availableColors,
    required this.onColorSelected,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: controller,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Player ${index + 1}',
              hintStyle: const TextStyle(color: AppColors.greyB3),
              filled: true,
              fillColor: const Color(0xFF1D2A23),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            ),
            onChanged: onNameChanged,
            onTapOutside: (_) {
              FocusScope.of(context).unfocus();
            },
          ),
          const SizedBox(height: 12),
          Row(
            children:
                availableColors.map((color) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: BallColorOption(
                      color: color,
                      isSelected: color == selectedColor,
                      onTap: () => onColorSelected(color),
                    ),
                  );
                }).toList(),
          ),
        ],
      ),
    );
  }
}
