import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ReusableButton extends StatelessWidget {
  final String buttonText;
  final bool active;
  final VoidCallback onPress;

  const ReusableButton({
    Key? key,
    required this.buttonText,
    required this.active,
    required this.onPress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return active
        ? ElevatedButton(
            onPressed: onPress,
            child: Text(
              buttonText,
              style: Get.textTheme.displayMedium?.copyWith(
                color: Colors.white,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF464646),
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          )
        : OutlinedButton(
            onPressed: onPress,
            child: Text(
              buttonText,
              style: Get.textTheme.displayMedium,
            ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
  }
} 