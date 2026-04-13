import 'package:flutter/material.dart';

enum BackgroundType { lottie, gradient, image }

class BackgroundConfig {
  final BackgroundType type;
  final String? lottiePath;
  final List<Color>? gradientColors;
  final List<double>? gradientStops;
  final String? imagePath;
  final BoxFit fit;
  final double dimAmount;

  const BackgroundConfig.lottie({
    required String path,
    this.fit = BoxFit.cover,
    this.dimAmount = 0.0,
  })  : type = BackgroundType.lottie,
        lottiePath = path,
        gradientColors = null,
        gradientStops = null,
        imagePath = null;

  const BackgroundConfig.image({
    required String path,
    this.fit = BoxFit.cover,
    this.dimAmount = 0.0
  })  : type = BackgroundType.image,
        imagePath = path,
        gradientColors = null,
        gradientStops = null,
        lottiePath = null;

  const BackgroundConfig.gradient({
    required List<Color> colors,
    List<double>? gradientStops,
    this.dimAmount = 0.0,
    this.fit = BoxFit.cover,
  })  : type = BackgroundType.gradient,
        gradientColors = colors,
        gradientStops = gradientStops,
        lottiePath = null,
        imagePath = null;
}