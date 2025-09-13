import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:my_app32/app/core/app_icons.dart';
import 'package:my_app32/app/theme/app_colors.dart';
import 'package:my_app32/features/widgets/fill_button_widget.dart';
import 'package:my_app32/features/widgets/outline_button_widget.dart';

class AppDialog {
  AppDialog({
    required this.title,
    required this.subTitle,
    this.icon = AppIcons.icWarning,
    this.mainTask,
    this.otherTask,
    this.otherTaskTitle,
    this.mainTaskTitle,
  });

  String title;
  String subTitle;
  String icon;
  VoidCallback? mainTask;
  VoidCallback? otherTask;
  String? mainTaskTitle;
  String? otherTaskTitle;

  Future<void> showAppDialog() async {
    return Get.dialog(
      barrierDismissible: true,
      PopScope(
        canPop: false,
        child: AlertDialog(
          backgroundColor: AppColors.backgroundColor,
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SvgPicture.asset(icon),
                const SizedBox(height: 10),
                Text(title, style: Get.textTheme.titleMedium),
                const SizedBox(height: 8),
                Text(
                  subTitle,
                  style: Get.textTheme.bodyMedium!.copyWith(
                    color: AppColors.gray[300],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            ConstrainedBox(
              constraints: const BoxConstraints.tightFor(
                width: double.infinity,
                height: 48,
              ),
              child: otherTask != null
                  ? Row(
                      children: [
                        Expanded(
                          child: OutlineButtonWidget(
                            height: 36,
                            color: AppColors.gray[300]!,
                            onTap: () => otherTask!(),
                            child: Text(
                              otherTaskTitle!,
                              style: Get.textTheme.labelLarge,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FillButtonWidget(
                            height: 36,
                            isLoading: false,
                            onTap: () =>
                                mainTask == null ? Get.back() : mainTask!(),
                            buttonTitle: mainTaskTitle ?? 'Done',
                          ),
                        ),
                      ],
                    )
                  : FillButtonWidget(
                      height: 36,
                      isLoading: false,
                      onTap: () => mainTask == null ? Get.back() : mainTask!(),
                      buttonTitle: mainTaskTitle ?? 'Done',
                    ),
            ),
          ],
          actionsPadding: const EdgeInsets.only(
            right: 24,
            left: 24,
            bottom: 24,
          ),
        ),
      ),
    );
  }
}
