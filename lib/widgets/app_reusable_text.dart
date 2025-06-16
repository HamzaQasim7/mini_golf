import 'package:flutter/material.dart';

import '../core/theme/app_text_style.dart';

class AppReusableText extends StatelessWidget {
  const AppReusableText({
    super.key,
    required this.text,
    this.fontWeight,
    this.fontSize,
    this.color,
    this.textAlignment = TextAlign.start,
    this.maxLines = 1,
  });

  final String text;
  final FontWeight? fontWeight;
  final double? fontSize;
  final Color? color;
  final TextAlign textAlignment;
  final int? maxLines;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      overflow: TextOverflow.ellipsis,
      textAlign: textAlignment,
      maxLines: maxLines,
      style: AppTextStyles.h2.copyWith(
        fontWeight: fontWeight,
        fontSize: fontSize,
        color: color,
      ),
    );
  }
}
