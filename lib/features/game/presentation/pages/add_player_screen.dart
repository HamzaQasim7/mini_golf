import 'package:flutter/material.dart';
import 'package:mini_golf/features/game/presentation/pages/course_selection_screen.dart';
import 'package:mini_golf/features/game/presentation/pages/hole_score_screen.dart';
import 'package:mini_golf/widgets/custom_button.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../widgets/player_input_card.dart';
import '../../data/models/player_model.dart';
import '../providers/game_provider.dart';

class AddPlayersScreen extends StatefulWidget {
  final String courseName;
  final int numberOfHoles;

  const AddPlayersScreen({
    super.key,
    required this.courseName,
    required this.numberOfHoles,
  });

  @override
  State<AddPlayersScreen> createState() => _AddPlayersScreenState();
}

class _AddPlayersScreenState extends State<AddPlayersScreen> {
  final List<TextEditingController> _nameControllers = List.generate(
    6,
    (index) => TextEditingController(),
  );
  final List<Color?> selectedColors = List.filled(6, null);
  bool _isCreatingGame = false;

  final List<Color> availableColors = [
    Colors.red,
    Colors.green,
    Colors.blue,
    Colors.yellow,
    Colors.pinkAccent,
    Colors.cyanAccent,
  ];

  @override
  void dispose() {
    for (var controller in _nameControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _onColorSelected(int playerIndex, Color color) {
    setState(() {
      // Clear the color from other players if already selected
      for (int i = 0; i < selectedColors.length; i++) {
        if (i != playerIndex && selectedColors[i] == color) {
          selectedColors[i] = null;
        }
      }
      selectedColors[playerIndex] = color;
    });
  }

  List<Player> _getValidPlayers() {
    final validPlayers = <Player>[];

    for (int i = 0; i < _nameControllers.length; i++) {
      final name = _nameControllers[i].text.trim();
      final color = selectedColors[i];

      if (name.isNotEmpty && color != null) {
        validPlayers.add(
          Player(
            name: name,
            avatar: 'assets/images/mini-golf.jpg',
            handicap: 0, // Can be customized later
            colorHex: '#${color.value.toRadixString(16).substring(2)}',
          ),
        );
      }
    }

    return validPlayers;
  }

  bool _canStartGame() {
    final validPlayers = _getValidPlayers();
    return validPlayers.length >= 1; // At least 1 player required
  }

  Future<void> _startGame() async {
    if (!_canStartGame() || _isCreatingGame) return;

    setState(() {
      _isCreatingGame = true;
    });

    try {
      final players = _getValidPlayers();
      final gameProvider = Provider.of<GameProvider>(context, listen: false);

      await gameProvider.createGame(
        courseName: widget.courseName,
        numberOfHoles: widget.numberOfHoles,
        players: players,
      );

      if (gameProvider.error != null) {
        throw Exception(gameProvider.error);
      }

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => HoleScoreScreen(holeNumber: 1, players: []),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create game: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCreatingGame = false;
        });
      }
    }
  }

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
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Add Players',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  '${widget.courseName.isEmpty ? 'Unnamed Course' : widget.courseName} • ${widget.numberOfHoles} holes',
                  style: const TextStyle(fontSize: 14, color: AppColors.greyB3),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: 6,
                itemBuilder: (context, index) {
                  return PlayerInputCard(
                    index: index,
                    controller: _nameControllers[index],
                    selectedColor: selectedColors[index],
                    availableColors: availableColors,
                    onColorSelected: (color) => _onColorSelected(index, color),
                    onNameChanged: (String) {},
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Consumer<GameProvider>(
              builder: (context, gameProvider, child) {
                return CustomButton(
                  onPressed:
                      _canStartGame() && !_isCreatingGame ? _startGame : null,
                  text: _isCreatingGame ? 'Creating Game...' : 'Start Game',
                  backgroundColor:
                      _canStartGame() ? AppColors.primary : AppColors.greyB3,
                );
              },
            ),
            const SizedBox(height: 8),
            Text(
              _getValidPlayers().isEmpty
                  ? 'Add at least one player to start'
                  : '${_getValidPlayers().length} player(s) ready',
              style: const TextStyle(color: AppColors.greyB3, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

// class AddPlayersScreen extends StatelessWidget {
//   const AddPlayersScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.backgroundDark,
//       appBar: AppBar(
//         backgroundColor: AppColors.backgroundDark,
//         elevation: 0,
//         leading: const CloseButton(color: Colors.white),
//         centerTitle: true,
//         title: const Text(
//           'New Game',
//           style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
//         ),
//       ),
//       body: const Padding(padding: EdgeInsets.all(16), child: AddPlayersBody()),
//     );
//   }
// }
//
// class AddPlayersBody extends StatefulWidget {
//   const AddPlayersBody({super.key});
//
//   @override
//   State<AddPlayersBody> createState() => _AddPlayersBodyState();
// }
//
// class _AddPlayersBodyState extends State<AddPlayersBody> {
//   final List<String> playerNames = List.filled(6, '');
//   final List<Color?> selectedColors = List.filled(6, null);
//
//   final List<Color> availableColors = [
//     Colors.red,
//     Colors.green,
//     Colors.blue,
//     Colors.yellow,
//     Colors.pinkAccent,
//     Colors.cyanAccent,
//   ];
//
//   void _onColorSelected(int playerIndex, Color color) {
//     setState(() {
//       selectedColors[playerIndex] = color;
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         const Align(
//           alignment: Alignment.centerLeft,
//           child: Text(
//             'Add Players',
//             style: TextStyle(
//               fontSize: 22,
//               fontWeight: FontWeight.bold,
//               color: AppColors.textPrimary,
//             ),
//           ),
//         ),
//         const SizedBox(height: 16),
//         Expanded(
//           child: ListView.builder(
//             itemCount: 6,
//             itemBuilder: (context, index) {
//               return PlayerInputCard(
//                 index: index,
//                 onNameChanged: (name) => playerNames[index] = name,
//                 selectedColor: selectedColors[index],
//                 availableColors: availableColors,
//                 onColorSelected: (color) => _onColorSelected(index, color),
//               );
//             },
//           ),
//         ),
//         const SizedBox(height: 16),
//         CustomButton(
//           onPressed: () {
//             Navigator.push(
//               context,
//               MaterialPageRoute(
//                 builder:
//                     (_) => HoleScoreScreen(
//                       holeNumber: 1, // Replace with the desired hole number
//                       players:
//                           playerNames
//                               .map(
//                                 (name) => Player(
//                                   name: name,
//                                   avatar: 'assets/images/mini-golf.jpg',
//                                   handicap: 2,
//                                   colorHex: '',
//                                 ),
//                               )
//                               .toList(),
//                     ),
//               ),
//             );
//           },
//           text: 'Next',
//         ),
//       ],
//     );
//   }
// }
