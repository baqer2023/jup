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
    final devices = controller.deviceList; // RxList<DeviceItem>

    // ۱️⃣ بررسی انتخاب مکان
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

    // ۲️⃣ جمع‌آوری deviceIds
    final deviceIds = devices.map((d) => d.deviceId).toList();

    // ۳️⃣ رجیستر کردن ReliableSocketController
    if (Get.isRegistered<ReliableSocketController>(tag: 'smartDevicesController')) {
      Get.delete<ReliableSocketController>(tag: 'smartDevicesController');
    }

    final reliableController = Get.put(
      ReliableSocketController(controller.token, deviceIds),
      tag: 'smartDevicesController',
      permanent: true,
    );

    // ۴️⃣ نمایش Grid دیوایس‌ها
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

            // مقداردهی پیش‌فرض
            bool switch1On = false;
            bool switch2On = false;
            Color iconColor1 = Colors.grey;
            Color iconColor2 = Colors.grey;

            if (deviceData != null) {
              // وضعیت کلیدها
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

              // رنگ LED
              if (deviceData['ledColor'] is List && deviceData['ledColor'].isNotEmpty) {
                final ledJson = deviceData['ledColor'][0][1];
                if (ledJson is String) {
                  final ledMap = jsonDecode(ledJson);
                  iconColor1 = switch1On
                      ? Color.fromARGB(255, ledMap['touch1']['on']['r'], ledMap['touch1']['on']['g'], ledMap['touch1']['on']['b'])
                      : Color.fromARGB(255, ledMap['touch1']['off']['r'], ledMap['touch1']['off']['g'], ledMap['touch1']['off']['b']);
                  iconColor2 = switch2On
                      ? Color.fromARGB(255, ledMap['touch2']['on']['r'], ledMap['touch2']['on']['g'], ledMap['touch2']['on']['b'])
                      : Color.fromARGB(255, ledMap['touch2']['off']['r'], ledMap['touch2']['off']['g'], ledMap['touch2']['off']['b']);
                }
              }
            }

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
  required bool switch2On,
  required Color iconColor1,
  required Color iconColor2,
  required Function(int switchNumber, bool value) onToggle,
}) {
  final reliableController = Get.find<ReliableSocketController>(
    tag: 'smartDevicesController',
  );

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
          // 🔹 عنوان + وضعیت آنلاین/آفلاین
          Obx(() {
            final isOnline = reliableController.isDeviceConnected(deviceId);
            final lastSeen = reliableController.getLastActivity(deviceId);

            return Column(
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isOnline ? Icons.circle : Icons.circle_outlined,
                      color: isOnline ? Colors.green : Colors.red,
                      size: 12,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isOnline ? "آنلاین" : "آفلاین",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: isOnline ? Colors.green : Colors.red,
                      ),
                    ),
                  ],
                ),
                if (!isOnline && lastSeen != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    "آخرین فعالیت: ${lastSeen.toLocal()}",
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ],
            );
          }),
          const SizedBox(height: 12),

          // 🔹 کلیدها
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildSwitchColumn(
                deviceId: deviceId,
                switchNumber: 1,
                color: iconColor1,
                onToggle: onToggle,
              ),
              _buildSwitchColumn(
                deviceId: deviceId,
                switchNumber: 2,
                color: iconColor2,
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
      final keyEntries = [
        if (switchNumber == 1) ...?deviceData['Touch_W1'] ?? [], 
        if (switchNumber == 1) ...?deviceData['Touch_D1'] ?? [],
        if (switchNumber == 2) ...?deviceData['Touch_W2'] ?? [],
        if (switchNumber == 2) ...?deviceData['Touch_D2'] ?? [],
      ];

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
            // 🔹 دایره رنگ LED
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

            // 🔹 دکمه پاور
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
}

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
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  title: Center(
                    child: Text(
                      'تغییر رنگ کلید',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  content: Column(
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
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 8,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: 260,
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
                  actionsAlignment: MainAxisAlignment.spaceBetween,
                  actionsPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  actions: [
                    TextButton(
                      child: const Text(
                        'انصراف',
                        style: TextStyle(color: Colors.black54),
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: tempColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 10,
                        ),
                        elevation: 2,
                      ),
                      child: const Text(
                        'تایید',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
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
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: Offset(0, 1),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 13)),
      ],
    );
  }


  
}
