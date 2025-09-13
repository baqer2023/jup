import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/smart_light_controller.dart';
import '../constants/constants.dart';
import 'color_dot.dart';
import 'reusable_button.dart';

class ColorPickerSheet extends StatelessWidget {
  final SmartLightController controller;

  const ColorPickerSheet({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Select Color',
                style: Get.textTheme.titleLarge,
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => controller.onPanelClosed(),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ColorDot(
                isSelected: controller.selectedIndex.value == 0,
                color: const Color(0xFF2196F3),
                index: 0,
                model: controller,
              ),
              ColorDot(
                isSelected: controller.selectedIndex.value == 1,
                color: const Color(0xFF4CAF50),
                index: 1,
                model: controller,
              ),
              ColorDot(
                isSelected: controller.selectedIndex.value == 2,
                color: const Color(0xFFFFEB3B),
                index: 2,
                model: controller,
              ),
              ColorDot(
                isSelected: controller.selectedIndex.value == 3,
                color: const Color(0xFF2196F3),
                index: 3,
                model: controller,
              ),
            ],
          ),
          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton(
                onPressed: () => controller.onPanelClosed(),
                child: Text(
                  'Cancel',
                  style: Get.textTheme.titleMedium?.copyWith(
                    color: const Color(0xFF464646),
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  controller.onPanelClosed();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF464646),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Text(
                  'Set Color',
                  style: Get.textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
