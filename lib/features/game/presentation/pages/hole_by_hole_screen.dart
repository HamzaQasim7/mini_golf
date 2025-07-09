import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../widgets/custom_button.dart';
import '../providers/game_provider.dart';
import '../widgets/score_button.dart';
import 'score_card_screen.dart';
import 'spin_wheel_screen.dart';

class HoleByHoleScreen extends StatefulWidget {
  const HoleByHoleScreen({super.key});

  @override
  State<HoleByHoleScreen> createState() => _HoleByHoleScreenState();
}

class _HoleByHoleScreenState extends State<HoleByHoleScreen> {
  late PageController _pageController;
  int _currentHole = 1;

  @override
  void initState() {
    super.initState();
    final gameProvider = Provider.of<GameProvider>(context, listen: false);
    final currentGame = gameProvider.currentGame;
    if (currentGame != null) {
      _currentHole = currentGame.currentHole;
      _pageController = PageController(initialPage: _currentHole - 1);
    } else {
      _pageController = PageController();
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, gameProvider, child) {
        final currentGame = gameProvider.currentGame;

        if (currentGame == null) {
          return Scaffold(
            backgroundColor: AppColors.backgroundDark,
            appBar: AppBar(title: const Text('Error')),
            body: const Center(
              child: Text(
                'No active game found.',
                style: TextStyle(color: Colors.white),
              ),
            ),
          );
        }

        return Scaffold(
          backgroundColor: AppColors.backgroundDark,
          appBar: AppBar(
            backgroundColor: AppColors.backgroundDark,
            elevation: 0,
            centerTitle: true,
            automaticallyImplyLeading: false,
            title: Text(
              'Hole $_currentHole of ${currentGame.numberOfHoles}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
              ),
            ],
          ),
          body: Column(
            children: [
              // Progress indicator
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: LinearProgressIndicator(
                  value: _currentHole / currentGame.numberOfHoles,
                  backgroundColor: Colors.grey[600],
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    AppColors.primary,
                  ),
                ),
              ),

              SizedBox(
                height: 30,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed:
                          _currentHole > 1
                              ? () {
                                _pageController.previousPage(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                );
                              }
                              : null,
                      icon: Icon(Icons.arrow_back, color: Colors.white),
                    ),
                    IconButton(
                      onPressed: () async {
                        if (_currentHole == currentGame.numberOfHoles) {
                          // Finish the game
                          await gameProvider.completeGame();
                          if (mounted) {
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder:
                                    (context) =>
                                        ScorecardScreen(game: currentGame),
                              ),
                            );
                          }
                        } else {
                          // For Crazy Mini Golf, go to spin wheel before next hole
                          if (currentGame.courseName == 'Crazy Mini Golf') {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => SpinWheelScreen(
                                      onTaskSelected: (
                                        spinContext,
                                        title,
                                        description,
                                      ) {
                                        // After spinning, go to next hole
                                        Navigator.pop(spinContext);
                                        _pageController.nextPage(
                                          duration: const Duration(
                                            milliseconds: 300,
                                          ),
                                          curve: Curves.easeInOut,
                                        );

                                        // Show task for the next hole
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              'Hole ${_currentHole + 1} Task: $title',
                                            ),
                                            backgroundColor: Colors.blueAccent,
                                          ),
                                        );
                                      },
                                    ),
                              ),
                            );
                          } else {
                            // For regular courses, just go to next hole
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          }
                        }
                      },
                      icon: Icon(Icons.arrow_forward, color: Colors.white),
                    ),
                  ],
                ),
              ),
              // PageView for holes
              Expanded(
                child: PageView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentHole = index + 1;
                    });
                    // Update current hole in provider
                    gameProvider.updateCurrentHole(_currentHole);
                  },
                  itemCount: currentGame.numberOfHoles,
                  itemBuilder: (context, index) {
                    return _HoleScoreCard(
                      holeNumber: index + 1,
                      game: currentGame,
                    );
                  },
                ),
              ),

              // Navigation buttons
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: CustomButton(
                        text: 'Previous',
                        textStyle: const TextStyle(color: Colors.white),
                        backgroundColor: const Color(0xFF2A3B34),
                        textColor: Colors.white,
                        onPressed:
                            _currentHole > 1
                                ? () {
                                  _pageController.previousPage(
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                  );
                                }
                                : null,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: CustomButton(
                        text:
                            _currentHole == currentGame.numberOfHoles
                                ? 'Finish Game'
                                : 'Next',
                        backgroundColor: AppColors.primary,
                        textColor: Colors.black,
                        onPressed: () async {
                          if (_currentHole == currentGame.numberOfHoles) {
                            // Finish the game
                            await gameProvider.completeGame();
                            if (mounted) {
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                  builder:
                                      (context) =>
                                          ScorecardScreen(game: currentGame),
                                ),
                              );
                            }
                          } else {
                            // For Crazy Mini Golf, go to spin wheel before next hole
                            if (currentGame.courseName == 'Crazy Mini Golf') {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => SpinWheelScreen(
                                        onTaskSelected: (
                                          spinContext,
                                          title,
                                          description,
                                        ) {
                                          // After spinning, go to next hole
                                          Navigator.pop(spinContext);
                                          _pageController.nextPage(
                                            duration: const Duration(
                                              milliseconds: 300,
                                            ),
                                            curve: Curves.easeInOut,
                                          );

                                          // Show task for the next hole
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                'Hole ${_currentHole + 1} Task: $title',
                                              ),
                                              backgroundColor:
                                                  Colors.blueAccent,
                                            ),
                                          );
                                        },
                                      ),
                                ),
                              );
                            } else {
                              // For regular courses, just go to next hole
                              _pageController.nextPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            }
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _HoleScoreCard extends StatefulWidget {
  final int holeNumber;
  final dynamic game;

  const _HoleScoreCard({required this.holeNumber, required this.game});

  @override
  State<_HoleScoreCard> createState() => _HoleScoreCardState();
}

class _HoleScoreCardState extends State<_HoleScoreCard> {
  late List<int> _scores;

  @override
  void initState() {
    super.initState();
    _initializeScores();
  }

  void _initializeScores() {
    final holeIndex = widget.holeNumber - 1;
    if (holeIndex >= 0 && holeIndex < widget.game.holes.length) {
      _scores =
          widget.game.holes[holeIndex]
              .map((score) => score.strokes is int ? score.strokes : 0)
              .cast<int>()
              .toList();
    } else {
      _scores = List.filled(widget.game.players.length, 0);
    }
  }

  void _incrementScore(int playerIndex) {
    setState(() {
      if (_scores[playerIndex] < 99) {
        _scores[playerIndex]++;
      }
    });
    _saveScore(playerIndex, _scores[playerIndex]);
  }

  void _decrementScore(int playerIndex) {
    setState(() {
      if (_scores[playerIndex] > 0) {
        _scores[playerIndex]--;
      }
    });
    _saveScore(playerIndex, _scores[playerIndex]);
  }

  void _saveScore(int playerIndex, int score) {
    final gameProvider = Provider.of<GameProvider>(context, listen: false);
    final holeIndex = widget.holeNumber - 1;
    gameProvider.updateHoleScore(
      holeIndex: holeIndex,
      playerIndex: playerIndex,
      strokes: score,
    );
  }

  @override
  Widget build(BuildContext context) {
    final players = widget.game.players;
    final holeIndex = widget.holeNumber - 1;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: players.length,
              itemBuilder: (context, index) {
                final par = widget.game.holes[holeIndex][index].par;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Player name and Par
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              players[index].name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Par $par',
                              style: const TextStyle(
                                color: AppColors.greyB3,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Score controls
                      Row(
                        children: [
                          ScoreButton(
                            icon: Icons.remove,
                            onTap: () => _decrementScore(index),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${_scores[index]}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(width: 8),
                          ScoreButton(
                            icon: Icons.add,
                            onTap: () => _incrementScore(index),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
