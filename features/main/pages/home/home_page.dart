import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'package:my_app32/app/services/realable_controller.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_app32/app/core/app_constants.dart';
import 'package:my_app32/app/core/base/base_view.dart';
import 'package:my_app32/app/services/weather_service.dart';
import 'package:my_app32/features/config/device_config_page.dart';
import 'package:my_app32/features/devices/pages/edit_device_page.dart';
import 'package:my_app32/features/main/models/home/device_item_model.dart';
import 'package:my_app32/features/main/pages/home/Add_device_page.dart';
import 'package:my_app32/features/main/pages/home/home_controller.dart';
import 'package:my_app32/features/main/repository/home_repository.dart';
import 'package:my_app32/features/widgets/custom_appbar.dart';
import 'package:my_app32/features/widgets/sidebar.dart';
import 'package:my_app32/features/widgets/weather.dart';
import 'package:my_app32/features/widgets/category_selector_widget.dart';
import 'package:my_app32/features/main/pages/home/profile.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:persian_datetime_picker/persian_datetime_picker.dart';
import 'dart:ui' as ui;

class HomePage extends BaseView<HomeController> {
  HomePage({super.key}) {
    // ⚡ ساخت HomeController مستقیم داخل صفحه
    Get.put<HomeController>(
      HomeController(Get.find<HomeRepository>()),
      permanent: true,
    );
  }

  @override
  Widget body() {
    final controller = Get.find<HomeController>();

    // ⚡ بعد از ساخته شدن صفحه داده‌ها را تازه کن
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.selectedLocationId.value = '';
      controller.deviceList.clear();
      controller.initData(); // اگر میخوای initData هم صدا زده بشه
    });

    return Scaffold(
      endDrawer: const Sidebar(),
      appBar: CustomAppBar(isRefreshing: controller.isRefreshing),
      body: Builder(
        builder: (context) => _buildMainContent(controller),
      ),
    );
  }
  
Widget _buildMainContent(HomeController controller) {
  return Obx(() {
    final devices = controller.dashboardDevices;
    final groups = [];
    final scenarios = [];
    final energyConsumption = [];

    Widget buildSection({
      required String title,
      required Widget child,
    }) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: Material(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(16),
          elevation: 4,
          shadowColor: Colors.black.withOpacity(0.1),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                child,
              ],
            ),
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: controller.refreshAllData,
      child: NotificationListener<OverscrollIndicatorNotification>(
        onNotification: (overscroll) {
          overscroll.disallowIndicator();
          return true;
        },
        child: ScrollConfiguration(
          behavior: const ScrollBehavior().copyWith(overscroll: false),
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 16),

                // 🔸 بخش بالایی چهار کارت
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return GridView.count(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          childAspectRatio: 2.5,
                          children: [
                            _infoBox(
                              iconPath: 'assets/svg/enableSencor.svg',
                              text: 'نیاز به اتصال سنسور دما',
                            ),
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Directionality(
                                textDirection: ui.TextDirection.ltr,
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: WeatherDisplay(
                                        weatherFuture: controller.weatherFuture,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            StreamBuilder<DateTime>(
                              stream: Stream.periodic(
                                const Duration(seconds: 1),
                                (_) => DateTime.now(),
                              ),
                              builder: (context, snapshot) {
                                final now = snapshot.data ?? DateTime.now();
                                final jalali = Jalali.fromDateTime(now);
                                final time =
                                    '${jalali.hour.toString().padLeft(2, '0')}:${jalali.minute.toString().padLeft(2, '0')}';
                                final date = jalali.formatFullDate();
                                return _infoBox(
                                  iconPath: 'assets/svg/time.svg',
                                  text: '$time\n$date',
                                );
                              },
                            ),
                            _infoBox(
                              iconPath: 'assets/svg/enableDevice.svg',
                              text: 'هنوز دستگاه فعالی نیست',
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 30),

// 🔸 بخش دستگاه‌ها
buildSection(
  title: 'دستگاه‌ها',
  child: Padding(
    padding: const EdgeInsets.symmetric(horizontal: 1, vertical: 1), // فاصله کم از کناره‌ها و بالا/پایین
    child: devices.isEmpty
        ? Center(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                SizedBox(
                  height: 400, // کمی بلندتر تا بخش رو پر کنه
                  width: double.infinity,
                  child: SvgPicture.asset(
                    'assets/svg/EmptyDashboard.svg',
                    fit: BoxFit.contain, // تصویر خراب نشه
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'هیچ دستگاهی به داشبورد اضافه نشده است',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          )
        : _buildSmartDevicesGrid(controller), // GridView کارت‌ها
  ),
),


                // 🔸 بخش گروه‌ها
                buildSection(
                  title: 'گروه‌ها',
                  child: groups.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
  SizedBox(
    height: 200, // می‌تونی کم یا زیاد کنی
    child: SvgPicture.asset(
      'assets/svg/EmptyGroups.svg',
      fit: BoxFit.contain, // این مهمه: تصویر اصلی رو خراب نمی‌کنه
      width: double.infinity, // عرض کل Container رو می‌گیره
    ),
  ),
  const SizedBox(height: 20),
  const Text(
    'هیچ گروهی ایجاد نشده است',
    style: TextStyle(
      fontSize: 16,
      color: Colors.grey,
      fontWeight: FontWeight.w500,
    ),
    textAlign: TextAlign.center, // متن هم وسط چین بشه
  ),
],

                          ),
                        )
                      : Column(
                          children: groups.map((g) => _buildGroupCard(g)).toList(),
                        ),
                ),

                // 🔸 بخش سناریوها
                buildSection(
                  title: 'سناریو ها',
                  child: scenarios.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
  SizedBox(
    height: 200, // می‌تونی کم یا زیاد کنی
    child: SvgPicture.asset(
      'assets/svg/EmptySenario.svg',
      fit: BoxFit.contain, // این مهمه: تصویر اصلی رو خراب نمی‌کنه
      width: double.infinity, // عرض کل Container رو می‌گیره
    ),
  ),
  const SizedBox(height: 20),
  const Text(
    'هیچ سناریویی ایجاد نشده است',
    style: TextStyle(
      fontSize: 16,
      color: Colors.grey,
      fontWeight: FontWeight.w500,
    ),
    textAlign: TextAlign.center, // متن هم وسط چین بشه
  ),
],

                          ),
                        )
                      : Column(
                          children: scenarios.map((s) => _buildScenarioCard(s)).toList(),
                        ),
                ),

                // 🔸 بخش مصرف انرژی
                buildSection(
                  title: 'مصرف انرژی',
                  child: energyConsumption.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
  SizedBox(
    height: 200, // می‌تونی کم یا زیاد کنی
    child: SvgPicture.asset(
      'assets/svg/EmptyEnergy.svg',
      fit: BoxFit.contain, // این مهمه: تصویر اصلی رو خراب نمی‌کنه
      width: double.infinity, // عرض کل Container رو می‌گیره
    ),
  ),
  const SizedBox(height: 20),
  const Text(
    'هیچ مصرف انرژیی ایجاد نشده است',
    style: TextStyle(
      fontSize: 16,
      color: Colors.grey,
      fontWeight: FontWeight.w500,
    ),
    textAlign: TextAlign.center, // متن هم وسط چین بشه
  ),
],

                          ),
                        )
                      : Column(
                          children: energyConsumption
                              .map((e) => _buildEnergyCard(e))
                              .toList(),
                        ),
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  });
}


Widget _buildGroupCard(dynamic group) {
  // کارت ساده برای نمایش گروه (فعلاً داده‌ها خالی هستند)
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 200,
              width: 200,
              child: SvgPicture.asset(
                'assets/svg/EmptyGroups.svg',
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'هیچ گروهی ایجاد نشده است',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    ),
  );
}



Widget _buildScenarioCard(dynamic scenario) {
   // کارت ساده برای نمایش گروه (فعلاً داده‌ها خالی هستند)
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 200,
              width: 200,
              child: SvgPicture.asset(
                'assets/svg/EmptySenario.svg',
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'هیچ سناریویی ایجاد نشده است',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    ),
  );
}

Widget _buildEnergyCard(dynamic energy) {
  // کارت ساده برای نمایش گروه (فعلاً داده‌ها خالی هستند)
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 200,
              width: 200,
              child: SvgPicture.asset(
                'assets/svg/EmptyEnergy.svg',
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'هیچ مصرف انرژیی ایجاد نشده است',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    ),
  );
}


  Widget _infoBox({
  required String iconPath,
  required String text,
}) {
  return Container(
    padding: const EdgeInsets.all(6),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.7),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.right,
          ),
        ),
        const SizedBox(width: 8),
        SvgPicture.asset(iconPath, width: 28, height: 28),
      ],
    ),
  );
}


  Widget _buildWeatherSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SizedBox(
        width: double.infinity,
        child: WeatherDisplay(
          weatherFuture: controller.weatherFuture, // ⬅️ از کنترلر بخون
        ),
      ),
    );
  }

  // ------------------- Smart Devices Grid (اصلاح شده) -------------------
Widget _buildSmartDevicesGrid(HomeController controller) {
  return Obx(() {
    final devices = controller.dashboardDevices;
    if (devices.isEmpty) {
      return _buildNoDevicesFound();
    }

    final reliableController =
        Get.isRegistered<ReliableSocketController>(
          tag: 'smartDevicesController',
        )
        ? Get.find<ReliableSocketController>(tag: 'smartDevicesController')
        : Get.put(
            ReliableSocketController(
              controller.token,
              devices.map((d) => d.deviceId).toList(),
            ),
            tag: 'smartDevicesController',
            permanent: true,
          );

    reliableController.updateDeviceList(
      devices.map((d) => d.deviceId).toList(),
    );
return Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    // 🔹 عنوان بالا
// Padding(
//   padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//   child: Align(
//     alignment: Alignment.centerRight, // متن سمت راست بالا
//     child: const Text(
//       'دستگاه‌ها',
//       textDirection:ui.TextDirection.rtl, // برای اطمینان از راست‌چینی
//       style: TextStyle(
//         fontSize: 20,
//         fontWeight: FontWeight.bold,
//       ),
//     ),
//   ),
// ),
    // 🔹 اسلایدر دستگاه‌ها
    SizedBox(
      height: 280,
      child: Builder(
        builder: (context) {
          final pageController = PageController(viewportFraction: 0.85);
          final currentPage = 0.obs;

          pageController.addListener(() {
            if (pageController.page != null) {
              currentPage.value = pageController.page!.round();
            }
          });

          return Column(
            children: [
              Expanded(
                child: PageView.builder(
                  controller: pageController,
                  physics: const BouncingScrollPhysics(),
                  itemCount: devices.length,
                  clipBehavior: Clip.none,
                  itemBuilder: (context, index) {
                    final device = devices[index];

                    return AnimatedBuilder(
                      animation: pageController,
                      builder: (context, child) {
                        double scale = 1.0;
                        double opacity = 1.0;

                        if (pageController.position.haveDimensions) {
                          final page = pageController.page ?? 0.0;
                          final diff = (index - page).abs();
                          scale = (1 - (diff * 0.1)).clamp(0.9, 1.0);
                          opacity = (1 - (diff * 0.5)).clamp(0.5, 1.0);
                        }

                        return Opacity(
                          opacity: opacity,
                          child: Transform.scale(
                            scale: scale,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8)
                                  .copyWith(top: 25),
                              child: SizedBox(
                                width: 280,
                                child: Obx(() {
                                  final deviceData = reliableController
                                          .latestDeviceDataById[device.deviceId];

                                  bool switch1On = false;
                                  bool switch2On = false;
                                  Color iconColor1 = Colors.grey;
                                  Color iconColor2 = Colors.grey;

                                  if (deviceData != null) {
                                    // بررسی TW1 و TD1
                                    final key1Entries = [
                                      if (deviceData['TW1'] is List)
                                        ...deviceData['TW1'],
                                      if (deviceData['TD1'] is List)
                                        ...deviceData['TD1'],
                                    ];
                                    if (key1Entries.isNotEmpty) {
                                      key1Entries.sort((a, b) =>
                                          (b[0] as int).compareTo(a[0] as int));
                                      final val = key1Entries.first[1];
                                      switch1On = val is Map
                                          ? val['c']
                                                  ?.toString()
                                                  .contains('On') ??
                                              false
                                          : val.toString().contains('On');
                                    }

                                    // بررسی TW2 و TD2
                                    final key2Entries = [
                                      if (deviceData['TW2'] is List)
                                        ...deviceData['TW2'],
                                      if (deviceData['TD2'] is List)
                                        ...deviceData['TD2'],
                                    ];
                                    if (key2Entries.isNotEmpty) {
                                      key2Entries.sort((a, b) =>
                                          (b[0] as int).compareTo(a[0] as int));
                                      final val = key2Entries.first[1];
                                      switch2On = val is Map
                                          ? val['c']
                                                  ?.toString()
                                                  .contains('On') ??
                                              false
                                          : val.toString().contains('On');
                                    }

                                    // بررسی رنگ LED
                                    if (deviceData['ledColor'] is List &&
                                        deviceData['ledColor'].isNotEmpty) {
                                      final ledEntry =
                                          deviceData['ledColor'][0][1];
                                      Map<String, dynamic> ledMap;
                                      if (ledEntry is String) {
                                        try {
                                          ledMap = jsonDecode(ledEntry);
                                        } catch (e) {
                                          ledMap = {};
                                        }
                                      } else if (ledEntry
                                          is Map<String, dynamic>) {
                                        ledMap = ledEntry;
                                      } else {
                                        ledMap = {};
                                      }

                                      if (ledMap.isNotEmpty) {
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
                                  }

                                  final isSingleKey =
                                      device.deviceTypeName == 'key-1';

                                  return _buildSmartDeviceCard(
                                    title: device.title,
                                    deviceId: device.deviceId,
                                    switch1On: switch1On,
                                    switch2On: switch2On,
                                    iconColor1: iconColor1,
                                    iconColor2: iconColor2,
                                    onToggle: (switchNumber, value) async {
                                      await reliableController.toggleSwitch(
                                        value,
                                        switchNumber,
                                        device.deviceId,
                                      );
                                    },
                                    isSingleKey: isSingleKey,
                                    device: device,
                                  );
                                }),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),

              // 🔹 نقطه‌های نشانگر پایین
              Obx(() {
                return Padding(
                  padding: const EdgeInsets.only(top: 4, bottom: 2),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      devices.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: currentPage.value == index ? 12 : 8,
                        height: currentPage.value == index ? 12 : 8,
                        decoration: BoxDecoration(
                          color: currentPage.value == index
                              ? Colors.blueAccent
                              : Colors.grey.shade400,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ],
          );
        },
      ),
    ),
  ],
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
  required DeviceItem device,
}) {
  final reliableController = Get.find<ReliableSocketController>(
    tag: 'smartDevicesController',
  );

  bool anySwitchOn = switch1On || (!isSingleKey && (switch2On ?? false));
  Color borderColor = anySwitchOn ? Colors.blue.shade400 : Colors.grey.shade400;
  final homeController = Get.find<HomeController>();

return ConstrainedBox(
  constraints: const BoxConstraints(minHeight: 310, maxHeight: 350), // فقط 10px اضافه شد
  child: Stack(
    clipBehavior: Clip.none,
    children: [
      Card(
        color: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: borderColor, width: 2),
        ),
        shadowColor: Colors.black12,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 38, 12, 14), // بالا +2px، پایین +2px
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // 🔹 ردیف بالایی (کلیدها + اطلاعات)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildSwitchRow(
                          deviceId: deviceId,
                          switchNumber: 1,
                          onToggle: onToggle,
                        ),
                        if (!isSingleKey)
                          _buildSwitchRow(
                            deviceId: deviceId,
                            switchNumber: 2,
                            onToggle: onToggle,
                          ),
                        const SizedBox(height: 4), // اضافه شد برای کمی ارتفاع
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // وضعیت آنلاین/آفلاین و نوع کلید
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                            Obx(() {
                              final lastSeen =
                                  reliableController.lastDeviceActivity[deviceId];
                              final isOnline = lastSeen != null &&
                                  DateTime.now().difference(lastSeen) <
                                      const Duration(seconds: 30);
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: isOnline ? Colors.blue : Colors.grey,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  isOnline ? "آنلاین" : "آفلاین",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              );
                            }),
                            const SizedBox(width: 6),
                            Text(
                              isSingleKey ? "کلید تک پل" : "کلید دو پل",
                              textAlign: TextAlign.right,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        // عنوان دستگاه
                        Text(
                          title,
                          textAlign: TextAlign.right,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        // مکان دستگاه با آیکن
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Flexible(
                              child: Text(
                                device.dashboardTitle ?? "بدون مکان",
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade600,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 4),
                            SvgPicture.asset(
                              'assets/svg/location.svg',
                              width: 24,
                              height: 24,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 2),

                // 🔸 ردیف پایین کارت (SVG سمت راست + سه‌نقطه + آخرین همگام‌سازی)
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    

                    // منوی سه‌نقطه
                    PopupMenuButton<int>(
                      color: Colors.white,
                      icon: const Icon(
                        Icons.more_vert,
                        size: 20,
                        color: Colors.black87,
                      ),
                      onSelected: (value) async {
                        if (value == 1) {
                          Get.to(() => EditDevicePage(
                                deviceId: device.deviceId,
                                serialNumber: device.sn,
                                initialName: device.title ?? '',
                                initialDashboardId: device.dashboardId ?? '',
                              ));
                        }else if (value == 2) {
      // 🔹 حذف از داشبورد
      final token = homeController.token;
      if (token == null) {
        Get.snackbar("خطا", "توکن معتبر پیدا نشد",
            backgroundColor: Colors.red, colorText: Colors.white);
        return;
      }

      final headers = {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };

      final data = {"deviceId": device.deviceId};

      try {
        final dio = Dio();
        final response = await dio.post(
          'http://45.149.76.245:8080/api/device/removeFromHome',
          data: data,
          options: Options(headers: headers),
        );
        if (response.statusCode == 200 || response.statusCode == 201) {
          Get.snackbar(
            'موفقیت',
            'دستگاه از داشبورد حذف شد',
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
          await homeController.refreshAllData();
        }
      } catch (e) {
        Get.snackbar(
          'خطا',
          'مشکل در حذف از داشبورد: $e',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } else if (value == 3) {
                          await homeController.removeFromAllDashboard(device.deviceId);
                          await homeController.refreshAllData();
                          Get.snackbar('موفقیت', 'کلید از همه مکان‌ها حذف موقت شد',
                              backgroundColor: Colors.green,
                              colorText: Colors.white);
                        } else if (value == 4) {
                          await homeController.completeRemoveDevice(device.deviceId);
                          await homeController.refreshAllData();
                          Get.snackbar('موفقیت', 'دستگاه با موفقیت حذف شد',
                              backgroundColor: Colors.green,
                              colorText: Colors.white);
                        } else if (value == 5) {
  Get.dialog(
    Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "بازنشانی / پیکربندی",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              "می‌خواهید چه کاری انجام دهید؟",
              style: TextStyle(fontSize: 14, color: Colors.black54),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            // --- گزینه پیکربندی ---
            Card(
              color: const Color(0xFFF8F9FA),
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  Get.back();
                  Get.to(() => DeviceConfigPage(sn: device.sn));
                },
                child: ListTile(
                  trailing: const Icon(Icons.settings, color: Colors.blueAccent),
                  title: const Text(
                    textDirection: ui.TextDirection.rtl,
                    "رفتن به پیکربندی",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                ),
              ),
            ),

            const SizedBox(height: 10),

            // --- گزینه ریست ---
            Card(
              color: const Color(0xFFF8F9FA),
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () async {
                  Get.back();
                  await homeController.resetDevice(device.deviceId);
                  Get.snackbar(
                    'موفقیت',
                    'دستگاه ریست شد',
                    backgroundColor: Colors.green,
                    colorText: Colors.white,
                  );
                },
                child: ListTile(
                  trailing: const Icon(Icons.refresh, color: Colors.redAccent),
                  title: const Text(
                    textDirection: ui.TextDirection.rtl,
                    "ریست دستگاه",
                    style: TextStyle(
                      color: Colors.redAccent,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                ),
              ),
            ),

            const SizedBox(height: 10),

            // --- گزینه انصراف ---
            Card(
              color: const Color(0xFFF8F9FA),
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => Get.back(),
                child: ListTile(
                  trailing: const Icon(Icons.cancel, color: Colors.amber),
                  title: const Text(
                    textDirection: ui.TextDirection.rtl,
                    "انصراف",
                    style: TextStyle(
                      color: Colors.amber,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem<int>(
                          value: 1,
                          child: Row(
                            textDirection: ui.TextDirection.rtl,
                            children: [
                              SvgPicture.asset('assets/svg/edit.svg',
                                  width: 20, height: 20, color: Colors.blueAccent),
                              const SizedBox(width: 2),
                              const Text('ویرایش کلید',
                                  style: TextStyle(color: Colors.black)),
                            ],
                          ),
                        ),
                        PopupMenuItem<int>(
                          value: 5,
                          child: Row(
                            textDirection: ui.TextDirection.rtl,
                            children: [
                              SvgPicture.asset('assets/svg/reset.svg',
                                  width: 20, height: 20),
                              const SizedBox(width: 2),
                              const Text('بازنشانی / پیکربندی',
                                  style: TextStyle(color: Colors.black)),
                            ],
                          ),
                        ),
                        const PopupMenuDivider(),
                         PopupMenuItem<int>(
      value: 2,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        textDirection: ui.TextDirection.rtl,
        children: [
          SvgPicture.asset('assets/svg/add_dashboard.svg',
              width: 20, height: 20, color: Colors.red),
          const SizedBox(width: 4),
          const Text('حذف از داشبورد', style: TextStyle(color: Colors.red)),
        ],
      ),
    ),
                        PopupMenuItem<int>(
                          value: 3,
                          child: Row(
                            textDirection: ui.TextDirection.rtl,
                            children: [
                              SvgPicture.asset('assets/svg/delete_temp.svg',
                                  width: 20, height: 20, color: Colors.red),
                              const SizedBox(width: 2),
                              const Text('حذف موقت',
                                  style: TextStyle(color: Colors.red)),
                            ],
                          ),
                        ),
                        PopupMenuItem<int>(
                          value: 4,
                          child: Row(
                            textDirection: ui.TextDirection.rtl,
                            children: [
                              SvgPicture.asset('assets/svg/deleting.svg',
                                  width: 20, height: 20, color: Colors.red),
                              const SizedBox(width: 2),
                              const Text('حذف کامل',
                                  style: TextStyle(color: Colors.red)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    // const SizedBox(width:2),
                    // آیکن تنظیمات LED (سمت راست)
                    GestureDetector(
                      onTap: () {
                        showLedColorDialog(device: device);
                      },
                      child: SvgPicture.asset(
                        'assets/svg/advanced_settings.svg',
                        width: 15,
                        height: 15,
                        color: Colors.black87,
                      ),
                    ),
                    

                    const Spacer(),

                    // آخرین همگام‌سازی
Flexible(
  child: Obx(() {
    final lastSeen = reliableController.lastDeviceActivity[deviceId];

    String displayText;
    if (lastSeen != null) {
      final formattedDate =
          "${lastSeen.year}/${lastSeen.month.toString().padLeft(2, '0')}/${lastSeen.day.toString().padLeft(2, '0')}";
      final formattedTime =
          "${lastSeen.hour.toString().padLeft(2, '0')}:${lastSeen.minute.toString().padLeft(2, '0')}:${lastSeen.second.toString().padLeft(2, '0')}";
      displayText = "$formattedDate - $formattedTime";
    } else {
      displayText = "نامشخص";
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        
        
        Flexible(
          child: Text(
            displayText,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 10,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            softWrap: true,
            textAlign: TextAlign.right,
          ),
        ),
        SizedBox(width: 4),
        Icon(
          Icons.access_time,
          color: Colors.grey[600],
          size: 14,
        ),
      ],
    );
  }),
),

                  ],
                ),
              ],
            ),
          ),
        ),

        // 🔵 آیکن لامپ بالا وسط
        Positioned(
          top: -15,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              width: 45,
              height: 45,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color:
                      anySwitchOn ? Colors.blue.shade400 : Colors.grey.shade400,
                  width: 3,
                ),
                boxShadow: [
                  if (anySwitchOn)
                    BoxShadow(
                      color: Colors.blue.shade200.withOpacity(0.5),
                      blurRadius: 5,
                      spreadRadius: 1,
                    ),
                ],
              ),
              child: ClipOval(
                child: SvgPicture.asset(
                  anySwitchOn ? 'assets/svg/on.svg' : 'assets/svg/off.svg',
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}


  // ------------------- ستون کلید (Switch Row) اصلاح شده -------------------
Widget _buildSwitchRow({
  required String deviceId,
  required int switchNumber,
  required Function(int switchNumber, bool value) onToggle,
}) {
  final reliableController = Get.find<ReliableSocketController>(
    tag: 'smartDevicesController',
  );

  bool _safeSwitch(List<dynamic>? entries) {
    if (entries == null || entries.isEmpty) return false;
    try {
      entries.sort((a, b) => (b[0] as int).compareTo(a[0] as int));
      final lastEntry = entries.first[1];
      if (lastEntry is Map && lastEntry.containsKey('c')) {
        return lastEntry['c'].toString().contains('On');
      }
      return lastEntry.toString().contains('On');
    } catch (_) {
      return false;
    }
  }

  Color _safeColor(Map<String, dynamic>? map, bool isOn, String key) {
    if (map == null) return isOn ? Colors.lightBlueAccent : Colors.grey;
    final section = map[key]?[isOn ? 'on' : 'off'];
    if (section == null) return isOn ? Colors.lightBlueAccent : Colors.grey;
    return Color.fromARGB(
      255,
      (section['r'] ?? (isOn ? 0 : 128)).toInt(),
      (section['g'] ?? (isOn ? 180 : 128)).toInt(),
      (section['b'] ?? (isOn ? 255 : 128)).toInt(),
    );
  }

  return Obx(() {
    final deviceData = reliableController.latestDeviceDataById[deviceId];

    bool isOn = false;
    Map<String, dynamic>? ledMap;

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

      isOn = _safeSwitch(keyEntries);

      if (deviceData['ledColor'] is List && deviceData['ledColor'].isNotEmpty) {
        final ledEntry = deviceData['ledColor'][0][1];
        if (ledEntry is String) {
          try {
            ledMap = jsonDecode(ledEntry);
          } catch (_) {
            ledMap = null;
          }
        } else if (ledEntry is Map<String, dynamic>) {
          ledMap = ledEntry;
        }
      }
    }

    final Color circleColor =
        _safeColor(ledMap, isOn, switchNumber == 1 ? 't1' : 't2');
    final Color buttonColor = isOn ? Colors.lightBlueAccent : Colors.grey.shade400;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          // دایره رنگ وضعیت
          Container(
            width: 15,
            height: 15,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: circleColor,
              boxShadow: [
                if (isOn)
                  BoxShadow(
                    color: circleColor.withOpacity(0.6),
                    blurRadius: 6,
                    spreadRadius: 2,
                  ),
              ],
            ),
          ),
          const SizedBox(width: 4),

          // دکمه روشن/خاموش
          GestureDetector(
            onTap: () => onToggle(switchNumber, !isOn),
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: buttonColor,
              ),
              child: const Icon(
                Icons.power_settings_new,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 2),

          // نام کلید
          Text(
            "کلید $switchNumber",
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  });
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
  void showLedColorDialog({required DeviceItem device}) {
  final reliableController = Get.find<ReliableSocketController>(
    tag: 'smartDevicesController',
  );
  final deviceData = reliableController.latestDeviceDataById[device.deviceId];
  final isSingleKey = device.deviceTypeName == 'key-1';

  // Reactive colors
  Rx<Color> touch1On = const Color(0xFF2196F3).obs;
  Rx<Color> touch1Off = const Color(0xFF9E9E9E).obs;
  Rx<Color> touch2On = const Color(0xFF4CAF50).obs;
  Rx<Color> touch2Off = const Color(0xFF9E9E9E).obs;

  // مقداردهی اولیه از داده دستگاه
  if (deviceData != null &&
      deviceData['ledColor'] is List &&
      deviceData['ledColor'].isNotEmpty) {
    try {
      final ledEntry = deviceData['ledColor'][0][1];
      Map<String, dynamic> ledMap = ledEntry is String
          ? jsonDecode(ledEntry)
          : (ledEntry as Map<String, dynamic>);

      if (ledMap['t1'] != null) {
        touch1On.value = Color.fromARGB(
          255,
          (ledMap['t1']['on']['r'] as int).clamp(0, 255),
          (ledMap['t1']['on']['g'] as int).clamp(0, 255),
          (ledMap['t1']['on']['b'] as int).clamp(0, 255),
        );
        touch1Off.value = Color.fromARGB(
          255,
          (ledMap['t1']['off']['r'] as int).clamp(0, 255),
          (ledMap['t1']['off']['g'] as int).clamp(0, 255),
          (ledMap['t1']['off']['b'] as int).clamp(0, 255),
        );
      }

      if (!isSingleKey && ledMap['t2'] != null) {
        touch2On.value = Color.fromARGB(
          255,
          (ledMap['t2']['on']['r'] as int).clamp(0, 255),
          (ledMap['t2']['on']['g'] as int).clamp(0, 255),
          (ledMap['t2']['on']['b'] as int).clamp(0, 255),
        );
        touch2Off.value = Color.fromARGB(
          255,
          (ledMap['t2']['off']['r'] as int).clamp(0, 255),
          (ledMap['t2']['off']['g'] as int).clamp(0, 255),
          (ledMap['t2']['off']['b'] as int).clamp(0, 255),
        );
      }
    } catch (e) {
      print("❗️Error parsing ledColor: $e");
    }
  }

  showDialog(
    context: Get.context!,
    barrierDismissible: false,
    builder: (context) {
      return AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        titlePadding: EdgeInsets.zero,
        title: Container(
          decoration: BoxDecoration(
            color: Colors.blue,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            border: Border.all(color: Colors.blue, width: 2),
          ),
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          child: const Center(
            child: Text(
              'تنظیمات پیشرفته',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Obx(() => _ColorPreviewPicker(
                    label: 'کلید ۱ روشن',
                    color: touch1On.value,
                    onPick: (c) => touch1On.value = c,
                  )),
              Obx(() => _ColorPreviewPicker(
                    label: 'کلید ۱ خاموش',
                    color: touch1Off.value,
                    onPick: (c) => touch1Off.value = c,
                  )),
              if (!isSingleKey) ...[
                const SizedBox(height: 8),
                Obx(() => _ColorPreviewPicker(
                      label: 'کلید ۲ روشن',
                      color: touch2On.value,
                      onPick: (c) => touch2On.value = c,
                    )),
                Obx(() => _ColorPreviewPicker(
                      label: 'کلید ۲ خاموش',
                      color: touch2Off.value,
                      onPick: (c) => touch2Off.value = c,
                    )),
              ],
            ],
          ),
        ),
        actions: [
          Align(
            alignment: Alignment.centerLeft,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 100,
                  height: 44,
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFFF39530),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: const BorderSide(
                          color: Color(0xFFF39530),
                          width: 2,
                        ),
                      ),
                    ),
                    child: const Text(
                      "انصراف",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                SizedBox(
                  width: 100,
                  height: 44,
                  child: ElevatedButton(
                    onPressed: () async {
                      // 🔹 ارسال رنگ‌ها به API
                      try {
                        final token = controller.token;
                        final dio = Dio();
                        final headers = {
                          'Authorization': 'Bearer $token',
                          'Content-Type': 'application/json',
                        };

                        final data = json.encode({
                          "deviceId": device.deviceId,
                          "request": {
                            "ledColor": {
                              "t1": {
                                "on": {
                                  "r": touch1On.value.red,
                                  "g": touch1On.value.green,
                                  "b": touch1On.value.blue,
                                },
                                "off": {
                                  "r": touch1Off.value.red,
                                  "g": touch1Off.value.green,
                                  "b": touch1Off.value.blue,
                                },
                              },
                              if (!isSingleKey)
                                "t2": {
                                  "on": {
                                    "r": touch2On.value.red,
                                    "g": touch2On.value.green,
                                    "b": touch2On.value.blue,
                                  },
                                  "off": {
                                    "r": touch2Off.value.red,
                                    "g": touch2Off.value.green,
                                    "b": touch2Off.value.blue,
                                  },
                                },
                            },
                          },
                        });

                        print('🔹 Sending LED color payload: $data');

                        final response = await dio.post(
                          'http://45.149.76.245:8080/api/plugins/telemetry/changeColor',
                          options: Options(headers: headers),
                          data: data,
                        );

                        if (response.statusCode == 200) {
                          print('✅ Success: ${response.data}');
                          Get.snackbar(
                            'موفق',
                            'رنگ کلید با موفقیت تغییر کرد',
                            backgroundColor: Colors.green,
                            colorText: Colors.white,
                            snackPosition: SnackPosition.TOP,
                          );
                          Navigator.of(context).pop();
                        } else {
                          print('⚠️ Response: ${response.statusCode} ${response.data}');
                          Get.snackbar(
                            'خطا',
                            'خطا در تغییر رنگ: ${response.data}',
                            backgroundColor: Colors.red,
                            colorText: Colors.white,
                            snackPosition: SnackPosition.TOP,
                          );
                        }
                      } on DioException catch (e) {
                        print('❌ Dio error: ${e.message}');
                        Get.snackbar(
                          'خطا',
                          'خطا در ارتباط با سرور: ${e.message}',
                          backgroundColor: Colors.red,
                          colorText: Colors.white,
                          snackPosition: SnackPosition.TOP,
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 2,
                    ),
                    child: const Text(
                      'ثبت',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
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
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  titlePadding: const EdgeInsets.all(16),
                  title: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                      border: Border.all(color: Colors.blue, width: 2),
                    ),
                    child: const Center(
                      child: Text(
                        'تغییر رنگ کلید',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                    ),
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
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 8,
                                offset: Offset(0, 2),
                              ),
                            ],
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
                  actionsPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  actions: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // دکمه انصراف
                          SizedBox(
                            width: 100,
                            height: 44,
                            child: TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              style: TextButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: const Color(0xFFF39530),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  side: const BorderSide(
                                    color: Color(0xFFF39530),
                                    width: 2,
                                  ),
                                ),
                              ),
                              child: const Text(
                                "انصراف",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          // دکمه تایید همیشه آبی
                          SizedBox(
                            width: 100,
                            height: 44,
                            child: ElevatedButton(
                              onPressed: () => Navigator.of(context).pop(tempColor),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                elevation: 2,
                              ),
                              child: const Text(
                                'تایید',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
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
              boxShadow: const [
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
