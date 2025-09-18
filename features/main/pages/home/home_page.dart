import 'package:dio/dio.dart';
import 'package:my_app32/app/services/realable_controller.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_app32/app/core/app_constants.dart';
import 'package:my_app32/app/core/base/base_view.dart';
import 'package:my_app32/app/services/weather_service.dart';
import 'package:my_app32/features/main/models/home/device_item_model.dart';
import 'package:my_app32/features/main/pages/home/Add_device_page.dart';
import 'package:my_app32/features/main/pages/home/home_controller.dart';
import 'package:my_app32/features/widgets/custom_appbar.dart';
import 'package:my_app32/features/widgets/sidebar.dart';
import 'package:my_app32/features/widgets/weather.dart';
import 'package:my_app32/features/widgets/category_selector_widget.dart';
import 'package:my_app32/features/main/pages/home/profile.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_svg/flutter_svg.dart';



class HomePage extends BaseView<HomeController> {
  const HomePage({super.key});

  @override
  Widget body() {
    return DefaultTabController(
      length: 3,
      child: Builder(builder: (context) {
        final tabController = DefaultTabController.of(context);
        return Scaffold(
          endDrawer: const Sidebar(),
appBar: CustomAppBar(
  isRefreshing: controller.isRefreshing,
),


          body: TabBarView(
            children: [
              _buildMainContent(),
              const Center(child: Text('To be Built Soon')),
              const Center(child: Text('Under Construction')),
            ],
          ),
        );
      }),
    );
  }


Widget _buildMainContent() {
  // Reactive variable برای نگه داشتن مکان انتخاب شده
  // final RxString selectedLocationId = ''.obs;

  return Obx(() {
final locations = controller.userLocations;
final devices = controller.deviceList;

return RefreshIndicator(
  onRefresh: controller.refreshAllData,
  child: SingleChildScrollView(
    physics: const AlwaysScrollableScrollPhysics(),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 16),
        _buildWeatherSection(),
        const SizedBox(height: 24),

        // دکمه‌ها و عنوان
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                 ElevatedButton(
  onPressed: () {
    Get.to(() => const AddDevicePage());
  },
  style: ElevatedButton.styleFrom(
    backgroundColor: Colors.lightBlue.shade400,
    foregroundColor: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  ),
  child: const Text('ثبت دستگاه'),
),

                  const SizedBox(width: 12),
              ElevatedButton(
                onPressed: _showAddLocationDialog, // اینجا تابع مدال را فراخوانی می‌کنیم
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.yellow.shade700,
                  side: BorderSide(color: Colors.yellow.shade700, width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                child: const Text('افزودن مکان'),
              ),

                ],
              ),
              const Text(
                'دستگاه‌ها',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const Divider(thickness: 2),
        const SizedBox(height: 16),

        // لیست مکان‌ها با انتخاب فعال
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Wrap(
            spacing: 12,
            runSpacing: 8,
            children: locations.map((loc) {
              return Obx(() {
                final isSelected = controller.selectedLocationId.value == loc.id;
                return GestureDetector(
                  onTap: () {
                    controller.selectedLocationId.value = loc.id;
                    controller.fetchDevicesByLocation(loc.id);
                  },
                  child: Chip(
                    label: Text(
                      loc.title,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black87,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    backgroundColor: isSelected ? Colors.blue.shade400 : Colors.blue.shade50,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                );
              });
            }).toList(),
          ),
        ),
        const SizedBox(height: 16),

        // لیست دیوایس‌ها
        if (devices.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Text(
                'برای مشاهده دستگاه‌ها، ابتدا یک مکان را انتخاب کنید',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          )
        else
          _buildSmartDevicesGrid(),
      ],
    ),
  ),
);

  });
}






  Widget _buildWeatherSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SizedBox(
        width: double.infinity,
        child: RefreshIndicator(
          onRefresh: () async {},
          child: WeatherDisplay(
            weatherFuture: WeatherApiService(
              apiKey: 'e6f7286f932ef4636fdfb82a45266d17',
            ).getWeather(lat: 35.7219, lon: 51.3347),
          ),
        ),
      ),
    );
  }


// ------------------- Smart Devices Grid -------------------
Widget _buildSmartDevicesGrid() {
  return Obx(() {
    final devices = controller.deviceList;

    if (devices.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Text(
            'برای مشاهده دستگاه‌ها، ابتدا یک مکان را انتخاب کنید',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    final deviceIds = devices.map((d) => d.deviceId).toList();

    if (Get.isRegistered<ReliableSocketController>(tag: 'smartDevicesController')) {
      Get.delete<ReliableSocketController>(tag: 'smartDevicesController');
    }

    final reliableController = Get.put(
      ReliableSocketController(controller.token, deviceIds),
      tag: 'smartDevicesController',
      permanent: true,
    );

    return Padding(
      padding: const EdgeInsets.all(16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: devices.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.65,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemBuilder: (context, index) {
          final device = devices[index];

          return Obx(() {
            final deviceData = reliableController.latestDeviceDataById[device.deviceId];

            bool switch1On = false;
            bool switch2On = false;
            Color iconColor1 = Colors.grey;
            Color iconColor2 = Colors.grey;

            if (deviceData != null) {
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
                final ledEntry = deviceData['ledColor'][0][1];
                Map<String, dynamic> ledMap;

                if (ledEntry is String) {
                  ledMap = jsonDecode(ledEntry);
                } else if (ledEntry is Map<String, dynamic>) {
                  ledMap = ledEntry;
                } else {
                  ledMap = {};
                }

                iconColor1 = switch1On
                    ? Color.fromARGB(
                        255,
                        ledMap['touch1']['on']['r'],
                        ledMap['touch1']['on']['g'],
                        ledMap['touch1']['on']['b'],
                      )
                    : Color.fromARGB(
                        255,
                        ledMap['touch1']['off']['r'],
                        ledMap['touch1']['off']['g'],
                        ledMap['touch1']['off']['b'],
                      );

                iconColor2 = switch2On
                    ? Color.fromARGB(
                        255,
                        ledMap['touch2']['on']['r'],
                        ledMap['touch2']['on']['g'],
                        ledMap['touch2']['on']['b'],
                      )
                    : Color.fromARGB(
                        255,
                        ledMap['touch2']['off']['r'],
                        ledMap['touch2']['off']['g'],
                        ledMap['touch2']['off']['b'],
                      );
              }
            }

            final isSingleKey = device.deviceTypeName == 'key-1';

            return _buildSmartDeviceCard(
              title: device.title,
              deviceId: device.deviceId,
              switch1On: switch1On,
              switch2On: switch2On,
              iconColor1: iconColor1,
              iconColor2: iconColor2,
              onToggle: (switchNumber, value) async {
                await reliableController.toggleSwitch(value, switchNumber, device.deviceId);
              },
              isSingleKey: isSingleKey,
              device: device, // دستگاه را پاس می‌دهیم
            );
          });
        },
      ),
    );
  });
}

// ------------------- Smart Device Card -------------------
Widget _buildSmartDeviceCard({
  required String title,
  required String deviceId,
  required bool switch1On,
  bool? switch2On,
  required Color iconColor1,
  Color? iconColor2,
  required Function(int switchNumber, bool value) onToggle,
  required bool isSingleKey,
  required DeviceItem device, // ← اضافه شد تا دستگاه برای تنظیمات پیشرفته داشته باشیم
}) {
  final reliableController = Get.find<ReliableSocketController>(tag: 'smartDevicesController');

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
          // عنوان + وضعیت آنلاین + منوی سه نقطه
          Obx(() {
            final isOnline = reliableController.isDeviceConnected(deviceId);
            final lastSeen = reliableController.getLastActivity(deviceId);
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(isOnline ? Icons.circle : Icons.circle_outlined,
                            color: isOnline ? Colors.green : Colors.red, size: 12),
                        const SizedBox(width: 6),
                        Text(isOnline ? "آنلاین" : "آفلاین",
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: isOnline ? Colors.green : Colors.red)),
                      ],
                    ),
                    if (!isOnline && lastSeen != null) ...[
                      const SizedBox(height: 4),
                      Text("آخرین فعالیت: ${lastSeen.toLocal()}",
                          style: const TextStyle(fontSize: 11, color: Colors.grey)),
                    ],
                  ],
                ),
PopupMenuButton<int>(
  icon: const Icon(Icons.more_vert, color: Colors.black87),
  onSelected: (value) {
    if (value == 0) { 
      // وقتی روی تنظیمات پیشرفته کلیک شد، دیالوگ رنگ باز میشه
      showLedColorDialog(device: device, token: controller.token);
    }
    // سایر گزینه‌ها را می‌توانید اینجا اضافه کنید
  },
  itemBuilder: (context) => [
    const PopupMenuItem(value: 0, child: Text('تنظیمات پیشرفته')),
    const PopupMenuItem(value: 1, child: Text('ویرایش کلید')),
    const PopupMenuItem(value: 2, child: Text('فعال کردن قفل کودک')),
    const PopupMenuItem(value: 3, child: Text('بازنشانی به تنظیمات کارخانه')),
    const PopupMenuItem(value: 4, child: Text('حذف موقت', style: TextStyle(color: Colors.red))),
    const PopupMenuItem(value: 5, child: Text('حذف کامل', style: TextStyle(color: Colors.red))),
  ],
),

              ],
            );
          }),
          const SizedBox(height: 12),

          // کلیدها
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildSwitchColumn(
                deviceId: deviceId,
                switchNumber: 1,
                color: iconColor1,
                onToggle: onToggle,
              ),
              if (!isSingleKey)
                _buildSwitchColumn(
                  deviceId: deviceId,
                  switchNumber: 2,
                  color: iconColor2 ?? Colors.grey,
                  onToggle: onToggle,
                ),
            ],
          ),
        ],
      ),
    ),
  );
}


// ------------------- ستون کلید -------------------
Widget _buildSwitchColumn({
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
      // فقط کلید مربوطه را بررسی می‌کنیم
      final keyEntries = switchNumber == 1
          ? [
              if (deviceData['Touch_W1'] is List) ...deviceData['Touch_W1'],
              if (deviceData['Touch_D1'] is List) ...deviceData['Touch_D1'],
            ]
          : switchNumber == 2
              ? [
                  if (deviceData['Touch_W2'] is List) ...deviceData['Touch_W2'],
                  if (deviceData['Touch_D2'] is List) ...deviceData['Touch_D2'],
                ]
              : [];

      if (keyEntries.isNotEmpty) {
        keyEntries.sort((a, b) => (b[0] as int).compareTo(a[0] as int));
        isOn = keyEntries.first[1].toString().contains('On');
      }
    }

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // دایره رنگ LED
            Container(
              width: 16,
              height: 16,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color,
                boxShadow: [
                  if (isOn)
                    BoxShadow(
                      color: color.withOpacity(0.6),
                      blurRadius: 6,
                      spreadRadius: 1,
                    ),
                ],
              ),
            ),

            // دکمه پاور
            GestureDetector(
              onTap: () => onToggle(switchNumber, !isOn),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isOn ? Colors.lightBlueAccent : Colors.grey.shade400,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.power_settings_new,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          "کلید $switchNumber",
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        ),
      ],
    );
  });
}



void _showAddLocationDialog() {
  final TextEditingController nameController = TextEditingController();

  showDialog(
    context: Get.context!,
    builder: (context) {
      return AlertDialog(
        backgroundColor: Colors.white, // پس‌زمینه مدال
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 10, // سایه ملایم
        title: const Text(
          'افزودن مکان',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
            fontSize: 18,
          ),
          textAlign: TextAlign.center,
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'نام مکان',
                  hintText: 'نام مکان را وارد کنید',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        actionsAlignment: MainAxisAlignment.spaceBetween,
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(
              backgroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: Colors.yellow),
              ),
            ),
            child: const Text(
              'انصراف',
              style: TextStyle(color: Colors.yellow, fontWeight: FontWeight.bold),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = nameController.text.trim();
              if (name.isEmpty) {
                Get.snackbar(
                  'خطا',
                  'لطفاً نام مکان را وارد کنید',
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                );
                return;
              }
              await controller.addLocation(name);
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'ثبت',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      );
    },
  );
}






  Widget _buildLoadingDeviceCard({required String title}) {
    return Card(
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.05),
      color: const Color(0xFFF8FAFC),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.lightbulb_sharp, size: 40, color: Colors.grey),
                  Icon(Icons.lightbulb_sharp, size: 40, color: Colors.grey),
                  IconButton(
                    icon: const Icon(Icons.more_vert),
                    onPressed: () {},
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: Color(0xFF1E3A8A),
                ),
                textAlign: TextAlign.right,
              ),
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'کلید ۱: در حال بارگذاری...',
                          style: const TextStyle(fontSize: 12),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Switch(
                        value: false,
                        onChanged: (val) {},
                        activeColor: Colors.blueAccent,
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'کلید ۲: در حال بارگذاری...',
                          style: const TextStyle(fontSize: 12),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Switch(
                        value: false,
                        onChanged: (val) {},
                        activeColor: Colors.blueAccent,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  
  Widget _buildNoDevicesFound() {
    return Center(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final double svgHeight = (constraints.maxHeight * 0.4).clamp(
            120.0,
            300.0,
          );
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: svgHeight,
                child: AspectRatio(
                  aspectRatio: 1,
                  child: SvgPicture.asset(
                    'assets/images/device_notFound.svg',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'هیچ دستگاهی یافت نشد',
                style: TextStyle(fontSize: 18, color: Colors.grey[600]),
              ),
            ],
          );
        },
      ),
    );
  }


// ------------------- Advanced Settings Dialog -------------------
void showLedColorDialog({
  required DeviceItem device,
  required String token,
}) {
  final reliableController = Get.find<ReliableSocketController>(tag: 'smartDevicesController');
  final deviceData = reliableController.latestDeviceDataById[device.deviceId];
  final isSingleKey = device.deviceTypeName == 'key-1';

  // Reactive colors
  Rx<Color> touch1On = const Color(0xFF2196F3).obs;
  Rx<Color> touch1Off = const Color(0xFF9E9E9E).obs;
  Rx<Color> touch2On = const Color(0xFF4CAF50).obs;
  Rx<Color> touch2Off = const Color(0xFF9E9E9E).obs;

  // مقداردهی اولیه از داده دستگاه
  if (deviceData != null && deviceData['ledColor'] is List && deviceData['ledColor'].isNotEmpty) {
    try {
      final ledEntry = deviceData['ledColor'][0][1];
      Map<String, dynamic> ledMap = ledEntry is String ? jsonDecode(ledEntry) : (ledEntry as Map<String, dynamic>);

      if (ledMap['touch1'] != null) {
        touch1On.value = Color.fromARGB(
          255,
          (ledMap['touch1']['on']['r'] as int).clamp(0, 255),
          (ledMap['touch1']['on']['g'] as int).clamp(0, 255),
          (ledMap['touch1']['on']['b'] as int).clamp(0, 255),
        );
        touch1Off.value = Color.fromARGB(
          255,
          (ledMap['touch1']['off']['r'] as int).clamp(0, 255),
          (ledMap['touch1']['off']['g'] as int).clamp(0, 255),
          (ledMap['touch1']['off']['b'] as int).clamp(0, 255),
        );
      }

      if (!isSingleKey && ledMap['touch2'] != null) {
        touch2On.value = Color.fromARGB(
          255,
          (ledMap['touch2']['on']['r'] as int).clamp(0, 255),
          (ledMap['touch2']['on']['g'] as int).clamp(0, 255),
          (ledMap['touch2']['on']['b'] as int).clamp(0, 255),
        );
        touch2Off.value = Color.fromARGB(
          255,
          (ledMap['touch2']['off']['r'] as int).clamp(0, 255),
          (ledMap['touch2']['off']['g'] as int).clamp(0, 255),
          (ledMap['touch2']['off']['b'] as int).clamp(0, 255),
        );
      }
    } catch (_) {}
  }

  showDialog(
    context: Get.context!,
    barrierDismissible: false,
    builder: (context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Center(
          child: Text('تنظیمات پیشرفته', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Obx(() => _ColorPreviewPicker(label: 'کلید ۱ روشن', color: touch1On.value, onPick: (c) => touch1On.value = c)),
              Obx(() => _ColorPreviewPicker(label: 'کلید ۱ خاموش', color: touch1Off.value, onPick: (c) => touch1Off.value = c)),
              if (!isSingleKey) ...[
                const SizedBox(height: 8),
                Obx(() => _ColorPreviewPicker(label: 'کلید ۲ روشن', color: touch2On.value, onPick: (c) => touch2On.value = c)),
                Obx(() => _ColorPreviewPicker(label: 'کلید ۲ خاموش', color: touch2Off.value, onPick: (c) => touch2Off.value = c)),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('انصراف', style: TextStyle(color: Colors.black54)),
          ),
          ElevatedButton(
            onPressed: () async {
                  try {
                    var headers = {
                      'Authorization': 'Bearer eyJhbGciOiJIUzUxMiJ9.eyJzdWIiOiIwOTIwMjI0NzA5MSIsInVzZXJJZCI6IjhiMmNhMjYwLThjMTctMTFmMC04MWFiLWViZWE4MWE3NWI2OSIsInNjb3BlcyI6WyJURU5BTlRfQURNSU4iXSwic2Vzc2lvbklkIjoiZjY3ZjliZjMtYzk2OC00YzE3LWJlMGMtZmEzZDgwYzNmZDc4IiwiZXhwIjoxNzU4MjY5OTMzLCJpc3MiOiJ0aGluZ3Nib2FyZC5pbyIsImlhdCI6MTc1ODE4MzUzMywiZW5hYmxlZCI6dHJ1ZSwiaXNQdWJsaWMiOmZhbHNlLCJ0ZW5hbnRJZCI6IjhhNTYzZjkwLThjMTctMTFmMC04MWFiLWViZWE4MWE3NWI2OSIsImN1c3RvbWVySWQiOiIxMzgxNDAwMC0xZGQyLTExYjItODA4MC04MDgwODA4MDgwODAifQ.EjGxGxDAJF-dp5-1MGtqF7cV8dM_bHxaWJ636VhLTNCpUF04OFk9eb_HRBTaRoi2xvyuG_Xrve-siB-ykNuK-Q',
                      'Content-Type': 'application/json'
                    };

                    var data = json.encode({
                      "deviceId": device.deviceId,
                      "request": {
                        "ledColor": {
                          "touch1": {
                            "on": {
                              "r": touch1On.value.red,
                              "g": touch1On.value.green,
                              "b": touch1On.value.blue
                            },
                            "off": {
                              "r": touch1Off.value.red,
                              "g": touch1Off.value.green,
                              "b": touch1Off.value.blue
                            }
                          },
                          if (!isSingleKey)
                            "touch2": {
                              "on": {
                                "r": touch2On.value.red,
                                "g": touch2On.value.green,
                                "b": touch2On.value.blue
                              },
                              "off": {
                                "r": touch2Off.value.red,
                                "g": touch2Off.value.green,
                                "b": touch2Off.value.blue
                              }
                            }
                        }
                      }
                    });

                    var dio = Dio();
                    var response = await dio.request(
                      'http://45.149.76.245:8080/api/plugins/telemetry/changeColor',
                      options: Options(
                        method: 'POST',
                        headers: headers,
                      ),
                      data: data,
                    );

                    if (response.statusCode == 200) {
                      Get.snackbar('موفق', 'رنگ کلید با موفقیت تغییر کرد', backgroundColor: Colors.green);
                      Navigator.of(context).pop();
                    } else {
                      Get.snackbar('خطا', 'خطا در تغییر رنگ: ${response.statusMessage}', backgroundColor: Colors.red);
                    }
                  } catch (e) {
                    Get.snackbar('خطا', 'خطا در ارتباط با سرور: $e', backgroundColor: Colors.red);
                  }
                },

            child: const Text('ثبت'),
          ),
        ],
      );
    },
  );
}
















}



// ------------------- Color Picker Widget -------------------
class _ColorPreviewPicker extends StatelessWidget {
  final String label;
  final Color color;
  final ValueChanged<Color> onPick;

  const _ColorPreviewPicker({
    required this.label,
    required this.color,
    required this.onPick,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: () async {
            Color tempColor = color;
            Color? picked = await showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  title: const Center(
                    child: Text('تغییر رنگ کلید', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  ),
                  content: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: tempColor,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.black26, width: 2),
                            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 2))],
                          ),
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.8,
                          child: ColorPicker(
                            pickerColor: tempColor,
                            onColorChanged: (c) => tempColor = c,
                            showLabel: false,
                            pickerAreaHeightPercent: 0.8,
                            enableAlpha: false,
                            displayThumbColor: true,
                            portraitOnly: true,
                          ),
                        ),
                      ],
                    ),
                  ),
                  actionsAlignment: MainAxisAlignment.spaceBetween,
                  actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  actions: [
                    TextButton(
                      child: const Text('انصراف', style: TextStyle(color: Colors.black54)),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: tempColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                        elevation: 2,
                      ),
                      child: const Text('تایید', style: TextStyle(fontWeight: FontWeight.bold)),
                      onPressed: () => Navigator.of(context).pop(tempColor),
                    ),
                  ],
                );
              },
            );
            if (picked != null) onPick(picked);
          },
          child: Container(
            width: 40,
            height: 40,
            margin: const EdgeInsets.symmetric(vertical: 4),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.black26),
              boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 1))],
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 13)),
      ],
    );
  }
}