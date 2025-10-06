import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'package:my_app32/app/services/realable_controller.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_app32/app/core/app_constants.dart';
import 'package:my_app32/app/core/base/base_view.dart';
import 'package:my_app32/app/services/weather_service.dart';
import 'package:my_app32/features/config/device_config_page.dart';
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
    final controller = Get.find<HomeController>();
    // وقتی صفحه ساخته میشه بلافاصله داده‌ها رو تازه می‌کنه
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.refreshAllData();
    });

    return DefaultTabController(
      length: 3,
      child: Builder(
        builder: (context) {
          final tabController = DefaultTabController.of(context);
          return Scaffold(
            endDrawer: const Sidebar(),
            appBar: CustomAppBar(isRefreshing: controller.isRefreshing),

            body: TabBarView(
              children: [
                _buildMainContent(controller),
                const Center(child: Text('To be Built Soon')),
                const Center(child: Text('Under Construction')),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMainContent(HomeController controller) {
    return Obx(() {
      final devices = controller.dashboardDevices;
      print(devices);

      return RefreshIndicator(
        onRefresh: controller.refreshAllData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),

              // --- چهار بخش بالای همه ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final width = constraints.maxWidth;
                    final height = width / 3; // کاهش ارتفاع برای جمع‌وجور شدن
                    return SizedBox(
                      width: width,
                      height: height,
                      child: Stack(
                        children: [
                          // بالا سمت راست: Weather
                          Positioned(
                            top: 8,
                            right: 8,
                            width: width / 2 - 16,
                            height: height / 2 - 8,
                            child: WeatherDisplay(
                              weatherFuture: controller.weatherFuture,
                            ),
                          ),

                          // پایین سمت راست: آیکون SVG
                          Positioned(
                            bottom: 8,
                            right: 8,
                            width: width / 2 - 16,
                            height: height / 2 - 8,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.7),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: SvgPicture.asset(
                                  'assets/svg/enableDevice.svg',
                                  width: 100,
                                  height: 100,
                                ),
                              ),
                            ),
                          ),

                          // بالا سمت چپ: آیکون SVG
                          Positioned(
                            top: 8,
                            left: 8,
                            width: width / 2 - 16,
                            height: height / 2 - 8,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.7),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: SvgPicture.asset(
                                  'assets/svg/enableSencor.svg',
                                  width: 100,
                                  height: 100,
                                ),
                              ),
                            ),
                          ),

                          // پایین سمت چپ: ساعت و تاریخ + آیکون
                          // پایین سمت چپ: ساعت و تاریخ + آیکون
                          Positioned(
                            bottom: 8,
                            left: 8,
                            width: width / 2 - 16,
                            height: height / 2 - 8,
                            child: Container(
                              padding: const EdgeInsets.all(4), // کمتر شد
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.7),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment:
                                    CrossAxisAlignment.center, // وسط آیکون
                                children: [
                                  // ساعت و تاریخ + متن کوچک
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      StreamBuilder<DateTime>(
                                        stream: Stream.periodic(
                                          const Duration(seconds: 1),
                                          (_) => DateTime.now(),
                                        ),
                                        builder: (context, snapshot) {
                                          final now =
                                              snapshot.data ?? DateTime.now();
                                          final time = DateFormat.Hm().format(
                                            now,
                                          );
                                          final date = DateFormat.yMd().format(
                                            now,
                                          );
                                          return Row(
                                            children: [
                                              Text(
                                                time,
                                                style: const TextStyle(
                                                  fontSize: 14, // کوچکتر شد
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                date,
                                                style: const TextStyle(
                                                  fontSize: 12, // کوچکتر شد
                                                  fontWeight: FontWeight.w500,
                                                  color: Colors.black54,
                                                ),
                                              ),
                                            ],
                                          );
                                        },
                                      ),
                                      const SizedBox(height: 2),
                                      const Text(
                                        'تاریخ و ساعت',
                                        style: TextStyle(
                                          fontSize: 8,
                                          color: Colors.black54,
                                        ), // کوچکتر شد
                                      ),
                                    ],
                                  ),
                                  // آیکون سمت راست وسط ستون
                                  SvgPicture.asset(
                                    'assets/svg/time.svg',
                                    width: 24, // کمی کوچکتر شد
                                    height: 24,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 36),

              // Grid یا حالت خالی دستگاه‌ها
              if (devices.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          height: 200,
                          child: SvgPicture.asset(
                            'assets/svg/EmptyDashboard.svg',
                            fit: BoxFit.fill,
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                )
              else
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _buildSmartDevicesGrid(controller),
                ),
              const SizedBox(height: 32), // ✅ فاصله پایین Grid
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

      // final devices = controller.dashboardDevices ?? [];

      if (devices.isEmpty) {
        return _buildNoDevicesFound(); // حالت خالی بدون خطا
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

      return SizedBox(
        height: 280,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: devices.map((device) {
              return Obx(() {
                final deviceData =
                    reliableController.latestDeviceDataById[device.deviceId];

                bool switch1On = false;
                bool switch2On = false;
                Color iconColor1 = Colors.grey;
                Color iconColor2 = Colors.grey;

                if (deviceData != null) {
                  final key1Entries = [
                    if (deviceData['Touch_W1'] is List)
                      ...deviceData['Touch_W1'],
                    if (deviceData['Touch_D1'] is List)
                      ...deviceData['Touch_D1'],
                  ];
                  if (key1Entries.isNotEmpty) {
                    key1Entries.sort(
                      (a, b) => (b[0] as int).compareTo(a[0] as int),
                    );
                    switch1On = key1Entries.first[1].toString().contains('On');
                  }

                  final key2Entries = [
                    if (deviceData['Touch_W2'] is List)
                      ...deviceData['Touch_W2'],
                    if (deviceData['Touch_D2'] is List)
                      ...deviceData['Touch_D2'],
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

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: SizedBox(
                    width: 280, // پهنای ثابت کارت‌ها
                    child: _buildSmartDeviceCard(
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
                    ),
                  ),
                );
              });
            }).toList(),
          ),
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
    required DeviceItem device,
  }) {
    final reliableController = Get.find<ReliableSocketController>(
      tag: 'smartDevicesController',
    );

    bool anySwitchOn = switch1On || (!isSingleKey && (switch2On ?? false));
    Color borderColor = anySwitchOn
        ? Colors.blue.shade400
        : Colors.grey.shade400;

    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 200, maxHeight: 250),
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
              padding: const EdgeInsets.fromLTRB(12, 32, 12, 12),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // بالای کارت: سوئیچ‌ها و عنوان
                  // بالای کارت: سوئیچ‌ها و عنوان
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween, // عنوان سمت راست
                    children: [
                      // ستون سوئیچ‌ها
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildSwitchRow(
                            deviceId: deviceId,
                            switchNumber: 1,
                            color: iconColor1,
                            onToggle: onToggle,
                          ),
                          if (!isSingleKey)
                            _buildSwitchRow(
                              deviceId: deviceId,
                              switchNumber: 2,
                              color: iconColor2 ?? Colors.grey,
                              onToggle: onToggle,
                            ),
                        ],
                      ),

                      // عنوان دستگاه
                      Text(
                        title,
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),

                  // پایین کارت: دکمه منو سمت چپ و وضعیت آنلاین/آفلاین سمت راست
                  Row(
                    children: [
                      // دکمه سه‌نقطه منو سمت چپ
                      Align(
                        alignment: Alignment.bottomLeft,
                        child: PopupMenuButton<int>(
                          color: Colors.white,
                          icon: const Icon(
                            Icons.more_vert,
                            size: 20,
                            color: Colors.black87,
                          ),
                          onSelected: (value) async {
                            final homeController = Get.find<HomeController>();

                            if (value == 0) {
                              showLedColorDialog(device: device);
                            } else if (value == 1) {
                              Get.to(() => DeviceConfigPage(sn: device.sn));
                            } else if (value == 2) {
                              // حذف از میانبر
                              final token = homeController.token;
                              if (token == null) {
                                Get.snackbar("خطا", "توکن معتبر پیدا نشد");
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
                                if (response.statusCode == 200 ||
                                    response.statusCode == 201) {
                                  Get.snackbar(
                                    'موفقیت',
                                    'دستگاه از داشبورد حذف شد',
                                    backgroundColor: Colors.green,
                                    colorText: Colors.white,
                                  );
                                  await homeController.refreshAllData();
                                }
                              } catch (e) {
                                print("Error removing device from home: $e");
                              }
                            } else if (value == 3) {
                              await homeController.removeFromAllDashboard(
                                device.deviceId,
                              );
                            } else if (value == 4) {
                              await homeController.completeRemoveDevice(
                                device.deviceId,
                              );
                            } else if (value == 5) {
                              // ریست دستگاه
                              await homeController.resetDevice(device.deviceId);
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 0,
                              child: Text(
                                'تنظیمات پیشرفته',
                                style: TextStyle(color: Colors.black),
                              ),
                            ),
                            const PopupMenuItem(
                              value: 1,
                              child: Text(
                                'پیکربندی',
                                style: TextStyle(color: Colors.black),
                              ),
                            ),
                            const PopupMenuItem(
                              value: 2,
                              child: Text(
                                'حذف از داشبورد',
                                style: TextStyle(color: Colors.black),
                              ),
                            ),
                            const PopupMenuItem(
                              value: 3,
                              child: Text(
                                'حذف موقت کلید از همه مکانها',
                                style: TextStyle(color: Colors.black),
                              ),
                            ),
                            const PopupMenuItem(
                              value: 4,
                              child: Text(
                                'حذف کامل دستگاه',
                                style: TextStyle(color: Colors.black),
                              ),
                            ),
                            const PopupMenuItem(
                              value: 5,
                              child: Text(
                                'ریست دستگاه',
                                style: TextStyle(color: Colors.black),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const Spacer(),

                      // وضعیت آنلاین/آفلاین سمت راست
                      Obx(() {
                        final lastSeen =
                            reliableController.lastDeviceActivity[deviceId];
                        final isOnline =
                            lastSeen != null &&
                            DateTime.now().difference(lastSeen) <
                                const Duration(seconds: 30);

                        if (isOnline) {
                          return const Text(
                            "آنلاین",
                            style: TextStyle(
                              color: Colors.green,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          );
                        } else {
                          String lastActivityText;
                          if (lastSeen != null) {
                            final formattedDate =
                                "${lastSeen.year}/${lastSeen.month.toString().padLeft(2, '0')}/${lastSeen.day.toString().padLeft(2, '0')}";
                            final formattedTime =
                                "${lastSeen.hour.toString().padLeft(2, '0')}:${lastSeen.minute.toString().padLeft(2, '0')}:${lastSeen.second.toString().padLeft(2, '0')}";
                            lastActivityText =
                                "آخرین فعالیت: $formattedDate - $formattedTime";
                          } else {
                            lastActivityText = "آخرین فعالیت: نامشخص";
                          }

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Text(
                                "آفلاین",
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                lastActivityText,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          );
                        }
                      }),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // دایره لامپ بالا وسط
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
                    color: anySwitchOn
                        ? Colors.blue.shade400
                        : Colors.grey.shade400,
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
                if (deviceData['Touch_W1'] is List) ...deviceData['Touch_W1'],
                if (deviceData['Touch_D1'] is List) ...deviceData['Touch_D1'],
              ]
            : [
                if (deviceData['Touch_W2'] is List) ...deviceData['Touch_W2'],
                if (deviceData['Touch_D2'] is List) ...deviceData['Touch_D2'],
              ];

        if (keyEntries.isNotEmpty) {
          keyEntries.sort((a, b) => (b[0] as int).compareTo(a[0] as int));
          isOn = keyEntries.first[1].toString().contains('On');
        }
      }

      return Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 10,
        ), // فاصله بیشتر بین کلیدها
        child: Row(
          children: [
            // دایره رنگ وضعیت (بزرگتر)
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

            // دکمه روشن/خاموش (بزرگتر)
            GestureDetector(
              onTap: () => onToggle(switchNumber, !isOn),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isOn ? Colors.lightBlueAccent : Colors.grey.shade400,
                ),
                child: const Icon(
                  Icons.power_settings_new,
                  color: Colors.white,
                  size: 20, // آیکون کمی بزرگتر
                ),
              ),
            ),
            const SizedBox(width: 10),

            // اسم کلید (فونت بزرگتر)
            Text(
              "کلید $switchNumber",
              style: const TextStyle(
                fontSize: 16, // فونت بزرگتر
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
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
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
          actionsPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          actionsAlignment: MainAxisAlignment.spaceBetween,
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                backgroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: Colors.yellow),
                ),
              ),
              child: const Text(
                'انصراف',
                style: TextStyle(
                  color: Colors.yellow,
                  fontWeight: FontWeight.bold,
                ),
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'ثبت',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
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
          backgroundColor: Colors.white, // بک‌گراند فرم سفید
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          titlePadding: EdgeInsets.zero,
          title: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Colors.blue, // هدر آبی
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
                Obx(
                  () => _ColorPreviewPicker(
                    label: 'کلید ۱ روشن',
                    color: touch1On.value,
                    onPick: (c) => touch1On.value = c,
                  ),
                ),
                Obx(
                  () => _ColorPreviewPicker(
                    label: 'کلید ۱ خاموش',
                    color: touch1Off.value,
                    onPick: (c) => touch1Off.value = c,
                  ),
                ),
                if (!isSingleKey) ...[
                  const SizedBox(height: 8),
                  Obx(
                    () => _ColorPreviewPicker(
                      label: 'کلید ۲ روشن',
                      color: touch2On.value,
                      onPick: (c) => touch2On.value = c,
                    ),
                  ),
                  Obx(
                    () => _ColorPreviewPicker(
                      label: 'کلید ۲ خاموش',
                      color: touch2Off.value,
                      onPick: (c) => touch2Off.value = c,
                    ),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.yellow, // متن زرد
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
              child: const Text("انصراف"),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  final token2 = controller.token;
                  var headers = {
                    'Authorization': 'Bearer $token2',
                    'Content-Type': 'application/json',
                  };

                  var data = json.encode({
                    "deviceId": device.deviceId,
                    "request": {
                      "ledColor": {
                        "touch1": {
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
                          "touch2": {
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

                  var dio = Dio();
                  var response = await dio.request(
                    'http://45.149.76.245:8080/api/plugins/telemetry/changeColor',
                    options: Options(method: 'POST', headers: headers),
                    data: data,
                  );

                  if (response.statusCode == 200) {
                    Get.snackbar(
                      'موفق',
                      'رنگ کلید با موفقیت تغییر کرد',
                      backgroundColor: Colors.green,
                    );
                    Navigator.of(context).pop();
                  } else {
                    Get.snackbar(
                      'خطا',
                      'خطا در تغییر رنگ: ${response.statusMessage}',
                      backgroundColor: Colors.red,
                    );
                  }
                } catch (e) {
                  Get.snackbar(
                    'خطا',
                    'خطا در ارتباط با سرور: $e',
                    backgroundColor: Colors.red,
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue, // دکمه ثبت آبی
                foregroundColor: Colors.white, // متن سفید
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
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
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  title: const Center(
                    child: Text(
                      'تغییر رنگ کلید',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
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
