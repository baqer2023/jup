import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_app32/app/core/base/base_view.dart';
import 'package:my_app32/app/theme/app_colors.dart';
import 'package:my_app32/features/main/pages/more/more_controller.dart';
import 'package:my_app32/features/widgets/app_bar_widget.dart';

class MorePage extends BaseView<MoreController> {
  const MorePage({super.key});

  @override
  Widget body() {
    return Column(
      children: [
        controller.isLoading.value ? const SizedBox() : const SizedBox(),
        const AppBarWidget(title: 'More', showBackButton: false),
        const SizedBox(height: 24),
        Container(
          width: Get.width,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.gray[300],
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const CircleAvatar(
                radius: 40,
                backgroundColor: AppColors.primaryColor,
                child: Icon(Icons.person, color: Colors.white, size: 40),
              ),
              const SizedBox(height: 24),
              Text(controller.userName, style: Get.textTheme.titleLarge),
            ],
          ),
        ),
        const SizedBox(height: 16),
        ListTile(
          leading: Icon(Icons.logout, color: AppColors.gray[900]),
          title: Text(
            'Logout',
            style: Get.textTheme.bodyLarge!.copyWith(color: Colors.red),
          ),
          onTap: () => controller.onTapLogOut(),
        ),
      ],
    );
  }
}
