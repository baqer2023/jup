import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:my_app32/app/routes/app_routes.dart';
import 'package:my_app32/features/main/pages/home/profile.dart';
import 'package:my_app32/app/store/user_store_service.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final RxBool isRefreshing;

  const CustomAppBar({Key? key, required this.isRefreshing}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const double iconHeight = 28;
    const double iconWidth = 28;
    const double spaceBetweenIconAndText = 4;

    Widget buildIconWithText({
      required Widget icon,
      required String label,
      VoidCallback? onTap,
    }) {
      return GestureDetector(
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: iconHeight, width: iconWidth, child: icon),
            const SizedBox(height: spaceBetweenIconAndText),
            Text(
              label,
              style: const TextStyle(fontSize: 10, color: Colors.white),
            ),
          ],
        ),
      );
    }

    return AppBar(
      titleSpacing: 0,
      title: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            buildIconWithText(
              icon: SvgPicture.asset(
                'assets/svg/logout.svg',
                color: Colors.white,
              ),
              label: 'خروج',
              onTap: () => _handleLogout(context),
            ),
            const SizedBox(width: 20),
            FutureBuilder<String?>(
              future: UserStoreService.to.getToken(),
              builder: (context, snapshot) {
                final token = snapshot.data ?? '';
                return buildIconWithText(
                  icon: SvgPicture.asset(
                    'assets/svg/profile.svg',
                    color: Colors.white,
                  ),
                  label: 'پروفایل',
                  onTap: () {
                    if (token.isNotEmpty) {
                      ProfilePage.showProfileDialog(token);
                    }
                  },
                );
              },
            ),
            const SizedBox(width: 20),
            buildIconWithText(
              icon: SvgPicture.asset(
                'assets/svg/bell.svg',
                color: Colors.white,
              ),
              label: 'اعلان‌ها',
              onTap: () => _handleNotifications(context),
            ),
            const SizedBox(width: 20),

            /// اگر حالت بروزرسانی فعال بود
            Obx(() {
              if (isRefreshing.value) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _showRefreshingDialog(context);
                });
              }
              return const SizedBox.shrink();
            }),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  void _showRefreshingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset(
                'assets/svg/no internet.svg',
                width: 150,
                height: 150,
              ),
              const SizedBox(height: 20),
              const Text(
                'در حال بروزرسانی...\nلطفاً کمی صبر کنید',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.black87),
              ),
              const SizedBox(height: 20),
              const LinearProgressIndicator(minHeight: 6),
            ],
          ),
        ),
      ),
    );

    // بعد از ۱۵ ثانیه خودکار دیالوگ بسته می‌شود
    Future.delayed(const Duration(seconds: 15), () {
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
        isRefreshing.value = false; // پروگرس بار هم غیرفعال شود
      }
    });
  }

  void _handleLogout(BuildContext context) {
    Get.defaultDialog(
      title: "خروج",
      titleStyle: const TextStyle(
        color: Colors.black,
        fontWeight: FontWeight.bold,
        fontSize: 18,
      ),
      middleText: "آیا مطمئن هستید که می‌خواهید خارج شوید؟",
      middleTextStyle: const TextStyle(color: Colors.black87, fontSize: 14),
      backgroundColor: Colors.white,
      textCancel: "خیر",
      textConfirm: "بله",
      confirmTextColor: Colors.white,
      cancelTextColor: Colors.black,
      buttonColor: Colors.blue,
      onConfirm: () async {
        Get.back();
        await UserStoreService.to.deleteToken();
        await UserStoreService.to.deleteRefreshToken();
        Get.offAllNamed(AppRoutes.LOGIN);
      },
    );
  }

  void _handleNotifications(BuildContext context) {
    Get.snackbar(
      "اعلان‌ها",
      "هیچ اعلان جدیدی ندارید",
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.blue.shade600,
      colorText: Colors.white,
    );
  }
}
