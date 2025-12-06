// Sidebar
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:my_app32/features/devices/pages/device_page.dart';
import 'package:my_app32/features/groups/pages/group_page.dart';
import 'package:my_app32/features/main/pages/home/home_page.dart';
import 'package:my_app32/features/main/pages/main/main_controller.dart';
import 'package:my_app32/features/main/repository/home_repository.dart';
import 'package:my_app32/core/lang/lang.dart';

class Sidebar extends StatelessWidget {
  const Sidebar({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(HomeRepositoryImpl());
    final controller = Get.put(MainController(Get.find<HomeRepository>()));

    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            color: Colors.white,
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 120,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF007DC0), Color(0xFF00B8E7)],
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

          // آیتم‌ها
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildSidebarItemWithDivider(context, 'dashboard', () {
                  Navigator.pop(context);
                  Get.to(() => HomePage());
                }),
                _buildSidebarItemWithDivider(context, 'devices', () {
                  Navigator.pop(context);
                  Get.to(() => DevicesPage());
                }),
                _buildSidebarItemWithDivider(context, 'groups', () {
                  Navigator.pop(context);
                  Get.to(() => GroupsPage());
                }, showDivider: false),

                // گزینه تغییر زبان
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Obx(() {
                    final isFa = Lang.current.value == 'fa';
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () async => Lang.setLocale('fa'),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: isFa ? Colors.blue : Colors.grey.shade300,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  'FA',
                                  style: TextStyle(
                                    color: isFa ? Colors.white : Colors.black87,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: () async => Lang.setLocale('en'),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: !isFa ? Colors.blue : Colors.grey.shade300,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  'EN',
                                  style: TextStyle(
                                    color: !isFa ? Colors.white : Colors.black87,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  }),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
Widget _buildSidebarItemWithDivider(
  BuildContext context,
  String key,
  VoidCallback onTap, {
  bool showDivider = true,
}) {
  return Obx(() {
    final isRtl = Lang.textDirection.value == TextDirection.rtl;
    
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (isRtl) ...[
                  // انگلیسی (RTL): ایکون سمت چپ + فاصله + متن سمت راست
                  Icon(
                    Icons.arrow_back_ios,
                    size: 16,
                    color: Colors.black54,
                  ),
                  Expanded(
                    child: Text(
                      Lang.t(key),
                      textAlign: TextAlign.left, // متن بچسبه به راست
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ] else ...[
                  // فارسی (LTR): ایکون اول + فاصله + متن بعد
                  Icon(
                    Icons.arrow_back_ios,
                    size: 16,
                    color: Colors.black54,
                  ),
                  Expanded(
                    child: Text(
                      Lang.t(key),
                      textAlign: TextAlign.right, // متن بچسبه به راست
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
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
  });
}
}