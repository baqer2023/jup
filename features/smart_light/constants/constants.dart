import 'package:flutter/material.dart';

class ColorData {
  final Color color;
  final String image;
  final int index;

  ColorData({
    required this.color,
    required this.image,
    required this.index,
  });
}

class Constants {
  static List<ColorData> colors = [
    ColorData(
      color: const Color(0xFF2196F3),
      image: 'assets/images/purple.png',
      index: 0,
    ),
    ColorData(
      color: const Color(0xFF4CAF50),
      image: 'assets/images/green.png',
      index: 1,
    ),
    ColorData(
      color: const Color(0xFFFFC107),
      image: 'assets/images/yellow.png',
      index: 2,
    ),
    ColorData(
      color: const Color(0xFF2196F3),
      image: 'assets/images/blue.png',
      index: 3,
    ),
  ];

  static List<Color> dotColors2 = [
    const Color(0xFFFF5252),
    const Color(0xFFFF9800),
    const Color(0xFF9C27B0),
    const Color(0xFF00BCD4),
  ];
}
