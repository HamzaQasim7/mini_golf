import 'package:flutter/material.dart';
import 'package:mini_golf/features/game/data/models/player_model.dart';
import 'package:mini_golf/features/game/presentation/pages/score_card_screen.dart';

import '../../../../core/theme/app_colors.dart';

// --- DUMMY DATA FOR UI PREVIEW ---
final _dummyPlayers1 = [
  Player(
    name: 'Alice',
    avatar: '',
    handicap: 0,
    colorHex: '#FF0000',
    scores: {1: 4, 2: 5, 3: 3},
  ),
  Player(
    name: 'Bob',
    avatar: '',
    handicap: 0,
    colorHex: '#00FF00',
    scores: {1: 3, 2: 4, 3: 4},
  ),
];

final _dummyPlayers2 = [
  Player(
    name: 'Charlie',
    avatar: '',
    handicap: 0,
    colorHex: '#0000FF',
    scores: {1: 5, 2: 5, 3: 5},
  ),
  Player(
    name: 'Dave',
    avatar: '',
    handicap: 0,
    colorHex: '#FFFF00',
    scores: {1: 6, 2: 5, 3: 6},
  ),
];

final _dummyGames = [
  Game(
    id: 'game1',
    courseName: 'Blast Zone',
    numberOfHoles: 3,
    players: _dummyPlayers1,
    isCompleted: true,
    createdAt: DateTime.now().subtract(const Duration(days: 2)),
    lastUpdated: DateTime.now().subtract(const Duration(days: 2)),
  ),
  Game(
    id: 'game2',
    courseName: 'Crazy Course',
    numberOfHoles: 3,
    players: _dummyPlayers2,
    isCompleted: false,
    createdAt: DateTime.now().subtract(const Duration(hours: 5)),
    lastUpdated: DateTime.now().subtract(const Duration(hours: 5)),
  ),
];
// --- END DUMMY DATA ---

class GameHistoryScreen extends StatefulWidget {
  const GameHistoryScreen({super.key});

  @override
  State<GameHistoryScreen> createState() => _GameHistoryScreenState();
}

class _GameHistoryScreenState extends State<GameHistoryScreen> {
  // A mutable list to manage the games shown in the UI.
  late List<Game> _games;

  @override
  void initState() {
    super.initState();
    // Initialize the list with a copy of the dummy data.
    _games = List.from(_dummyGames);
  }

  // Method to show a confirmation dialog before deletion.
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
              child:
                  const Text("DELETE", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  // Method to perform the deletion and show feedback.
  void _performDelete(Game game) {
    // Check if the widget is still in the tree.
    if (!mounted) return;

    setState(() {
      _games.removeWhere((g) => g.id == game.id);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${game.courseName} has been deleted.'),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.backgroundDark,
        elevation: 0,
        leading: const CloseButton(color: Colors.white),
        centerTitle: true,
        title: const Text(
          'Game History',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: _games.isEmpty
          ? const Center(
              child: Text(
                'No past games found.',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: _games.length,
              itemBuilder: (context, index) {
                final game = _games[index];
                return Dismissible(
                  key: Key(game.id!),
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
                    _performDelete(game);
                  },
                  child: _GameHistoryCard(
                    game: game,
                    onDelete: () async {
                      final confirmed = await _showDeleteConfirmationDialog();
                      if (confirmed == true) {
                        _performDelete(game);
                      }
                    },
                  ),
                );
              },
            ),
    );
  }
}

class _GameHistoryCard extends StatelessWidget {
  final Game game;
  final VoidCallback onDelete;

  const _GameHistoryCard({
    required this.game,
    required this.onDelete,
  });

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
    // Simple date formatting without external packages
    final formattedDate = '${date.day}/${date.month}/${date.year}';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      clipBehavior:
          Clip.antiAlias, // Ensures the InkWell ripple respects the border radius
      child: InkWell(
        onTap: () {
          // Navigate to ScorecardScreen with the details of the selected game.
          final playerNames = game.players.map((p) => p.name).toList();
          final scores = game.players.map((p) => p.totalScore).toList();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  ScorecardScreen(),
            ),
          );
        },
        child: Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
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
                icon: const Icon(Icons.delete_outline),
                iconSize: 22,
                color: Colors.redAccent,
                onPressed: onDelete,
                visualDensity: VisualDensity.compact,
                tooltip: 'Delete Game',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
