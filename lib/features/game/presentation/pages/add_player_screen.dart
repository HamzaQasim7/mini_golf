import 'package:flutter/material.dart';
import 'package:mini_golf/features/game/presentation/pages/hole_score_screen.dart';
import 'package:mini_golf/widgets/custom_button.dart';
import 'package:provider/provider.dart';
import 'package:mini_golf/features/game/domain/entities/player.dart' as domain;

import '../../../../core/theme/app_colors.dart';
import '../../data/models/player_model.dart';
import '../pages/spin_wheel_screen.dart';
import '../providers/game_provider.dart';
import '../widgets/golf_dimple_painter.dart';
import '../widgets/player_count_selector.dart';

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

class _AddPlayersScreenState extends State<AddPlayersScreen>
    with TickerProviderStateMixin {
  int selectedPlayerCount = 2; // Default to 2 players
  final List<TextEditingController> _nameControllers = List.generate(
    6,
    (index) => TextEditingController(),
  );
  final List<Color?> selectedColors = List.filled(6, null);
  bool _isCreatingGame = false;

  // Animation controllers for each color button
  late List<AnimationController> _colorAnimationControllers;
  late List<Animation<double>> _scaleAnimations;
  late List<Animation<double>> _rotationAnimations;

  final List<Color> availableColors = [
    const Color(0xFFFF4444), // Red
    const Color(0xFF44FF44), // Green
    const Color(0xFF4444FF), // Blue
    const Color(0xFFFFDD44), // Yellow
    const Color(0xFFFF44DD), // Pink
    const Color(0xFF44FFDD), // Cyan
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _colorAnimationControllers = List.generate(
      availableColors.length,
      (index) => AnimationController(
        duration: const Duration(milliseconds: 200),
        vsync: this,
      ),
    );

    _scaleAnimations =
        _colorAnimationControllers
            .map(
              (controller) => Tween<double>(begin: 1.0, end: 1.2).animate(
                CurvedAnimation(parent: controller, curve: Curves.elasticOut),
              ),
            )
            .toList();

    _rotationAnimations =
        _colorAnimationControllers
            .map(
              (controller) => Tween<double>(begin: 0.0, end: 0.1).animate(
                CurvedAnimation(parent: controller, curve: Curves.easeInOut),
              ),
            )
            .toList();
  }

  @override
  void dispose() {
    for (var controller in _nameControllers) {
      controller.dispose();
    }
    for (var animationController in _colorAnimationControllers) {
      animationController.dispose();
    }
    super.dispose();
  }

  void _onColorSelected(int playerIndex, Color color) async {
    // Find the color index for animation
    final colorIndex = availableColors.indexOf(color);
    if (colorIndex != -1) {
      // Reset the animation controller
      _colorAnimationControllers[colorIndex].reset();
      // Trigger animation
      await _colorAnimationControllers[colorIndex].forward();
      await _colorAnimationControllers[colorIndex].reverse();
    }

    if (!_isColorUnique(color, playerIndex)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('This color is already selected by another player'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      selectedColors[playerIndex] = color;
    });
  }

  bool _isNameValid(String name) {
    return name.trim().isNotEmpty;
  }

  bool _isNameUnique(String name, int currentIndex) {
    for (int i = 0; i < selectedPlayerCount; i++) {
      if (i != currentIndex &&
          _nameControllers[i].text.trim().toLowerCase() ==
              name.trim().toLowerCase()) {
        return false;
      }
    }
    return true;
  }

  String? _validatePlayerName(String name, int index) {
    if (!_isNameValid(name)) {
      return 'Name cannot be empty';
    }
    if (!_isNameUnique(name, index)) {
      return 'Name must be unique';
    }
    return null;
  }

  bool _isColorUnique(Color color, int currentIndex) {
    for (int i = 0; i < selectedPlayerCount; i++) {
      if (i != currentIndex && selectedColors[i] == color) {
        return false;
      }
    }
    return true;
  }

  List<Player> _getValidPlayers() {
    final validPlayers = <Player>[];

    for (int i = 0; i < selectedPlayerCount; i++) {
      final name = _nameControllers[i].text.trim();
      final color = selectedColors[i];

      if (_isNameValid(name) &&
          _isNameUnique(name, i) &&
          color != null &&
          _isColorUnique(color, i)) {
        validPlayers.add(
          Player(
            name: name,
            avatar: 'assets/images/mini-golf.jpg',
            handicap: 0,
            colorHex: '#${color.value.toRadixString(16).substring(2)}',
          ),
        );
      }
    }

    return validPlayers;
  }

  bool _canStartGame() {
    final validPlayers = _getValidPlayers();
    return validPlayers.length >= 2;
  }

  Future<void> _startGame() async {
    if (!_canStartGame() || _isCreatingGame) return;

    setState(() {
      _isCreatingGame = true;
    });

    try {
      final validPlayers = _getValidPlayers();
      final domainPlayers = validPlayers.map(playerModelToDomain).toList();
      final gameProvider = Provider.of<GameProvider>(context, listen: false);

      await gameProvider.createGame(
        courseName: widget.courseName,
        players: domainPlayers,
      );

      // After game is created, navigate based on course
      if (widget.courseName == 'Blastzone Mini Golf') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => HoleScoreScreen()),
        );
      } else if (widget.courseName == 'Crazy Mini Golf') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => SpinWheelScreen(
              onTaskSelected: (title, description) {
                // After spinning, go to HoleScoreScreen
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => HoleScoreScreen()),
                );
              },
            ),
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

  Widget _buildGolfBall(Color color, bool isSelected, int colorIndex) {
    return AnimatedBuilder(
      animation: _colorAnimationControllers[colorIndex],
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimations[colorIndex].value,
          child: Transform.rotate(
            angle: _rotationAnimations[colorIndex].value,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  center: const Alignment(-0.3, -0.3),
                  colors: [
                    color.withOpacity(0.8),
                    color,
                    color.withOpacity(0.6),
                  ],
                  stops: const [0.0, 0.7, 1.0],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(2, 4),
                  ),
                  if (isSelected)
                    BoxShadow(
                      color: color.withOpacity(0.5),
                      blurRadius: 12,
                      spreadRadius: 2,
                    ),
                ],
              ),
              child: Stack(
                children: [
                  // Golf ball dimples pattern
                  Positioned.fill(
                    child: CustomPaint(painter: GolfBallDimplesPainter(color)),
                  ),
                  // Selection indicator
                  if (isSelected)
                    Center(
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.check,
                          color: Colors.black,
                          size: 12,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showBallPicker(int playerIndex) async {
    final AnimationController slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    final Animation<Offset> slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1), // Start from below the screen
      end: Offset.zero, // Slide to its original position
    ).animate(
      CurvedAnimation(parent: slideController, curve: Curves.easeInOut),
    );

    await slideController.forward(); // Start the slide animation

    final Color? selected = await showModalBottomSheet<Color>(
      context: context,
      backgroundColor: AppColors.backgroundDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SlideTransition(
          position: slideAnimation,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Select your golf ball',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 24),
                Wrap(
                  spacing: 24,
                  runSpacing: 24,
                  children: List.generate(availableColors.length, (colorIdx) {
                    final color = availableColors[colorIdx];
                    final isSelected = selectedColors[playerIndex] == color;
                    return GestureDetector(
                      onTap: () {
                        Navigator.pop(context, color);
                      },
                      child: _buildGolfBall(color, isSelected, colorIdx),
                    );
                  }),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );

    slideController.reverse();
    slideController.dispose();

    if (selected != null) {
      _onColorSelected(playerIndex, selected);
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
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'How many players?',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              // Player count selection
              PlayerCountSelector(
                selectedPlayerCount: selectedPlayerCount,
                onPlayerCountChanged: (count) {
                  setState(() {
                    selectedPlayerCount = count;
                    // Reset names/colors for unused players
                    for (int i = count; i < 6; i++) {
                      _nameControllers[i].clear();
                      selectedColors[i] = null;
                    }
                  });
                },
              ),

              const SizedBox(height: 24),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.4,
                child: ListView.builder(
                  itemCount: selectedPlayerCount,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _nameControllers[index],
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                hintText: 'Player ${index + 1} Name',
                                errorText: _validatePlayerName(
                                  _nameControllers[index].text,
                                  index,
                                ),
                              ),
                              textCapitalization: TextCapitalization.sentences,
                              onChanged: (value) {
                                setState(() {});
                              },
                              onTapOutside: (_) {
                                FocusScope.of(context).unfocus();
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          GestureDetector(
                            onTap: () => _showBallPicker(index),
                            child: _buildGolfBall(
                              selectedColors[index] ?? Colors.white,
                              false,
                              selectedColors[index] != null
                                  ? availableColors.indexOf(
                                    selectedColors[index]!,
                                  )
                                  : 0,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 34),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomButton(
                    onPressed:
                        _canStartGame() && !_isCreatingGame ? _startGame : null,
                    text: _isCreatingGame ? 'Creating Game...' : 'Start Game',
                    backgroundColor:
                        _canStartGame() ? AppColors.primary : AppColors.greyB3,
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: Text(
                      _getValidPlayers().isEmpty
                          ? 'Add at least two players to start'
                          : _getValidPlayers().length < 2
                          ? 'Need ${2 - _getValidPlayers().length} more valid player(s)'
                          : '${_getValidPlayers().length} player(s) ready',
                      style: const TextStyle(
                        color: AppColors.greyB3,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  domain.Player playerModelToDomain(Player model) {
    return domain.Player(
      id: '', // You can generate or assign an ID if needed
      name: model.name,
      avatar: model.avatar,
      handicap: model.handicap,
      colorHex: model.colorHex,
      createdAt: DateTime.now(),
      // Add other fields if needed
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

/*
 Wrap(
                spacing: 12,
                runSpacing: 12,
                children: List.generate(6, (index) {
                  final count = index + 1;
                  final isSelected = selectedPlayerCount == count;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedPlayerCount = count;
                        // Reset names/colors for unused players
                        for (int i = count; i < 6; i++) {
                          _nameControllers[i].clear();
                          selectedColors[i] = null;
                        }
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 100,
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 12,
                      ),
                      decoration: BoxDecoration(
                        color:
                            isSelected ? AppColors.primary : Colors.transparent,
                        border: Border.all(
                          color:
                              isSelected ? AppColors.primary : AppColors.greyB3,
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
              ),
 */
