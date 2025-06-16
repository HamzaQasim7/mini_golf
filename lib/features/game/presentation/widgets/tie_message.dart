import 'package:flutter/material.dart';

class TieMessage extends StatelessWidget {
  final String message;
  final Color? textColor;
  final double fontSize;
  final EdgeInsetsGeometry padding;

  const TieMessage({
    super.key,
    required this.message,
    this.textColor = Colors.white70,
    this.fontSize = 15.0,
    this.padding = const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: textColor,
          fontSize: fontSize,
          height: 1.4, // For better line spacing
        ),
      ),
    );
  }
}
