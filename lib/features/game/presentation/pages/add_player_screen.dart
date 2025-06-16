import 'package:flutter/material.dart';
import 'package:mini_golf/features/game/presentation/pages/course_selection_screen.dart';
import 'package:mini_golf/features/game/presentation/pages/hole_score_screen.dart';
import 'package:mini_golf/widgets/custom_button.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../widgets/player_input_card.dart';
import '../../data/models/player_model.dart';

// Assume AppColors is imported

class AddPlayersScreen extends StatelessWidget {
  const AddPlayersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundDark,
        elevation: 0,
        leading: const CloseButton(color: Colors.white),
        centerTitle: true,
        title: const Text(
          'New Game',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: const Padding(padding: EdgeInsets.all(16), child: AddPlayersBody()),
    );
  }
}

class AddPlayersBody extends StatefulWidget {
  const AddPlayersBody({super.key});

  @override
  State<AddPlayersBody> createState() => _AddPlayersBodyState();
}

class _AddPlayersBodyState extends State<AddPlayersBody> {
  final List<String> playerNames = List.filled(6, '');
  final List<Color?> selectedColors = List.filled(6, null);

  final List<Color> availableColors = [
    Colors.red,
    Colors.green,
    Colors.blue,
    Colors.yellow,
    Colors.pinkAccent,
    Colors.cyanAccent,
  ];

  void _onColorSelected(int playerIndex, Color color) {
    setState(() {
      selectedColors[playerIndex] = color;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Add Players',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: ListView.builder(
            itemCount: 6,
            itemBuilder: (context, index) {
              return PlayerInputCard(
                index: index,
                onNameChanged: (name) => playerNames[index] = name,
                selectedColor: selectedColors[index],
                availableColors: availableColors,
                onColorSelected: (color) => _onColorSelected(index, color),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        CustomButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (_) => HoleScoreScreen(
                      holeNumber: 1, // Replace with the desired hole number
                      players:
                          playerNames
                              .map(
                                (name) => Player(
                                  name: name,
                                  avatar: 'assets/images/mini-golf.jpg',
                                  handicap: 2,
                                ),
                              )
                              .toList(),
                    ),
              ),
            );
          },
          text: 'Next',
        ),
      ],
    );
  }
}
