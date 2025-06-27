import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_text_style.dart';
import '../../../../widgets/custom_button.dart';
import '../providers/game_provider.dart';
import 'score_card_screen.dart';

class AllHolesScoreEntryScreen extends StatefulWidget {
  const AllHolesScoreEntryScreen({super.key});

  @override
  State<AllHolesScoreEntryScreen> createState() =>
      _AllHolesScoreEntryScreenState();
}

class _AllHolesScoreEntryScreenState extends State<AllHolesScoreEntryScreen> {
  final Map<String, TextEditingController> _controllers = {};

  @override
  void initState() {
    super.initState();
    final gameProvider = Provider.of<GameProvider>(context, listen: false);
    final game = gameProvider.currentGame;
    if (game != null) {
      for (var p = 0; p < game.players.length; p++) {
        for (var h = 0; h < game.numberOfHoles; h++) {
          final key = '$p-$h';
          final score = game.holes[h][p].strokes;
          _controllers[key] = TextEditingController(
            text: score > 0 ? score.toString() : '',
          );
        }
      }
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E28),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Full Scorecard Entry',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () {
              // Potentially save all changes if not saving on the fly
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Scores saved!')));
            },
          ),
        ],
      ),
      body: Consumer<GameProvider>(
        builder: (context, gameProvider, child) {
          final game = gameProvider.currentGame;

          if (game == null) {
            return const Center(child: Text('No active game found.'));
          }

          return SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: DataTable(
                  columnSpacing: 16,
                  dataRowMaxHeight: 80.0,
                  dividerThickness: 1,
                  headingRowColor: MaterialStateProperty.all(
                    Colors.transparent,
                  ),
                  columns: _buildColumns(game.numberOfHoles),
                  rows: _buildRows(gameProvider),
                ),
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: _buildBottomBar(context),
    );
  }

  List<DataColumn> _buildColumns(int numberOfHoles) {
    return [
      DataColumn(
        label: Text(
          'Player',
          style: AppTextStyles.buttonSmall.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      DataColumn(
        label: Text(
          'Total',
          style: AppTextStyles.buttonSmall.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      ...List.generate(
        numberOfHoles,
        (index) => DataColumn(
          label: Center(child: Text('H${index + 1}')),
          numeric: true,
        ),
      ),
    ];
  }

  List<DataRow> _buildRows(GameProvider gameProvider) {
    final game = gameProvider.currentGame!;
    final totalScores = gameProvider.getTotalScores();

    return List.generate(game.players.length, (playerIndex) {
      final player = game.players[playerIndex];
      return DataRow(
        cells: [
          DataCell(
            Text(
              player.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          DataCell(
            Center(
              child: Text(
                totalScores[playerIndex].toString(),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          ...List.generate(game.numberOfHoles, (holeIndex) {
            final key = '$playerIndex-$holeIndex';
            return DataCell(
              SizedBox(
                width: 40,
                child: TextFormField(
                  controller: _controllers[key],
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 8),
                  ),
                  onChanged: (value) {
                    final newScore = int.tryParse(value) ?? 0;
                    gameProvider.updateHoleScore(
                      holeIndex: holeIndex,
                      playerIndex: playerIndex,
                      strokes: newScore,
                    );
                  },
                  onTapOutside: (_) {
                    FocusScope.of(context).unfocus();
                  },
                ),
              ),
            );
          }),
        ],
      );
    });
  }

  Widget _buildBottomBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            child: CustomButton(
              text: 'Save & Exit',
              textStyle: TextStyle(color: Colors.white),
              backgroundColor: const Color(0xFF2A3B34),
              textColor: Colors.white,
              onPressed: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: CustomButton(
              text: 'Finish Game',
              onPressed: () async {
                final gameProvider = Provider.of<GameProvider>(
                  context,
                  listen: false,
                );
                final gameToComplete = gameProvider.currentGame;

                if (gameToComplete == null) return;

                await gameProvider.completeGame();

                if (mounted) {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder:
                          (context) => ScorecardScreen(game: gameToComplete),
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
