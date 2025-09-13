import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/smart_light_controller.dart';
import '../../../config/size_config.dart';

class Body extends StatelessWidget {
  final SmartLightController controller;
  
  const Body({Key? key, required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          // Power
          Text(
            'Power',
            style: Get.textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Obx(() => Switch(
                value: controller.isOn.value,
                onChanged: controller.togglePower,
                activeColor: const Color(0xFF464646),
              )),
          const SizedBox(height: 24),
          // Color
          Text(
            'Color',
            style: Get.textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: controller.onColorTap,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: controller.selectedColor.value,
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFF464646),
                  width: 2,
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),
          // Tone Glow
          Text(
            'Tone Glow',
            style: Get.textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF464646),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        bottomLeft: Radius.circular(20),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        'Warm',
                        style: Get.textTheme.titleMedium?.copyWith(color: Colors.white),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(20),
                        bottomRight: Radius.circular(20),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        'Cold',
                        style: Get.textTheme.titleMedium,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          // Intensity
          Text(
            'Intensity',
            style: Get.textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Off', style: Get.textTheme.bodySmall),
              Obx(() => Text('${controller.intensity.value.toInt()}%', style: Get.textTheme.bodySmall)),
              Text('100%', style: Get.textTheme.bodySmall),
            ],
          ),
          Obx(() => Slider(
                value: controller.intensity.value,
                min: 0,
                max: 100,
                onChanged: controller.changeIntensity,
                activeColor: const Color(0xFF464646),
                inactiveColor: const Color(0xFFBDBDBD),
              )),
        ],
      ),
    );
  }
} 