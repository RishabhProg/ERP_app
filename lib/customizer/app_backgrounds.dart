import 'package:flutter/material.dart';
import 'background_config.dart';

class AppBackgrounds {
  AppBackgrounds._();

  static const List<BackgroundConfig> all = [
    BackgroundConfig.lottie(path: "assets/night.json"),
    //BackgroundConfig.lottie(path: "assets/planet.json"),
    BackgroundConfig.lottie(path: "assets/train.json", dimAmount: 0.3),
    BackgroundConfig.lottie(path: "assets/valley.json", dimAmount: 0.3),

    BackgroundConfig.gradient(
      colors: [Color(0xFF141840), Color(0xFF020617), Color(0xFF1C1736)],
      gradientStops: [0.0, 0.5, 1.0],
    ),
    BackgroundConfig.gradient(
      colors: [Color(0xFF0f2027), Color(0xFF203a43), Color(0xFF2c5364)],
      gradientStops: [0.0, 0.5, 1.0],
    ),
    BackgroundConfig.gradient(
      colors: [Color(0xFF200122), Color(0xFF6f0000), Color(0xFF200122)],
      gradientStops: [0.0, 0.5, 1.0],
    ),
    BackgroundConfig.gradient(
      colors: [Color(0xFF0d2b1a), Color(0xFF134e5e), Color(0xFF071a10)],
      gradientStops: [0.0, 0.5, 1.0],
    ),
    BackgroundConfig.gradient(
      colors: [Color(0xFF1a0533), Color(0xFF0d001a), Color(0xFF2d0657)],
      gradientStops: [0.0, 0.5, 1.0],
    ),

  ];
}