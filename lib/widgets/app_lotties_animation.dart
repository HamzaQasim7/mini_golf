import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class AppLottieAnimation extends StatelessWidget {
  final String assetPath;
  final double? width;
  final double? height;
  final BoxFit fit;
  final bool repeat;
  final bool animate;
  final Alignment alignment;
  final void Function(LottieComposition)? onLoaded;
  final bool isNetwork;

  const AppLottieAnimation({
    super.key,
    required this.assetPath,
    this.width,
    this.height,
    this.fit = BoxFit.none,
    this.repeat = true,
    this.animate = true,
    this.alignment = Alignment.center,
    this.onLoaded,
    this.isNetwork = false,
  });

  @override
  Widget build(BuildContext context) {
    final lottieWidget =
        isNetwork
            ? Lottie.network(
              assetPath,
              width: width,
              height: height,
              fit: fit,
              repeat: repeat,
              animate: animate,
              alignment: alignment,
              onLoaded: onLoaded,
            )
            : Lottie.asset(
              assetPath,
              width: width,
              height: height,
              fit: fit,
              repeat: repeat,
              animate: animate,
              alignment: alignment,
              onLoaded: onLoaded,
            );

    return Center(child: lottieWidget);
  }
}
