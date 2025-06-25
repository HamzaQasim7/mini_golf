import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_fortune_wheel/flutter_fortune_wheel.dart';
import 'package:mini_golf/features/game/data/models/crazy_wheel_tasks_model.dart';
import 'package:mini_golf/widgets/custom_button.dart';

import '../../../../core/theme/app_colors.dart';

class SpinWheelScreen extends StatefulWidget {
  final void Function(String title, String description) onTaskSelected;

  const SpinWheelScreen({super.key, required this.onTaskSelected});

  @override
  State<SpinWheelScreen> createState() => _SpinWheelScreenState();
}

class _SpinWheelScreenState extends State<SpinWheelScreen> {
  final StreamController<int> _selected = StreamController<int>();
  int? selectedIndex;
  bool isSpinning = false;

  @override
  void dispose() {
    _selected.close();
    super.dispose();
  }

  void spinWheel() {
    if (isSpinning || crazyMiniGolfTasks.isEmpty) return;

    isSpinning = true;
    final random = Random();
    final index = random.nextInt(crazyMiniGolfTasks.length);

    setState(() {
      selectedIndex = index;
    });

    _selected.add(index);
  }

  @override
  Widget build(BuildContext context) {
    if (crazyMiniGolfTasks.isEmpty) {
      return const Scaffold(body: Center(child: Text("No tasks available.")));
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.backgroundDark,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: Text(
          'Spin the Wheel',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Wheel widget
              SizedBox(
                height: 250,
                child: FortuneWheel(
                  selected: _selected.stream,
                  animateFirst: false,
                  items: [
                    for (final task in crazyMiniGolfTasks)
                      FortuneItem(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6.0),
                          child: Text(
                            task.title,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                          ),
                        ),
                      ),
                  ],
                  onAnimationEnd: () {
                    HapticFeedback.heavyImpact();
                    setState(() {
                      isSpinning = false;
                    });
                  },
                ),
              ),
              const SizedBox(height: 32),

              // Action buttons and result
              if (selectedIndex == null)
                CustomButton(onPressed: spinWheel, text: "SPIN 🎯")
              else ...[
                Text(
                  crazyMiniGolfTasks[selectedIndex!].title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Text(
                    crazyMiniGolfTasks[selectedIndex!].description,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
                const SizedBox(height: 32),
                CustomButton(
                  onPressed: () {
                    widget.onTaskSelected(
                      crazyMiniGolfTasks[selectedIndex!].title,
                      crazyMiniGolfTasks[selectedIndex!].description,
                    );
                  },
                  text: "Continue to Hole",
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
