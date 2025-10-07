import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:my_app32/features/devices/pages/device_page.dart';
import 'package:my_app32/features/groups/pages/group_page.dart';
import 'package:my_app32/features/main/pages/home/home_page.dart';
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
            // 🔹 بخش لوگو با گرادینت و لوگوی وسط
            DrawerHeader(
              padding: EdgeInsets.zero,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF007DC0),
                    Color(0xFF00B8E7),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // لوگوی وسط
                  Expanded(
                    child: Center(
                      child: SvgPicture.asset(
                        'assets/svg/Login.svg',
                        width: 100,
                        height: 80,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  // سه SVG زیر لوگو
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

            // 🔹 داشبورد
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
              onTap: () {
                Navigator.pop(context);
                Get.to(() => const HomePage());
              },
            ),

            // 🔹 دستگاه‌ها
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
              onTap: () {
                Navigator.pop(context);
                Get.to(() => const DevicesPage());
              },
            ),

            // 🔹 سناریوها
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

            // 🔹 گروه‌ها
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
              onTap: () {
                Navigator.pop(context);
                Get.to(() => GroupsPage());
              },
            ),

            const Divider(),
          ],
        ),
      ),
    );
  }
}
