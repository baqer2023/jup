import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:my_app32/features/main/pages/main/main_controller.dart';
import 'package:my_app32/features/main/repository/home_repository.dart';

class Sidebar extends StatelessWidget {
  const Sidebar({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(HomeRepositoryImpl());
    final controller = Get.put(MainController(Get.find<HomeRepository>()));

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Drawer(
        backgroundColor: Colors.white,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // بخش لوگو و SVG ها
            DrawerHeader(
              padding: EdgeInsets.zero,
              decoration: const BoxDecoration(color: Colors.white),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // لوگوی اصلی کل عرض
                  SvgPicture.asset(
                    'assets/svg/jupin.svg',
                    fit: BoxFit.fill,
                    width: double.infinity,
                    height: 80,
                  ),
                  // سه SVG روی هم و عرض کامل
                  SizedBox(
                    height: 60,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        SvgPicture.asset('assets/svg/1.svg', fit: BoxFit.fill),
                        SvgPicture.asset('assets/svg/2.svg', fit: BoxFit.fill),
                        SvgPicture.asset('assets/svg/3.svg', fit: BoxFit.fill),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // آیتم‌های سایدبار
            ListTile(
              leading: const Icon(Icons.dashboard, color: Colors.black87),
              title: const Text(
                'داشبورد',
                style: TextStyle(
                  color: Colors.black87,
                  fontFamily: 'IranYekan',
                ),
                textAlign: TextAlign.right,
              ),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.devices, color: Colors.black87),
              title: const Text(
                'دستگاه‌ها',
                style: TextStyle(
                  color: Colors.black87,
                  fontFamily: 'IranYekan',
                ),
                textAlign: TextAlign.right,
              ),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.edit_calendar_outlined, color: Colors.black87),
              title: const Text(
                'سناریوها',
                style: TextStyle(
                  color: Colors.black87,
                  fontFamily: 'IranYekan',
                ),
                textAlign: TextAlign.right,
              ),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.person, color: Colors.black87),
              title: const Text(
                'مشتری‌ها',
                style: TextStyle(
                  color: Colors.black87,
                  fontFamily: 'IranYekan',
                ),
                textAlign: TextAlign.right,
              ),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.group, color: Colors.black87),
              title: const Text(
                'گروه‌ها',
                style: TextStyle(
                  color: Colors.black87,
                  fontFamily: 'IranYekan',
                ),
                textAlign: TextAlign.right,
              ),
              onTap: () {},
            ),
            const Divider(),
            // آیتم خروج
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.redAccent),
              title: const Text(
                'خروج',
                style: TextStyle(
                  color: Colors.redAccent,
                  fontFamily: 'IranYekan',
                ),
                textAlign: TextAlign.right,
              ),
              onTap: () => controller.onTapLogOut(),
            ),
          ],
        ),
      ),
    );
  }
}
