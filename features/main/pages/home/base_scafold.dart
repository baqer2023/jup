import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_app32/app/store/user_store_service.dart';
import 'package:my_app32/features/main/pages/home/profile.dart';
import 'package:my_app32/features/widgets/sidebar.dart';

class BaseScaffold extends StatelessWidget {
  final Widget body;
  final String title;
  final List<Widget>? actions; // دکمه‌های اضافی سفارشی

  const BaseScaffold({
    required this.body,
    required this.title,
    this.actions,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      endDrawer: const Sidebar(),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Row(
          children: [
            // 🔹 دکمه خروج
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () {
                // TODO: عملیات خروج
              },
            ),

            // 🔹 آیکون پروفایل با FutureBuilder برای async token
  FutureBuilder<String?>(
  future: UserStoreService.to.getToken(),
  builder: (context, snapshot) {
    final token = snapshot.data ?? ''; // اگر null بود، رشته خالی
    return IconButton(
      icon: const Icon(Icons.account_circle),
      onPressed: () {
        ProfilePage.showProfileDialog(token);
      },
    );
  },
),


            // 🔹 اعلان
            IconButton(
              icon: const Icon(Icons.notifications),
              onPressed: () {
                // TODO: رفتن به صفحه اعلان‌ها
              },
            ),

            // 🔹 دکمه‌های اضافی (معکوس شده)
            if (actions != null) ...actions!.reversed,

            const Spacer(),

            // 🔹 عنوان سمت راست
            Text(title),
          ],
        ),
        automaticallyImplyLeading: false,
      ),
      body: body,
    );
  }
}
