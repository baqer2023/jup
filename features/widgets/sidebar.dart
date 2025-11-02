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
        child: Column(
          children: [
            // 🔹 Header مشابه لاگین، بدون خط زیرش
            Container(
              width: double.infinity,
              color: Colors.white,
              child: Column(
                children: [
                  // گرادینت + لوگو
                  SizedBox(
                    width: double.infinity,
                    height: 120,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Container(
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
                        ),
                        Center(
                          child: SvgPicture.asset(
                            'assets/svg/Login.svg',
                            width: 120,
                            height: 80,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // سه SVG زیر لوگو
                  SizedBox(
                    height: 60,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        SvgPicture.asset('assets/svg/logo1.svg', fit: BoxFit.fill),
                        SvgPicture.asset('assets/svg/logo2.svg', fit: BoxFit.fill),
                        SvgPicture.asset('assets/svg/logo3.svg', fit: BoxFit.fill),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // 🔹 لیست آیتم‌ها — بدون هیچ فاصله یا خط اضافی زیر هدر
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _buildSidebarItemWithDivider(context, 'داشبورد', () {
                    Navigator.pop(context);
                    Get.to(() =>  HomePage());
                  }),
                  _buildSidebarItemWithDivider(context, 'دستگاه‌ها', () {
                    Navigator.pop(context);
                    Get.to(() =>  DevicesPage());
                  }),
                  _buildSidebarItemWithDivider(context, 'سناریوها', () {}),
                  _buildSidebarItemWithDivider(context, 'گروه‌ها', () {
                    Navigator.pop(context);
                    Get.to(() => GroupsPage());
                  }, showDivider: false),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSidebarItemWithDivider(
    BuildContext context,
    String label,
    VoidCallback onTap, {
    bool showDivider = true,
  }) {
    return Column(
      children: [
        ListTile(
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          title: Text(
            label,
            textAlign: TextAlign.right,
            style: const TextStyle(
              color: Colors.black87,
              fontFamily: 'IranYekan',
            ),
          ),
          onTap: onTap,
        ),
        if (showDivider)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Divider(
              color: Colors.grey.shade300,
              thickness: 1,
              height: 1,
            ),
          ),
      ],
    );
  }
}
