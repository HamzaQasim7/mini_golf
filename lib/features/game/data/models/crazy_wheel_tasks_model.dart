// lib/features/game/presentation/pages/crazy_wheel_tasks.dart

class WheelTask {
  final String title;
  final String description;
  const WheelTask(this.title, this.description);
}

const List<WheelTask> crazyMiniGolfTasks = [
  WheelTask(
    "Ace Up Your Sleeve",
    "If you get a hole-in-one on this hole, put a 0 on the scorecard for the hole instead of a 1",
  ),
  WheelTask(
    "Extra Obstacle",
    "Choose an opponent to stand on the course as an extra obstacle for your first shot (opponent chooses location)",
  ),
  WheelTask(
    "Get Back",
    "Choose an opponent to attempt his/her first shot holding the putter behind his/her back",
  ),
  WheelTask("Blind Putt", "Attempt your first shot with your eyes closed"),
  WheelTask(
    "Hands On",
    "Use only your hand to hit the ball on your first shot",
  ),
  WheelTask(
    "Runaway Ball",
    "After everyone has taken their first shot, move an opponent's ball anywhere on the hole (must stay in bounds)",
  ),
  WheelTask(
    "Reverse Course",
    "Play the hole backwards, starting from the hole and ending at the tee",
  ),
  WheelTask(
    "No Putter",
    "Use a different club to hit the ball on your first shot (no putter allowed)",
  ),
  WheelTask(
    "Obstacle Course",
    "Choose an opponent to create an obstacle for your first shot (e.g., standing in the way, holding a club in the air)",
  ),
];
