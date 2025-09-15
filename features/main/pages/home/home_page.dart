import 'package:my_app32/app/services/realable_controller.dart';
// import 'package:my_app32/features/main/pages/home/home_devices_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_app32/app/core/app_constants.dart';
import 'package:my_app32/app/core/base/base_view.dart';
import 'package:my_app32/app/services/weather_service.dart';
import 'package:my_app32/features/main/pages/home/base_scafold.dart';
import 'package:my_app32/features/main/pages/home/home_controller.dart';
import 'package:my_app32/features/widgets/sidebar.dart';
import 'package:my_app32/features/widgets/weather.dart';
import 'package:my_app32/features/widgets/category_selector_widget.dart';
import 'package:my_app32/features/main/pages/home/profile.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_svg/flutter_svg.dart';



// mixin HomeDevicesControllerMixin {
//   HomeDevicesController get homeDevicesController =>
//       Get.find<HomeDevicesController>();
// }


class HomePage extends BaseView<HomeController> {
  const HomePage({super.key});

  @override
  Widget body() {
    return DefaultTabController(
      length: 3,
      child: BaseScaffold(
        title: 'خانه', // عنوان اپ‌بار سمت راست
        body: Column(
          children: [
            // اپ‌بار سفارشی با TabBar
            PreferredSize(
              preferredSize: const Size.fromHeight(64),
              child: Container(
                height: 56,
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TabBar(
                  indicator: BoxDecoration(
                    color: const Color(0xFF0676C8),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0676C8).withOpacity(0.12),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  labelColor: Colors.white,
                  unselectedLabelColor: const Color(0xFF0676C8),
                  labelStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 15,
                  ),
                  tabs: const [
                    Tab(child: Text('خانه')),
                    Tab(child: Text('شرکت')),
                    Tab(child: Text('ویلا')),
                  ],
                ),
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _buildMainContent(),
                  const Center(child: Text('To be Built Soon')),
                  const Center(child: Text('Under Construction')),
                ],
              ),
            ),
          ],
        ),
        actions: [
          // IconButton(
          //   icon: const Icon(Icons.account_circle),
          //   onPressed: () {
          //     ProfilePage.showProfileDialog(controller.token);
          //   },
          // ),
          // سایر آیکون‌ها و دکمه‌های اضافی
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    return RefreshIndicator(
      onRefresh: () async => await controller.refreshAllData(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            _buildWeatherSection(),
            const CategorySelectorWidget(),
            _buildSmartDevicesGrid(),
          ],
        ),
      ),
    );
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


Widget _buildSmartDevicesGrid() {
  return Obx(() {
    final devices = controller.deviceList;
    if (devices.isEmpty) return const Center(child: CircularProgressIndicator());

    final deviceIds = devices.map((d) => d['deviceId']?.toString() ?? '').where((id) => id.isNotEmpty).toList();

    if (!Get.isRegistered<ReliableSocketController>(tag: 'smartDevicesController')) {
      Get.put(ReliableSocketController(controller.token, deviceIds),
          tag: 'smartDevicesController', permanent: true);
    }

    final reliableController = Get.find<ReliableSocketController>(tag: 'smartDevicesController');

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
          final deviceId = device['deviceId'] as String;
          final title = device['title'] ?? 'بدون نام';

          return Obx(() {
            final deviceData = reliableController.latestDeviceDataById[deviceId];

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
              title: title,
              deviceId: deviceId,
              switch1On: switch1On,
              switch2On: switch2On,
              iconColor1: iconColor1,
              iconColor2: iconColor2,
              onToggle: (switchNumber, value) async {
                await reliableController.toggleSwitch(value, switchNumber, deviceId);
              },
            );
          });
        },
      ),
    );
  });
}


  // ---------- کارت با callback برای toggle ----------
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
          // 🔹 عنوان + وضعیت آنلاین
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
                ]
              ],
            );
          }),
          const SizedBox(height: 12),

          // 🔹 دکمه‌ها
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // کلید 1
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
                    child: const Icon(
                      Icons.lightbulb,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Switch(
                    value: switch1On,
                    onChanged: (value) => onToggle(1, value),
                    activeColor: iconColor1,
                    inactiveThumbColor: iconColor1,
                    inactiveTrackColor: iconColor1.withOpacity(0.5),
                  ),
                ],
              ),

              // کلید 2
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
                    child: const Icon(
                      Icons.lightbulb,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Switch(
                    value: switch2On,
                    onChanged: (value) => onToggle(2, value),
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
