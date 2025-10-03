import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_app32/app/routes/app_routes.dart';
import 'package:my_app32/features/main/pages/home/profile.dart';
import 'package:my_app32/app/store/user_store_service.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final RxBool isRefreshing;

  const CustomAppBar({Key? key, required this.isRefreshing}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      titleSpacing: 0,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          /// آیکون خروج
          IconButton(
            onPressed: () {
              _handleLogout(context);
            },
            icon: const Icon(Icons.logout, color: Colors.white, size: 28),
          ),

          /// آیکون پروفایل
          FutureBuilder<String?>(
            future: UserStoreService.to.getToken(),
            builder: (context, snapshot) {
              final token = snapshot.data ?? '';
              return GestureDetector(
                onTap: () {
                  if (token.isNotEmpty) {
                    ProfilePage.showProfileDialog(token);
                  }
                },
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4),
                  child: Icon(Icons.account_circle, size: 32, color: Colors.white),
                ),
              );
            },
          ),

          /// آیکون اعلان‌ها
          IconButton(
            onPressed: () {
              _handleNotifications(context);
            },
            icon: const Icon(Icons.notifications, color: Colors.white, size: 28),
          ),

          /// اگر حالت بروزرسانی فعال بود
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
                        Text(
                          'بروزرسانی',
                          style: TextStyle(fontSize: 10, color: Colors.blue, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
              ],
            );
          }),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  /// هندل خروج
void _handleLogout(BuildContext context) {
  Get.defaultDialog(
    title: "خروج",
    titleStyle: const TextStyle(
      color: Colors.black,
      fontWeight: FontWeight.bold,
      fontSize: 18,
    ),
    middleText: "آیا مطمئن هستید که می‌خواهید خارج شوید؟",
    middleTextStyle: const TextStyle(
      color: Colors.black87,
      fontSize: 14,
    ),
    backgroundColor: Colors.white,
    textCancel: "خیر",
    textConfirm: "بله",
    confirmTextColor: Colors.white,
    cancelTextColor: Colors.black,
    buttonColor: Colors.blue, // رنگ دکمه تأیید
    onConfirm: () async {
  Get.back(); // اینو await نزن چون void هست
  await UserStoreService.to.deleteToken();
  await UserStoreService.to.deleteRefreshToken();
  Get.offAllNamed(AppRoutes.LOGIN);
}

,
  );
}


  /// هندل اعلان‌ها
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
