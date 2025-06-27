import 'package:flutter/material.dart';
import 'package:mini_golf/widgets/custom_button.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../providers/game_provider.dart';
import '../providers/player_provider.dart';
import '../widgets/golf_dimple_painter.dart';
import '../widgets/player_count_selector.dart';
import 'game_flow_screen.dart';

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
  final List<TextEditingController> _nameControllers = List.generate(
    6,
    (index) => TextEditingController(),
  );
  bool _isCreatingGame = false;

  // Animation controllers for each color button
  late List<AnimationController> _colorAnimationControllers;
  late List<Animation<double>> _scaleAnimations;
  late List<Animation<double>> _rotationAnimations;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeTextControllers();
  }

  void _initializeAnimations() {
    final playerProvider = Provider.of<PlayerSetupProvider>(
      context,
      listen: false,
    );
    _colorAnimationControllers = List.generate(
      playerProvider.availableColors.length,
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

  void _initializeTextControllers() {
    final playerProvider = Provider.of<PlayerSetupProvider>(
      context,
      listen: false,
    );
    for (int i = 0; i < _nameControllers.length; i++) {
      _nameControllers[i].text = playerProvider.playerNames[i];
      _nameControllers[i].addListener(() {
        playerProvider.setPlayerName(i, _nameControllers[i].text);
      });
    }
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
    final playerProvider = Provider.of<PlayerSetupProvider>(
      context,
      listen: false,
    );

    // Find the color index for animation
    final colorIndex = playerProvider.availableColors.indexOf(color);
    if (colorIndex != -1) {
      // Reset the animation controller
      _colorAnimationControllers[colorIndex].reset();
      // Trigger animation
      await _colorAnimationControllers[colorIndex].forward();
      await _colorAnimationControllers[colorIndex].reverse();
    }

    if (!playerProvider.isColorUnique(color, playerIndex)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('This color is already selected by another player'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    playerProvider.setPlayerColor(playerIndex, color);
  }

  Future<void> _startGame() async {
    final playerProvider = Provider.of<PlayerSetupProvider>(
      context,
      listen: false,
    );
    final gameProvider = Provider.of<GameProvider>(context, listen: false);

    if (!playerProvider.canStartGame() || _isCreatingGame) return;

    setState(() {
      _isCreatingGame = true;
    });

    try {
      final validPlayerNames = playerProvider.getValidPlayerNames();
      final validPlayerColors = playerProvider.getValidPlayerColors();

      await gameProvider.createGame(
        courseName: widget.courseName,
        numberOfHoles: widget.numberOfHoles,
        playerNames: validPlayerNames,
        playerColors: validPlayerColors,
      );

      if (mounted) {
        if (gameProvider.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to create game: ${gameProvider.error}'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }

        // Navigate to the GameFlowScreen, which will handle the routing.
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const GameFlowScreen(),
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
    final playerProvider = Provider.of<PlayerSetupProvider>(
      context,
      listen: false,
    );

    final AnimationController slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    final Animation<Offset> slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: slideController, curve: Curves.easeInOut),
    );

    await slideController.forward();

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
                Consumer<PlayerSetupProvider>(
                  builder: (context, provider, child) {
                    return Wrap(
                      spacing: 24,
                      runSpacing: 24,
                      children: List.generate(provider.availableColors.length, (
                        colorIdx,
                      ) {
                        final color = provider.availableColors[colorIdx];
                        final colorHex =
                            '#${color.value.toRadixString(16).substring(2)}';
                        final isSelected =
                            provider.selectedColors[playerIndex] == colorHex;
                        return GestureDetector(
                          onTap: () {
                            Navigator.pop(context, color);
                          },
                          child: _buildGolfBall(color, isSelected, colorIdx),
                        );
                      }),
                    );
                  },
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

  Color _getPlayerColor(PlayerSetupProvider provider, int playerIndex) {
    final colorHex = provider.selectedColors[playerIndex];
    if (colorHex != null) {
      return Color(int.parse(colorHex.replaceFirst('#', '0xFF')));
    }
    return Colors.white;
  }

  bool _isPlayerColorSelected(PlayerSetupProvider provider, int playerIndex) {
    return provider.selectedColors[playerIndex] != null;
  }

  int _getColorIndex(PlayerSetupProvider provider, int playerIndex) {
    final colorHex = provider.selectedColors[playerIndex];
    if (colorHex != null) {
      final color = Color(int.parse(colorHex.replaceFirst('#', '0xFF')));
      return provider.availableColors.indexOf(color);
    }
    return 0;
  }

  String _getValidationMessage(PlayerSetupProvider provider) {
    final validNames = provider.getValidPlayerNames();
    final validColors = provider.getValidPlayerColors();

    if (validNames.isEmpty) {
      return 'Add at least two players to start';
    } else if (validNames.length < 2) {
      return 'Need ${2 - validNames.length} more valid player(s)';
    } else if (validNames.length != validColors.length) {
      return 'Please select colors for all players';
    } else {
      return '${validNames.length} player(s) ready';
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
          child: Consumer<PlayerSetupProvider>(
            builder: (context, playerProvider, child) {
              return Column(
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
                    selectedPlayerCount: playerProvider.selectedPlayerCount,
                    onPlayerCountChanged: (count) {
                      playerProvider.setPlayerCount(count);
                      // Clear text controllers for unused players
                      for (int i = count; i < 6; i++) {
                        _nameControllers[i].clear();
                      }
                    },
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.4,
                    child: ListView.builder(
                      itemCount: playerProvider.selectedPlayerCount,
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
                                    errorText: playerProvider
                                        .validatePlayerName(
                                          _nameControllers[index].text,
                                          index,
                                        ),
                                  ),
                                  textCapitalization:
                                      TextCapitalization.sentences,
                                  onTapOutside: (_) {
                                    FocusScope.of(context).unfocus();
                                  },
                                ),
                              ),
                              const SizedBox(width: 16),
                              GestureDetector(
                                onTap: () => _showBallPicker(index),
                                child: _buildGolfBall(
                                  _getPlayerColor(playerProvider, index),
                                  _isPlayerColorSelected(playerProvider, index),
                                  _getColorIndex(playerProvider, index),
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
                      Consumer<GameProvider>(
                        builder: (context, gameProvider, child) {
                          return CustomButton(
                            onPressed:
                                playerProvider.canStartGame() &&
                                        !_isCreatingGame &&
                                        !gameProvider.isLoading
                                    ? _startGame
                                    : null,
                            text:
                                _isCreatingGame || gameProvider.isLoading
                                    ? 'Creating Game...'
                                    : 'Start Game',
                            backgroundColor:
                                playerProvider.canStartGame() &&
                                        !_isCreatingGame &&
                                        !gameProvider.isLoading
                                    ? AppColors.primary
                                    : AppColors.greyB3,
                          );
                        },
                      ),
                      const SizedBox(height: 8),
                      Center(
                        child: Text(
                          _getValidationMessage(playerProvider),
                          style: const TextStyle(
                            color: AppColors.greyB3,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
