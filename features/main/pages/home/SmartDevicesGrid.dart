import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_app32/app/services/realable_controller.dart';
import 'package:my_app32/features/main/pages/home/SmartDevicesPage.dart';
import 'package:my_app32/features/main/pages/home/home_controller.dart';

class SmartDevicesGrid extends StatelessWidget {
  const SmartDevicesGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();
    final reliableController = Get.isRegistered<ReliableSocketController>(
            tag: 'smartDevicesController')
        ? Get.find<ReliableSocketController>(tag: 'smartDevicesController')
        : Get.put(
            ReliableSocketController(
              controller.token,
              controller.dashboardDevices.map((d) => d.deviceId).toList(),
            ),
            tag: 'smartDevicesController',
            permanent: true,
          );

    reliableController.updateDeviceList(
        controller.dashboardDevices.map((d) => d.deviceId).toList());

    return Obx(() {
      final devices = controller.dashboardDevices;
      if (devices.isEmpty) return const Center(child: Text("هیچ دستگاهی یافت نشد"));

      return ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const ClampingScrollPhysics(),
        itemCount: devices.length,
        itemBuilder: (context, index) {
          final device = devices[index];
          // اینجا میتونی کد _buildSmartDeviceCard رو استفاده کنی
          return SizedBox(width: 280, child: _buildSmartDeviceCard());
        },
      );
    });
  }
  
  Widget? _buildSmartDeviceCard() {
    Padding(
  padding: const EdgeInsets.symmetric(horizontal: 16),
  child: SizedBox(
    height: 280,
    child: SmartDevicesPage(),
  ),
);

  }
}
