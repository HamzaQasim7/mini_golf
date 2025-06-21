import 'package:flutter/material.dart';

// Custom painter for golf ball dimples
class GolfBallDimplesPainter extends CustomPainter {
  final Color ballColor;

  GolfBallDimplesPainter(this.ballColor);

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = ballColor.withOpacity(0.3)
          ..style = PaintingStyle.fill;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Draw multiple small circles to simulate golf ball dimples
    final dimplePositions = [
      Offset(center.dx - 8, center.dy - 6),
      Offset(center.dx + 4, center.dy - 8),
      Offset(center.dx - 2, center.dy + 2),
      Offset(center.dx + 8, center.dy + 4),
      Offset(center.dx - 6, center.dy + 8),
      Offset(center.dx + 2, center.dy - 2),
    ];

    for (final position in dimplePositions) {
      canvas.drawCircle(position, 1.5, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
