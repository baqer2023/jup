import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_app32/app/theme/app_colors.dart';
import 'package:my_app32/features/widgets/fill_button_widget.dart';
import 'package:my_app32/features/widgets/outline_button_widget.dart';

class BottomSheetWidget extends StatelessWidget {
  const BottomSheetWidget({
    super.key,
    required this.onTapSave,
    required this.title,
  });

  final VoidCallback onTapSave;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 12),
            Container(
              height: 4,
              width: 32,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: AppColors.gray[300],
              ),
            ),
            const SizedBox(height: 24),
            Align(
              alignment: Alignment.centerRight,
              child: Text(title, style: Get.textTheme.titleLarge),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 48),
                child: Text(
                  title,
                  style: Get.textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Row(
                children: [
                  Expanded(
                    child: OutlineButtonWidget(
                      onTap: () => Get.back(),
                      buttonTitle: 'بازگشت',
                      color: AppColors.gray[300]!,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FillButtonWidget(
                      isLoading: false,
                      onTap: () => onTapSave(),
                      buttonTitle: 'ذخیره',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
