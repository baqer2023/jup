import 'package:flutter/material.dart';

class ColorModel {
  final Color color;
  final String image;
  final int index;

  ColorModel({
    required this.color,
    required this.image,
    required this.index,
  });
}

class Constants {
  static final List<ColorModel> colors = [
    ColorModel(
      color: const Color(0xFF2196F3),
      image: 'assets/images/purple.png',
      index: 0,
    ),
    ColorModel(
      color: const Color(0xFF4CAF50),
      image: 'assets/images/green.png',
      index: 1,
    ),
    ColorModel(
      color: const Color(0xFFFFC107),
      image: 'assets/images/yellow.png',
      index: 2,
    ),
    ColorModel(
      color: const Color(0xFF2196F3),
      image: 'assets/images/blue.png',
      index: 3,
    ),
  ];

  static final List<Color> dotColors2 = [
    const Color(0xFFFF5252),
    const Color(0xFFFF9800),
    const Color(0xFFE91E63),
    const Color(0xFF9C27B0),
  ];
}
