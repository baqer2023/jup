import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/smart_light_controller.dart';

class ColorDot extends StatelessWidget {
  final bool isSelected;
  final Color color;
  final int index;
  final SmartLightController model;

  const ColorDot({
    Key? key,
    required this.isSelected,
    required this.color,
    required this.index,
    required this.model,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => model.changeColor(currentIndex: index),
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
          border: Border.all(
            color: isSelected ? const Color(0xFF464646) : Colors.transparent,
            width: 2,
          ),
        ),
      ),
    );
  }
} 