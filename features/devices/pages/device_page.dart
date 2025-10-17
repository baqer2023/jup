import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:my_app32/app/core/base/base_view.dart';
import 'package:my_app32/app/services/realable_controller.dart';
import 'package:my_app32/features/config/device_config_page.dart';
import 'package:my_app32/features/main/models/home/device_item_model.dart';
import 'package:my_app32/features/main/pages/home/Add_device_page.dart';
import 'package:my_app32/features/main/pages/home/home_controller.dart';
import 'package:my_app32/features/widgets/custom_appbar.dart';
import 'package:my_app32/features/widgets/sidebar.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class DevicesPage extends BaseView<HomeController> {
  const DevicesPage({super.key});

  @override
  Widget body() {
        // ریست مقادیر بعد از اولین رندر
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.selectedLocationId.value = '';
      controller.deviceList.clear();
    });
    return Scaffold(
      endDrawer: const Sidebar(),
      appBar: CustomAppBar(isRefreshing: controller.isRefreshing),
      body: _buildDevicesContent(),
    );
  }

Widget _buildDevicesContent() {
  return Obx(() {
    final locations = controller.userLocations;
    final visibleLocations = locations
        .where((loc) => loc.title != "میانبر")
        .toList();

    final devices = controller.deviceList;


    return RefreshIndicator(
       onRefresh: controller.refreshAllData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
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
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                        ),
                        child: const Text('ثبت دستگاه'),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: _showAddLocationDialog,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.yellow.shade700,
                          side: BorderSide(
                            color: Colors.yellow.shade700,
                            width: 1.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                        ),
                        child: const Text('افزودن مکان'),
                      ),
                    ],
                  ),
                  const Text(
                    'دستگاه‌ها',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Divider(thickness: 2),
            const SizedBox(height: 16),

            // لیست مکان‌ها
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                height: 45, // ارتفاع ثابت برای آیتم‌ها
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: locations
                        .where((loc) => loc.title != "میانبر")
                        .map((loc) {
                      return Obx(() {
                        final isSelected = controller.selectedLocationId.value.isNotEmpty &&
                            controller.selectedLocationId.value == loc.id;

                        return GestureDetector(
                          onTap: () {
                            controller.selectedLocationId.value = loc.id;
                            controller.fetchDevicesByLocation(loc.id);
                          },
                          child: Container(
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(
                                color: isSelected
                                    ? Colors.yellow
                                    : Colors.grey.shade300,
                                width: isSelected ? 2 : 1,
                              ),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                loc.title,
                                style: TextStyle(
                                  color: isSelected
                                      ? Colors.yellow.shade700
                                      : Colors.grey,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        );
                      });
                    }).toList(),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // لیست دستگاه‌ها
            if (devices.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        height: 180,
                        child: SvgPicture.asset(
                          'assets/svg/NDeviceF.svg',
                          fit: BoxFit.fill,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        "تا کنون دستگاهی ثبت نشده‌است،\nجهت ثبت دستگاه جدید روی دکمه ثبت دستگاه کلیک کنید",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                          height: 1.5,
                        ),
                      ),
                    ],
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


  // ------------------- Smart Devices Grid (بهینه) -------------------
  Widget _buildSmartDevicesGrid() {
    return Obx(() {
      final devices = controller.deviceList;
      final ssssss = devices.map((d) => d.deviceId).toList();

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

      // تنها یکبار کنترلر را ایجاد کن اگر موجود نباشد
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

      // بعد از این خط:
      reliableController.updateDeviceList(
        devices.map((d) => d.deviceId).toList(),
      );

      return SingleChildScrollView(
        child: Column(
          children: devices.map((device) {
            return Obx(() {
              final deviceData =
                  reliableController.latestDeviceDataById[device.deviceId];

              bool switch1On = false;
              bool switch2On = false;
              Color iconColor1 = Colors.grey;
              Color iconColor2 = Colors.grey;

              if (deviceData != null) {
                // وضعیت سوئیچ‌ها
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

                // رنگ‌ها
                if (deviceData['ledColor'] is List &&
                    deviceData['ledColor'].isNotEmpty) {
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
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 400),
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
                ),
              );
            });
          }).toList(),
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
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // کلیدها سمت چپ
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
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
                      ),
                      const SizedBox(width: 8),
// عنوان دستگاه + نوع کلید + وضعیت آنلاین/آفلاین
Column(
  crossAxisAlignment: CrossAxisAlignment.end,
  mainAxisSize: MainAxisSize.min,
  children: [
    // ردیف نوع کلید + وضعیت آنلاین/آفلاین
    Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // وضعیت آنلاین / آفلاین به شکل بیضی
        Obx(() {
          final lastSeen = reliableController.lastDeviceActivity[deviceId];
          final isOnline = lastSeen != null &&
              DateTime.now().difference(lastSeen) < const Duration(seconds: 30);

          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
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
         // متن نوع کلید
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
        fontSize: 16,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    ),
    const SizedBox(height: 4),

    // مکان دستگاه با آیکن SVG
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
      'assets/svg/location.svg', // مسیر فایل SVG
      width: 24,
      height: 24,
      // color: Colors.grey.shade600,
    ),
    
  ],
),

  ],
),
                    ],
                  ),
                  Row(
                    children: [
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
    final controller = homeController; // اگر کلا از controller استفاده می‌کنیم

    if (value == 1) {
      // 📝 ویرایش کلید و تغییر مکان
      final TextEditingController nameController =
          TextEditingController(text: device.title ?? '');
      final RxString selectedDashboardId = (device.dashboardId ?? '').obs;

      Get.dialog(
        Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "ویرایش کلید",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'نام جدید کلید',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 🔹 انتخاب مکان
                  Obx(() {
                    final locations = controller.userLocations;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          "انتخاب مکان",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 12,
                          runSpacing: 8,
                          children: locations.map((loc) {
                            final isSelected =
                                selectedDashboardId.value == loc.id;
                            return GestureDetector(
                              onTap: () => selectedDashboardId.value = loc.id,
                              child: Chip(
                                label: Text(
                                  loc.title,
                                  style: TextStyle(
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.black87,
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                                backgroundColor: isSelected
                                    ? Colors.blue.shade400
                                    : Colors.blue.shade50,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 10),
                        OutlinedButton(
                          onPressed: () => _showAddLocationDialog(),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(
                                color: Colors.black, width: 1.5),
                          ),
                          child: const Text('افزودن مکان'),
                        ),
                      ],
                    );
                  }),

                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
ElevatedButton.icon(
  onPressed: () async {
    final newLabel = nameController.text.trim();
    final newDashboardId = selectedDashboardId.value;

    if (newLabel.isEmpty || newDashboardId.isEmpty) {
      Get.snackbar(
        'خطا',
        'لطفاً نام کلید و مکان را انتخاب کنید',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    try {
      await controller.renameDevice(
        deviceId: deviceId ?? '', // deviceId به جای serialNumber
        label: newLabel,
        oldDashboardId: device.dashboardId ?? '', // داشبورد قدیمی
        newDashboardId: newDashboardId, // داشبورد جدید
      );
      Get.back();
      await controller.refreshAllData();
      Get.snackbar(
        'موفقیت',
        'کلید با موفقیت ویرایش شد',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'خطا',
        'مشکل در ویرایش کلید: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  },
  icon: const Icon(Icons.check, size: 18),
  label: const Text('تأیید'),
),

                      OutlinedButton.icon(
                        onPressed: () => Get.back(),
                        icon: const Icon(Icons.close, size: 18),
                        label: const Text('بستن'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    } else if (value == 0) {
      showLedColorDialog(device: device);
    } else if (value == 2) {
      if (!controller.dashboardDevices.any(
        (d) => d.deviceId == device.deviceId,
      )) {
        final token = controller.token;
        if (token == null) {
          Get.snackbar(
            "خطا",
            "توکن معتبر پیدا نشد",
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
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
            'http://45.149.76.245:8080/api/shortcut/addDevice',
            data: data,
            options: Options(headers: headers),
          );

          if (response.statusCode == 200 || response.statusCode == 201) {
            Get.snackbar(
              'موفقیت',
              'دستگاه به داشبورد اضافه شد',
              backgroundColor: Colors.green,
              colorText: Colors.white,
            );
            controller.dashboardDevices.add(device);
          } else {
            Get.snackbar(
              'خطا',
              'افزودن دستگاه موفق نبود: ${response.statusCode}',
              backgroundColor: Colors.red,
              colorText: Colors.white,
            );
          }
        } catch (e) {
          Get.snackbar(
            'خطا',
            'مشکل در ارتباط با سرور: $e',
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      } else {
        Get.snackbar(
          'توجه',
          'این دستگاه قبلاً به داشبورد اضافه شده است',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
      }
    } else if (value == 3) {
      try {
        await homeController.removeFromAllDashboard(device.deviceId);
        await homeController.refreshAllData();
        Get.snackbar(
          'موفقیت',
          'کلید از همه مکان‌ها حذف موقت شد',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } catch (e) {
        Get.snackbar(
          'خطا',
          'عملیات حذف با خطا مواجه شد',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } else if (value == 4) {
      try {
        await homeController.completeRemoveDevice(device.deviceId);
        await homeController.refreshAllData();
        Get.snackbar(
          'موفقیت',
          'دستگاه با موفقیت حذف شد',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } catch (e) {
        Get.snackbar(
          'خطا',
          'عملیات حذف با خطا مواجه شد',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } else if (value == 5) {
      // 🔹 بازنشانی / پیکربندی
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
                ),
                const SizedBox(height: 8),
                const Text(
                  "می‌خواهید چه کاری انجام دهید؟",
                  style: TextStyle(fontSize: 14, color: Colors.black54),
                ),
                const SizedBox(height: 20),
                Card(
                  color: Colors.white,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: const Icon(Icons.settings, color: Colors.blue),
                    title: const Text("رفتن به پیکربندی"),
                    onTap: () {
                      Get.back();
                      Get.to(() => DeviceConfigPage(sn: device.sn));
                    },
                  ),
                ),
                const SizedBox(height: 10),
                Card(
                  color: Colors.white,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: const Icon(Icons.refresh, color: Colors.redAccent),
                    title: const Text(
                      "ریست دستگاه",
                      style: TextStyle(color: Colors.redAccent),
                    ),
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
                  ),
                ),
                const SizedBox(height: 10),
                Card(
                  color: Colors.white,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: const Icon(Icons.cancel, color: Colors.amber),
                    title: const Text(
                      "انصراف",
                      style: TextStyle(color: Colors.amber),
                    ),
                    onTap: () => Get.back(),
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
        textDirection: TextDirection.rtl,
        children: [
          SvgPicture.asset('assets/svg/edit.svg',
              width: 20, height: 20, color: Colors.blueAccent),
          const SizedBox(width: 2),
          const Text('ویرایش کلید', style: TextStyle(color: Colors.black)),
        ],
      ),
    ),
    PopupMenuItem<int>(
      value: 0,
      child: Row(
        textDirection: TextDirection.rtl,
        children: [
          SvgPicture.asset('assets/svg/settings.svg', width: 20, height: 20),
          const SizedBox(width: 2),
          const Text('تنظیمات پیشرفته', style: TextStyle(color: Colors.black)),
        ],
      ),
    ),
    if (!controller.dashboardDevices.any(
      (d) => d.deviceId == device.deviceId,
    ))
      PopupMenuItem<int>(
        value: 2,
        child: Row(
          textDirection: TextDirection.rtl,
          children: [
            SvgPicture.asset('assets/svg/add_dashboard.svg', width: 20, height: 20),
            const SizedBox(width: 2),
            const Text('افزودن به داشبورد', style: TextStyle(color: Colors.black)),
          ],
        ),
      ),
    PopupMenuItem<int>(
      value: 6,
      child: Row(
        textDirection: TextDirection.rtl,
        children: [
          SvgPicture.asset('assets/svg/child_lock.svg',
              width: 20, height: 20, color: Colors.blueAccent),
          const SizedBox(width: 2),
          const Text('قفل کودک', style: TextStyle(color: Colors.black)),
        ],
      ),
    ),
    PopupMenuItem<int>(
      value: 5,
      child: Row(
        textDirection: TextDirection.rtl,
        children: [
          SvgPicture.asset('assets/svg/reset.svg', width: 20, height: 20),
          const SizedBox(width: 2),
          const Text('بازنشانی / پیکربندی', style: TextStyle(color: Colors.black)),
        ],
      ),
    ),
    const PopupMenuDivider(),
    PopupMenuItem<int>(
      value: 3,
      child: Row(
        textDirection: TextDirection.rtl,
        children: [
          SvgPicture.asset('assets/svg/delete_temp.svg',
              width: 20, height: 20, color: Colors.red),
          const SizedBox(width: 2),
          const Text('حذف موقت', style: TextStyle(color: Colors.red)),
        ],
      ),
    ),
    PopupMenuItem<int>(
      value: 4,
      child: Row(
        textDirection: TextDirection.rtl,
        children: [
          SvgPicture.asset('assets/svg/deleting.svg',
              width: 20, height: 20, color: Colors.red),
          const SizedBox(width: 2),
          const Text('حذف کامل', style: TextStyle(color: Colors.red)),
        ],
      ),
    ),
  ],
),




                      ),
                      const Spacer(),
                      Obx(() {
                        final reliableController =
                            Get.find<ReliableSocketController>(
                              tag: 'smartDevicesController',
                            );

                        final lastSeen = reliableController.lastDeviceActivity[deviceId];
  String lastActivityText;

  if (lastSeen != null) {
    final formattedDate =
        "${lastSeen.year}/${lastSeen.month.toString().padLeft(2, '0')}/${lastSeen.day.toString().padLeft(2, '0')}";
    final formattedTime =
        "${lastSeen.hour.toString().padLeft(2, '0')}:${lastSeen.minute.toString().padLeft(2, '0')}:${lastSeen.second.toString().padLeft(2, '0')}";
    lastActivityText = "آخرین همگام سازی: $formattedDate - $formattedTime";
  } else {
    lastActivityText = "آخرین همگام سازی: نامشخص";
  }

  return Text(
    lastActivityText,
    style: TextStyle(
      color: Colors.grey[600],
      fontSize: 10,
    ),
    textAlign: TextAlign.right,
  );
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
                backgroundColor: Colors.white, // پس‌زمینه سفید
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(
                    color: Color(0xFFF39530), // زرد اختصاصی شما
                    width: 2,
                  ),
                ),
              ),
              child: const Text(
                'انصراف',
                style: TextStyle(
                  color: Color(0xFFF39530), // رنگ متن زرد اختصاصی
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
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
  // 🔸 دکمه انصراف
  SizedBox(
    height: 48,
    child: TextButton(
      onPressed: () => Navigator.of(context).pop(),
      style: TextButton.styleFrom(
        backgroundColor: Colors.white, // پس‌زمینه سفید
        foregroundColor: const Color(0xFFF39530), // متن زرد برند
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(
            color: Color(0xFFF39530), // حاشیه زرد برند
            width: 2,
          ),
        ),
        minimumSize: const Size(120, 48),
      ),
      child: const Text(
        "انصراف",
        style: TextStyle(
          fontFamily: 'IranYekan',
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    ),
  ),

  const SizedBox(width: 12),

  // 🔹 دکمه ثبت
  SizedBox(
    height: 48,
    child: ElevatedButton(
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
              colorText: Colors.white,
              snackPosition: SnackPosition.TOP,
            );
            Navigator.of(context).pop();
          } else {
            Get.snackbar(
              'خطا',
              'خطا در تغییر رنگ: ${response.statusMessage}',
              backgroundColor: Colors.red,
              colorText: Colors.white,
              snackPosition: SnackPosition.TOP,
            );
          }
        } catch (e) {
          Get.snackbar(
            'خطا',
            'خطا در ارتباط با سرور: $e',
            backgroundColor: Colors.red,
            colorText: Colors.white,
            snackPosition: SnackPosition.TOP,
          );
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue, // رنگ آبی برند
        foregroundColor: Colors.white, // رنگ متن سفید
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        minimumSize: const Size(120, 48),
        elevation: 2,
      ),
      child: const Text(
        'ثبت',
        style: TextStyle(
          fontFamily: 'IranYekan',
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
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
                      onPressed: () => Navigator.of(context).pop(),
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.white, // پس‌زمینه سفید
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: const BorderSide(
                            color: Color(0xFFF39530), // رنگ حاشیه زرد برند
                            width: 2,
                          ),
                        ),
                      ),
                      child: const Text(
                        'انصراف',
                        style: TextStyle(
                          color: Color(0xFFF39530), // رنگ متن زرد برند
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
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
