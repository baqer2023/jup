import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:dio/dio.dart';
import 'package:my_app32/app/services/realable_controller.dart';
import 'package:my_app32/features/main/models/home/device_item_model.dart';
import 'package:my_app32/features/main/pages/home/home_controller.dart';

// فرض: HomeController و ReliableSocketController قبلاً تعریف شدن
// و DeviceItem مدل دستگاه‌هاست

class SmartDevicesPage extends StatelessWidget {
  SmartDevicesPage({Key? key}) : super(key: key);

  final homeController = Get.find<HomeController>();

  @override
  Widget build(BuildContext context) {
    // ثبت ReliableSocketController در صورت عدم وجود
    final reliableController =
        Get.isRegistered<ReliableSocketController>(
          tag: 'smartDevicesController',
        )
        ? Get.find<ReliableSocketController>(tag: 'smartDevicesController')
        : Get.put(
            ReliableSocketController(
              homeController.token,
              homeController.dashboardDevices.map((d) => d.deviceId).toList(),
            ),
            tag: 'smartDevicesController',
            permanent: true,
          );

    // بروز رسانی لیست دستگاه‌ها
    reliableController.updateDeviceList(
      homeController.dashboardDevices.map((d) => d.deviceId).toList(),
    );

    return Scaffold(
      appBar: AppBar(title: const Text("دستگاه‌های هوشمند")),
      body: Obx(() {
        final devices = homeController.dashboardDevices;

        if (devices.isEmpty) {
          return const Center(child: Text("هیچ دستگاهی یافت نشد"));
        }

        return SizedBox(
          height: 280,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const ClampingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 8),
            itemCount: devices.length,
            itemBuilder: (context, index) {
              final device = devices[index];

              return Obx(() {
                final deviceData =
                    reliableController.latestDeviceDataById[device.deviceId];

                bool switch1On = false;
                bool switch2On = false;
                Color iconColor1 = Colors.grey;
                Color iconColor2 = Colors.grey;

                if (deviceData != null) {
                  final key1Entries = [
                    if (deviceData['TW1'] is List) ...deviceData['TW1'],
                    if (deviceData['TD1'] is List) ...deviceData['TD1'],
                  ];
                  if (key1Entries.isNotEmpty) {
                    key1Entries.sort(
                      (a, b) => (b[0] as int).compareTo(a[0] as int),
                    );
                    switch1On = key1Entries.first[1].toString().contains('On');
                  }

                  final key2Entries = [
                    if (deviceData['TW2'] is List) ...deviceData['TW2'],
                    if (deviceData['TD2'] is List) ...deviceData['TD2'],
                  ];
                  if (key2Entries.isNotEmpty) {
                    key2Entries.sort(
                      (a, b) => (b[0] as int).compareTo(a[0] as int),
                    );
                    switch2On = key2Entries.first[1].toString().contains('On');
                  }

                  if (deviceData['ledColor'] is List &&
                      deviceData['ledColor'].isNotEmpty) {
                    final ledEntry = deviceData['ledColor'][0][1];
                    Map<String, dynamic> ledMap = ledEntry is String
                        ? jsonDecode(ledEntry)
                        : (ledEntry as Map<String, dynamic>);

                    iconColor1 = switch1On
                        ? Color.fromARGB(
                            255,
                            ledMap['t1']['on']['r'],
                            ledMap['t1']['on']['g'],
                            ledMap['t1']['on']['b'],
                          )
                        : Color.fromARGB(
                            255,
                            ledMap['t1']['off']['r'],
                            ledMap['t1']['off']['g'],
                            ledMap['t1']['off']['b'],
                          );

                    iconColor2 = switch2On
                        ? Color.fromARGB(
                            255,
                            ledMap['t2']['on']['r'],
                            ledMap['t2']['on']['g'],
                            ledMap['t2']['on']['b'],
                          )
                        : Color.fromARGB(
                            255,
                            ledMap['t2']['off']['r'],
                            ledMap['t2']['off']['g'],
                            ledMap['t2']['off']['b'],
                          );
                  }
                }

                final isSingleKey = device.deviceTypeName == 'key-1';

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: SizedBox(
                    width: 280,
                    child: _buildSmartDeviceCard(
                      device: device,
                      switch1On: switch1On,
                      switch2On: switch2On,
                      iconColor1: iconColor1,
                      iconColor2: iconColor2,
                      isSingleKey: isSingleKey,
                      reliableController: reliableController,
                    ),
                  ),
                );
              });
            },
          ),
        );
      }),
    );
  }

  Widget _buildSmartDeviceCard({
    required DeviceItem device,
    required bool switch1On,
    required bool switch2On,
    required Color iconColor1,
    required Color iconColor2,
    required bool isSingleKey,
    required ReliableSocketController reliableController,
  }) {
    bool anySwitchOn = switch1On || (!isSingleKey && switch2On);
    Color borderColor = anySwitchOn
        ? Colors.blue.shade400
        : Colors.grey.shade400;

    return Card(
      color: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: borderColor, width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 48, 12, 12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // سوئیچ‌ها و عنوان
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _buildSwitchRow(
                      deviceId: device.deviceId,
                      switchNumber: 1,
                      color: iconColor1,
                      onToggle: (num, val) async {
                        await reliableController.toggleSwitch(
                          val,
                          num,
                          device.deviceId,
                        );
                      },
                    ),
                    if (!isSingleKey)
                      _buildSwitchRow(
                        deviceId: device.deviceId,
                        switchNumber: 2,
                        color: iconColor2,
                        onToggle: (num, val) async {
                          await reliableController.toggleSwitch(
                            val,
                            num,
                            device.deviceId,
                          );
                        },
                      ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      device.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      device.dashboardTitle ?? "بدون مکان",
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ],
            ),

            // منو و وضعیت آنلاین
            Row(
              children: [
                PopupMenuButton<int>(
                  color: Colors.white,
                  icon: const Icon(Icons.more_vert, color: Colors.black87),
                  onSelected: (value) async {
                    final homeController = Get.find<HomeController>();
                    if (value == 3) {
                      await homeController.removeFromAllDashboard(
                        device.deviceId,
                      );
                      await homeController.refreshAllData();
                      Get.snackbar(
                        'موفقیت',
                        'کلید حذف موقت شد',
                        backgroundColor: Colors.green,
                        colorText: Colors.white,
                      );
                    } else if (value == 4) {
                      await homeController.completeRemoveDevice(
                        device.deviceId,
                      );
                      await homeController.refreshAllData();
                      Get.snackbar(
                        'موفقیت',
                        'دستگاه حذف شد',
                        backgroundColor: Colors.green,
                        colorText: Colors.white,
                      );
                    }
                  },
                  itemBuilder: (context) => const [
                    PopupMenuItem(
                      value: 3,
                      child: Text(
                        'حذف موقت کلید از همه مکان‌ها',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                    PopupMenuItem(
                      value: 4,
                      child: Text(
                        'حذف کامل دستگاه',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Obx(() {
                  final lastSeen =
                      reliableController.lastDeviceActivity[device.deviceId];
                  final isOnline =
                      lastSeen != null &&
                      DateTime.now().difference(lastSeen) <
                          const Duration(seconds: 30);
                  return Text(
                    isOnline ? "آنلاین" : "آفلاین",
                    style: TextStyle(
                      color: isOnline ? Colors.green : Colors.red,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  );
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchRow({
    required String deviceId,
    required int switchNumber,
    required Color color,
    required Function(int switchNumber, bool value) onToggle,
  }) {
    final reliableController = Get.find<ReliableSocketController>(
      tag: 'smartDevicesController',
    );

    return Obx(() {
      final deviceData = reliableController.latestDeviceDataById[deviceId];
      bool isOn = false;

      if (deviceData != null) {
        final keyEntries = switchNumber == 1
            ? [
                if (deviceData['TW1'] is List) ...deviceData['TW1'],
                if (deviceData['TD1'] is List) ...deviceData['TD1'],
              ]
            : [
                if (deviceData['TW2'] is List) ...deviceData['TW2'],
                if (deviceData['TD2'] is List) ...deviceData['TD2'],
              ];

        if (keyEntries.isNotEmpty) {
          keyEntries.sort((a, b) => (b[0] as int).compareTo(a[0] as int));
          isOn = keyEntries.first[1].toString().contains('On');
        }
      }

      return Row(
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
              boxShadow: [
                if (isOn)
                  BoxShadow(
                    color: color.withOpacity(0.6),
                    blurRadius: 6,
                    spreadRadius: 2,
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => onToggle(switchNumber, !isOn),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isOn ? Colors.lightBlueAccent : Colors.grey.shade400,
              ),
              child: const Icon(Icons.power_settings_new, color: Colors.white),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            "کلید $switchNumber",
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ],
      );
    });
  }
}
