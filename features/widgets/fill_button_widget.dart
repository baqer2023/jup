import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:my_app32/app/theme/app_colors.dart';

class FillButtonWidget extends StatelessWidget {
  const FillButtonWidget({
    super.key,
    required this.isLoading,
    required this.onTap,
    required this.buttonTitle,
    this.buttonColor = AppColors.primaryColor,
    this.enable = true,
    this.height = 48,
  });

  final bool isLoading;
  final bool enable;
  final VoidCallback onTap;
  final String buttonTitle;
  final Color buttonColor;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enable && !isLoading ? onTap : null,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          height: height,
          width: Get.width,
          decoration: BoxDecoration(
            color: enable
                ? buttonColor
                : AppColors.primaryColor.withOpacity(0.3),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: isLoading
                ? SpinKitFadingCircle(
                    itemBuilder: (_, int index) {
                      return const DecoratedBox(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                      );
                    },
                    size: 24.0,
                  )
                : Center(
                    child: Text(
                      buttonTitle,
                      style: Get.textTheme.labelLarge!.copyWith(
                        color: enable
                            ? AppColors.gray[25]
                            : AppColors.gray[400],
                      ),
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
