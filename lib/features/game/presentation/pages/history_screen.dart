import 'package:flutter/material.dart';
import 'package:mini_golf/features/game/presentation/pages/hole_by_hole_screen.dart';
import 'package:mini_golf/features/game/presentation/pages/score_card_screen.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/game_provider.dart';

class GameHistoryScreen extends StatefulWidget {
  const GameHistoryScreen({super.key});

  @override
  State<GameHistoryScreen> createState() => _GameHistoryScreenState();
}

class _GameHistoryScreenState extends State<GameHistoryScreen> {
  @override
  void initState() {
    super.initState();
    // Load games from Hive via provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<GameProvider>(context, listen: false).refreshData();
    });
  }

  Future<bool?> _showDeleteConfirmationDialog() {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirm Deletion"),
          content: const Text("Are you sure you want to delete this game?"),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text("CANCEL"),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text("DELETE", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, gameProvider, child) {
        final games = gameProvider.gameHistory;
        return Scaffold(
          appBar: AppBar(
            backgroundColor: AppColors.backgroundDark,
            elevation: 0,
            leading: const CloseButton(color: Colors.white),
            centerTitle: true,
            title: const Text(
              'Game History',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          body:
              games.isEmpty
                  ? const Center(
                    child: Text(
                      'No past games found.',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  )
                  : ListView.builder(
                    reverse: true,
                    shrinkWrap: true,
                    padding: const EdgeInsets.all(8),
                    itemCount: games.length,
                    itemBuilder: (context, index) {
                      final game = games[index];
                      return Dismissible(
                        key: Key(game.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          color: Colors.redAccent,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          alignment: Alignment.centerRight,
                          child: const Icon(
                            Icons.delete_forever,
                            color: Colors.white,
                          ),
                        ),
                        confirmDismiss: (direction) async {
                          return await _showDeleteConfirmationDialog();
                        },
                        onDismissed: (direction) {
                          gameProvider.deleteGame(game.id);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                '${game.courseName} has been deleted.',
                              ),
                              backgroundColor: Colors.red,
                            ),
                          );
                        },
                        child: _GameHistoryCard(game: game),
                      );
                    },
                  ),
        );
      },
    );
  }
}

class _GameHistoryCard extends StatelessWidget {
  final dynamic game; // Use your Game model type

  const _GameHistoryCard({required this.game});

  Future<void> _deleteGame(BuildContext context) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirm Deletion"),
          content: const Text("Are you sure you want to delete this game?"),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text("CANCEL"),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text("DELETE", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );

    if (shouldDelete == true) {
      final gameProvider = Provider.of<GameProvider>(context, listen: false);
      await gameProvider.deleteGame(game.id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${game.courseName} has been deleted.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final winners = game.getWinners();
    String winnerText;

    if (!game.isCompleted) {
      winnerText = 'Status: In Progress';
    } else if (winners.isEmpty) {
      winnerText = 'Status: Completed';
    } else if (winners.length > 1) {
      winnerText = 'Result: A Tie!';
    } else {
      winnerText = 'Winner: ${winners.first.name}';
    }

    final date = game.createdAt;
    final formattedDate = '${date.day}/${date.month}/${date.year}';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          if (game.isCompleted) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ScorecardScreen(game: game),
              ),
            );
          } else {
            // Set as current game in provider before resuming
            final gameProvider = Provider.of<GameProvider>(context, listen: false);
            gameProvider.setCurrentGame(game);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const HoleByHoleScreen(),
              ),
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      game.courseName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Played on: $formattedDate',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      winnerText,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                game.isCompleted
                    ? Icons.check_circle_outline
                    : Icons.hourglass_top_rounded,
                color: game.isCompleted ? Colors.green : Colors.orangeAccent,
                size: 22,
              ),
              IconButton(
                onPressed: () => _deleteGame(context),
                icon: const Icon(Icons.delete, color: Colors.red),
                tooltip: 'Delete Game',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
