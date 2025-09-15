import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_app32/app/services/realable_controller.dart';
import 'package:my_app32/features/devices/controller/device_controller.dart';
import 'package:my_app32/features/main/pages/home/base_scafold.dart';
import 'package:my_app32/features/main/pages/home/profile.dart';

class DeviceView extends StatelessWidget {
  const DeviceView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(DeviceController());

    // ثبت ReliableSocketController اگر ثبت نشده
    if (!Get.isRegistered<ReliableSocketController>(tag: 'smartDevicesController')) {
      final deviceIds = controller.devices.map((d) => d.deviceId).toList();
      Get.put(ReliableSocketController(controller.token.value, deviceIds),
          tag: 'smartDevicesController', permanent: true);
    }

    final reliableController = Get.find<ReliableSocketController>(tag: 'smartDevicesController');

    return BaseScaffold(
      title: "لیست دستگاه‌ها",
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.devices.isEmpty) {
          return _buildNoDevices();
        }

        // GridView اصلی
        return Padding(
          padding: const EdgeInsets.all(16),
          child: GridView.builder(
            itemCount: controller.devices.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.65,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemBuilder: (context, index) {
              final device = controller.devices[index];
              final isDualKey = device.deviceTypeName == "key-2";

              // هر کارت خودش Obx می‌شود
              return Obx(() {
                final deviceData = reliableController.latestDeviceDataById[device.deviceId];

                bool switch1On = false;
                bool switch2On = false;
                Color iconColor1 = Colors.grey;
                Color iconColor2 = Colors.grey;

                if (deviceData != null && isDualKey) {
                  final key1Entries = [
                    if (deviceData['Touch_W1'] is List) ...deviceData['Touch_W1'],
                    if (deviceData['Touch_D1'] is List) ...deviceData['Touch_D1'],
                  ];
                  if (key1Entries.isNotEmpty) {
                    key1Entries.sort((a, b) => (b[0] as int).compareTo(a[0] as int));
                    switch1On = key1Entries.first[1].toString().contains('On');
                  }

                  final key2Entries = [
                    if (deviceData['Touch_W2'] is List) ...deviceData['Touch_W2'],
                    if (deviceData['Touch_D2'] is List) ...deviceData['Touch_D2'],
                  ];
                  if (key2Entries.isNotEmpty) {
                    key2Entries.sort((a, b) => (b[0] as int).compareTo(a[0] as int));
                    switch2On = key2Entries.first[1].toString().contains('On');
                  }

                  if (deviceData['ledColor'] is List && deviceData['ledColor'].isNotEmpty) {
                    final ledJson = deviceData['ledColor'][0][1];
                    if (ledJson is String) {
                      final ledMap = jsonDecode(ledJson);
                      iconColor1 = switch1On
                          ? Color.fromARGB(
                              255,
                              ledMap['touch1']['on']['r'],
                              ledMap['touch1']['on']['g'],
                              ledMap['touch1']['on']['b'])
                          : Color.fromARGB(
                              255,
                              ledMap['touch1']['off']['r'],
                              ledMap['touch1']['off']['g'],
                              ledMap['touch1']['off']['b']);
                      iconColor2 = switch2On
                          ? Color.fromARGB(
                              255,
                              ledMap['touch2']['on']['r'],
                              ledMap['touch2']['on']['g'],
                              ledMap['touch2']['on']['b'])
                          : Color.fromARGB(
                              255,
                              ledMap['touch2']['off']['r'],
                              ledMap['touch2']['off']['g'],
                              ledMap['touch2']['off']['b']);
                    }
                  }
                } else {
                  switch1On = device.onlineStatus;
                  iconColor1 = switch1On ? Colors.green : Colors.grey;
                }

                return _buildSmartDeviceCard(
                  title: device.title,
                  deviceId: device.deviceId,
                  switch1On: switch1On,
                  switch2On: isDualKey ? switch2On : null,
                  iconColor1: iconColor1,
                  iconColor2: isDualKey ? iconColor2 : null,
                  isDualKey: isDualKey,
                  onToggle: (switchNumber, value) async {
                    await reliableController.toggleSwitch(value, switchNumber, device.deviceId);
                  },
                );
              });
            },
          ),
        );
      }),
    );
  }

  Widget _buildNoDevices() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 200,
            height: 200,
            child: Image.asset("assets/svg/Dowshboard.svg"),
          ),
          const SizedBox(height: 16),
          const Text(
            "تا کنون دستگاهی ثبت نشده‌است، جهت ثبت دستگاه جدید روی دکمه زیر کلیک کنید",
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {},
            child: const Text("ثبت دستگاه"),
          ),
        ],
      ),
    );
  }

  Widget _buildSmartDeviceCard({
    required String title,
    required String deviceId,
    required bool switch1On,
    bool? switch2On,
    required Color iconColor1,
    Color? iconColor2,
    required bool isDualKey,
    required Function(int switchNumber, bool value) onToggle,
  }) {
    return Card(
      color: Colors.white,
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      shadowColor: Colors.black26,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(title,
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black87)),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: switch1On
                              ? [iconColor1.withOpacity(0.7), iconColor1]
                              : [Colors.grey.shade300, Colors.grey.shade400],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          if (switch1On)
                            BoxShadow(
                              color: iconColor1.withOpacity(0.5),
                              blurRadius: 8,
                              spreadRadius: 2,
                            ),
                        ],
                      ),
                      padding: const EdgeInsets.all(12),
                      child: const Icon(Icons.lightbulb,
                          color: Colors.white, size: 32),
                    ),
                    const SizedBox(height: 8),
                    Switch(
                      value: switch1On,
                      onChanged: (v) => onToggle(1, v),
                      activeColor: iconColor1,
                      inactiveThumbColor: iconColor1,
                      inactiveTrackColor: iconColor1.withOpacity(0.5),
                    ),
                  ],
                ),
                if (isDualKey && switch2On != null && iconColor2 != null)
                  Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: switch2On
                                ? [iconColor2.withOpacity(0.7), iconColor2]
                                : [Colors.grey.shade300, Colors.grey.shade400],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            if (switch2On)
                              BoxShadow(
                                color: iconColor2.withOpacity(0.5),
                                blurRadius: 8,
                                spreadRadius: 2,
                              ),
                          ],
                        ),
                        padding: const EdgeInsets.all(12),
                        child: const Icon(Icons.lightbulb,
                            color: Colors.white, size: 32),
                      ),
                      const SizedBox(height: 8),
                      Switch(
                        value: switch2On,
                        onChanged: (v) => onToggle(2, v),
                        activeColor: iconColor2,
                        inactiveThumbColor: iconColor2,
                        inactiveTrackColor: iconColor2.withOpacity(0.5),
                      ),
                    ],
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
