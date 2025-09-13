import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:my_app32/features/main/pages/alarms/alarms_page.dart';
import 'package:my_app32/features/main/pages/devices/devices_page.dart';
import 'package:my_app32/features/main/pages/home/home_page.dart';
import 'package:my_app32/features/main/pages/more/more_page.dart';
import 'package:my_app32/features/main/repository/home_repository.dart';
import 'main_controller.dart'; // Import MainController

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MainController(HomeRepositoryImpl()));

    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: PageView(
              controller: controller.pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: const [
                HomePage(),
                AlarmsPage(),
                DevicesPage(),
                MorePage(),
              ],
            ),
          ),
          _buildCustomNavBar(context, controller),
        ],
      ),
    );
  }

  Widget _buildCustomNavBar(BuildContext context, MainController controller) {
    return SizedBox(
      height: 94,
      width: 440,
      child: Stack(
        alignment: Alignment.center,
        children: [
          IconButton(
            onPressed: () {
              controller.showCustomModal(context);
            },
            icon: SvgPicture.asset(
              'assets/icons/add_newdevide.svg',
              width: 440,
              height: 94,
            ),
          ),
        ],
      ),
    );
  }
}
