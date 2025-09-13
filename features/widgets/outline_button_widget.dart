import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_app32/app/theme/app_colors.dart';

class OutlineButtonWidget extends StatelessWidget {
  const OutlineButtonWidget({
    super.key,
    required this.onTap,
    required this.color,
    this.buttonTitle,
    this.child,
    this.height = 48,
  });

  final VoidCallback? onTap;
  final Color color;
  final Widget? child;
  final String? buttonTitle;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        height: height,
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(8)),
            border: Border.all(color: color),
          ),
          child:
              child ??
              Text(
                buttonTitle ?? '',
                style: Get.textTheme.labelLarge!.copyWith(
                  color: AppColors.gray[700],
                ),
              ),
        ),
      ),
    );
  }
}
