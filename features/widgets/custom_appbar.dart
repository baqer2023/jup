import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:my_app32/app/routes/app_routes.dart';
import 'package:my_app32/features/main/pages/home/profile.dart';
import 'package:my_app32/app/store/user_store_service.dart';
import 'package:my_app32/core/lang/lang.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final RxBool isRefreshing;

  const CustomAppBar({Key? key, required this.isRefreshing}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const double iconHeight = 28;
    const double iconWidth = 28;
    const double spaceBetweenIconAndText = 4;

    Widget buildIconWithText({required Widget icon, required String label, VoidCallback? onTap}) {
      return GestureDetector(
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: iconHeight,
              width: iconWidth,
              child: icon,
            ),
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
            /// آیکون خروج
            buildIconWithText(
              icon: SvgPicture.asset(
                'assets/svg/logout.svg',
                color: Colors.white,
              ),
              label: Lang.t('logout'), // 🔹 چندزبانه
              onTap: () => _handleLogout(context),
            ),

            const SizedBox(width: 20),

            /// آیکون پروفایل
            FutureBuilder<String?>(
              future: UserStoreService.to.getToken(),
              builder: (context, snapshot) {
                final token = snapshot.data ?? '';
                return buildIconWithText(
                  icon: SvgPicture.asset(
                    'assets/svg/profile.svg',
                    color: Colors.white,
                  ),
                  label: Lang.t('profile'), // 🔹 چندزبانه
                  onTap: () {
                    if (token.isNotEmpty) {
                      ProfilePage.showProfileDialog(token);
                    }
                  },
                );
              },
            ),

            const SizedBox(width: 20),

            /// آیکون اعلان‌ها
            buildIconWithText(
              icon: SvgPicture.asset(
                'assets/svg/bell.svg',
                color: Colors.white,
              ),
              label: Lang.t('notifications'), // 🔹 چندزبانه
              onTap: () => _handleNotifications(context),
            ),

            const SizedBox(width: 20),

            /// بروزرسانی
            Obx(() {
              return Row(
                children: [
                  if (isRefreshing.value)
                    Container(
                      margin: const EdgeInsets.only(left: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blue, width: 1),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          SizedBox(
                            width: 12,
                            height: 12,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                            ),
                          ),
                          SizedBox(width: 4),
                        ],
                      ),
                    ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  void _handleLogout(BuildContext context) {
    Get.defaultDialog(
      title: Lang.t('logout'), // 🔹 چندزبانه
      titleStyle: const TextStyle(
        color: Colors.black,
        fontWeight: FontWeight.bold,
        fontSize: 18,
      ),
      middleText: Lang.t('confirm_logout'), // 🔹 چندزبانه
      middleTextStyle: const TextStyle(
        color: Colors.black87,
        fontSize: 14,
      ),
      backgroundColor: Colors.white,
      textCancel: Lang.t('no'), // 🔹 چندزبانه
      textConfirm: Lang.t('yes'), // 🔹 چندزبانه
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
      Lang.t('notifications'), // 🔹 چندزبانه
      Lang.t('no_new_notifications'), // 🔹 چندزبانه
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.blue.shade600,
      colorText: Colors.white,
    );
  }
}