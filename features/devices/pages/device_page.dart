import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:my_app32/app/core/base/base_view.dart';
import 'package:my_app32/app/services/realable_controller.dart';
import 'package:my_app32/features/config/device_config_page.dart';
import 'package:my_app32/features/devices/pages/edit_device_page.dart';
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
  WidgetsBinding.instance.addPostFrameCallback((_) {
    controller.selectedLocationId.value = '';
    controller.deviceList.clear();
  });

  return Scaffold(
    endDrawer: const Sidebar(),
    appBar: CustomAppBar(isRefreshing: controller.isRefreshing),
    // ✅ Builder اضافه شد تا context معتبر در اختیار داشته باشیم
    body: Builder(
      builder: (context) => _buildDevicesContent(context),
    ),
  );
}


  Widget _buildDevicesContent(BuildContext context) {
    return Obx(() {
      final locations = controller.userLocations;
      final visibleLocations =
          locations.where((loc) => loc.title != "میانبر").toList();
      final devices = controller.deviceList;

      return RefreshIndicator(
        onRefresh: controller.refreshAllData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),

              // دکمه‌ها و عنوان بالا
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

              // لیست مکان‌ها + دکمه ویرایش
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  height: 45,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        // دکمه ویرایش
// دکمه ویرایش
// دکمه ویرایش
GestureDetector(
  onTap: () {
    _showEditLocationsModal(context, controller.userLocations);
  },
  child: Container(
    margin: const EdgeInsets.only(right: 8),
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border.all(color: Colors.grey.shade300, width: 1),
      borderRadius: BorderRadius.circular(30), // کامل دایره
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: Row(
      children: [
        SvgPicture.asset(
          'assets/svg/pencil-solid.svg',
          width: 18,
          height: 18,
          color: Colors.grey.shade600,
        ),
        const SizedBox(width: 6),
        const Text(
          'ویرایش',
          style: TextStyle(
            color: Colors.grey,
            fontSize: 14,
          ),
        ),
      ],
    ),
  ),
),


                        // لیست مکان‌ها
                        ...locations
                            .where((loc) => loc.title != "میانبر")
                            .map((loc) {
                          return Obx(() {
                            final isSelected =
                                controller.selectedLocationId.value.isNotEmpty &&
                                    controller.selectedLocationId.value ==
                                        loc.id;

                            return GestureDetector(
                              onTap: () {
                                controller.selectedLocationId.value = loc.id;
                                controller.fetchDevicesByLocation(loc.id);
                              },
                              child: Container(
  margin: const EdgeInsets.only(right: 8),
  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  decoration: BoxDecoration(
    color: Colors.white,
    border: Border.all(
      color: isSelected ? Colors.yellow : Colors.grey.shade300,
      width: isSelected ? 2 : 1,
    ),
    borderRadius: BorderRadius.circular(30), // کامل دایره
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
        color: isSelected ? Colors.yellow.shade700 : Colors.grey,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        fontSize: 14,
      ),
    ),
  ),
),
                            );
                          });
                        }).toList(),
                      ],
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

  /// مدال ویرایش مکان‌ها
/// مدال ویرایش مکان‌ها با دکمه‌های ثبت و انصراف و استایل جدید
void _showEditLocationsModal(BuildContext context, List locations) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return Container(
        color: Colors.white, // پس‌زمینه کل مدال
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // هدر آبی با متن سفید
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'ویرایش مکان‌ها',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 12),

// لیست مکان‌ها
Flexible(
  child: ListView.builder(
    shrinkWrap: true,
    itemCount: locations.where((loc) => loc.title != "میانبر").length,
    itemBuilder: (context, index) {
      // فقط مکان‌هایی که title != "میانبر" رو انتخاب می‌کنیم
      final filteredLocations = locations.where((loc) => loc.title != "میانبر").toList();
      final loc = filteredLocations[index];

      return Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          title: Align(
            alignment: Alignment.centerRight,
            child: Text(
              loc.title,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black,
              ),
              textAlign: TextAlign.right,
            ),
          ),
          leading: PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.black87),
            onSelected: (value) {
              if (value == 'edit') {
                Navigator.pop(context);
                _showSingleLocationEditDialog(context, loc);
              } else if (value == 'up') {
                Navigator.pop(context);
              } else if (value == 'down') {
                Navigator.pop(context);
              } else if (value == 'delete') {
                Navigator.pop(context);
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'edit',
                child: Row(
                  textDirection: TextDirection.rtl,
                  children: [
                    SvgPicture.asset('assets/svg/edit.svg', width: 20, height: 20, color: Colors.black87),
                    const SizedBox(width: 8),
                    const Text('ویرایش مکان', style: TextStyle(color: Colors.black)),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'up',
                child: Row(
                  textDirection: TextDirection.rtl,
                  children: [
                    SvgPicture.asset('assets/svg/arrow_up.svg', width: 20, height: 20, color: Colors.black87),
                    const SizedBox(width: 8),
                    const Text('بالا بردن', style: TextStyle(color: Colors.black)),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'down',
                child: Row(
                  textDirection: TextDirection.rtl,
                  children: [
                    SvgPicture.asset('assets/svg/arrow_down.svg', width: 20, height: 20, color: Colors.black87),
                    const SizedBox(width: 8),
                    const Text('پایین آوردن', style: TextStyle(color: Colors.black)),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  textDirection: TextDirection.rtl,
                  children: [
                    SvgPicture.asset('assets/svg/deleting.svg', width: 20, height: 20, color: Colors.red),
                    const SizedBox(width: 8),
                    const Text('حذف مکان', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
            color: Colors.white,
          ),
        ),
      );
    },
  ),
),


              const SizedBox(height: 16),

              // دکمه‌های ثبت و انصراف
Row(
  mainAxisAlignment: MainAxisAlignment.start,
  children: [
    // دکمه انصراف
    SizedBox(
      width: 80, // عرض ثابت
      child: ElevatedButton(
        onPressed: () => Navigator.of(context).pop(),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Color(0xFFF39530),
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(
              color: Color(0xFFF39530),
              width: 2,
            ),
          ),
        ),
        child: const Text(
          'انصراف',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
    ),

    const SizedBox(width: 8),

    // دکمه ثبت
    SizedBox(
      width: 80, // عرض ثابت همانند دکمه انصراف
      child: ElevatedButton(
        onPressed: () {
          Navigator.of(context).pop();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          'ثبت',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
    ),
  ],
)

,
              const SizedBox(height: 12),
            ],
          ),
        ),
      );
    },
  );
}



void _showSingleLocationEditDialog(BuildContext context, dynamic loc) {
  final TextEditingController nameController =
      TextEditingController(text: loc.title);

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 10,
        title: const Text(
          'ویرایش مکان',
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
  textAlign: TextAlign.right, // متن راست‌چین
  decoration: InputDecoration(
    label: Align(
      alignment: Alignment.centerRight, // لیبل راست‌چین
      child: const Text('نام مکان'),
    ),
    hintText: 'نام مکان را وارد کنید',
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    contentPadding: const EdgeInsets.symmetric(
      horizontal: 12,
      vertical: 10,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.blue, width: 2), // حاشیه آبی هنگام فوکوس
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.grey.shade400, width: 1), // حاشیه حالت معمولی
    ),
  ),
),

              const SizedBox(height: 12),
              // Row(
              //   children: [
              //     const Text(
              //       'شناسه مکان (id): ',
              //       style: TextStyle(fontSize: 12, color: Colors.grey),
              //     ),
              //     Expanded(
              //       child: Text(
              //         loc.id?.toString() ?? '-',
              //         style: const TextStyle(fontSize: 13),
              //         overflow: TextOverflow.ellipsis,
              //       ),
              //     ),
              //   ],
              // ),
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
  Row(
    mainAxisSize: MainAxisSize.min, // فقط به اندازه محتوا جا می‌گیرد
    children: [
      SizedBox(
        width: 100, // عرض ثابت دکمه انصراف
        child: ElevatedButton(
          onPressed: () => Navigator.of(context).pop(),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Color(0xFFF39530),
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(
                color: Color(0xFFF39530),
                width: 2,
              ),
            ),
          ),
          child: const Text(
            'انصراف',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
      ),

      const SizedBox(width: 4), // فاصله خیلی کم بین دکمه‌ها

      SizedBox(
        width: 100, // عرض ثابت دکمه ذخیره
        child: ElevatedButton(
          onPressed: () async {
            final newName = nameController.text.trim();
            if (newName.isEmpty) {
              Get.snackbar(
                'خطا',
                'لطفاً نام مکان را وارد کنید',
                backgroundColor: Colors.red,
                colorText: Colors.white,
              );
              return;
            }

            await controller.updateLocation(
              title: newName,
              dashboardId: loc.id,
            );

            Navigator.of(context).pop();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text(
            'ذخیره',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
      ),
    ],
  ),
],


      );
    },
  );
}






  // ------------------- Smart Devices Grid (بهینه) -------------------
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

    final reliableController = Get.isRegistered<ReliableSocketController>(
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

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16), // فاصله از لبه
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
                final key1Entries = [
                  if (deviceData['TW1'] is List) ...deviceData['TW1'],
                  if (deviceData['TD1'] is List) ...deviceData['TD1'],
                ];
                if (key1Entries.isNotEmpty) {
                  key1Entries.sort((a, b) => (b[0] as int).compareTo(a[0] as int));
                  switch1On = key1Entries.first[1].toString().contains('On');
                }

                final key2Entries = [
                  if (deviceData['TW2'] is List) ...deviceData['TW2'],
                  if (deviceData['TD2'] is List) ...deviceData['TD2'],
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
  Color borderColor = anySwitchOn ? Colors.blue.shade400 : Colors.grey.shade400;

  final homeController = Get.find<HomeController>();

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
                // ردیف بالای کارت: کلیدها و اطلاعات دستگاه
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
                    // اطلاعات دستگاه سمت راست
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // وضعیت آنلاین و نوع کلید
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
                            fontSize: 16,
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
                // ردیف پایین کارت: سه نقطه، SVG تنظیمات و آخرین همگام‌سازی
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // PopupMenuButton (سه نقطه)
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
                        } else if (value == 0) {
                          showLedColorDialog(device: device);
                        } else if (value == 2) {
                          // افزودن به داشبورد
                          if (!homeController.dashboardDevices.any(
                              (d) => d.deviceId == device.deviceId)) {
                            final token = homeController.token;
                            if (token == null) {
                              Get.snackbar(
                                  "خطا", "توکن معتبر پیدا نشد",
                                  backgroundColor: Colors.red,
                                  colorText: Colors.white);
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
                              if (response.statusCode == 200 ||
                                  response.statusCode == 201) {
                                Get.snackbar(
                                    'موفقیت',
                                    'دستگاه به داشبورد اضافه شد',
                                    backgroundColor: Colors.green,
                                    colorText: Colors.white);
                                homeController.dashboardDevices.add(device);
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
                          // حذف موقت
                          await homeController.removeFromAllDashboard(device.deviceId);
                          await homeController.refreshAllData();
                          Get.snackbar(
                            'موفقیت',
                            'کلید از همه مکان‌ها حذف موقت شد',
                            backgroundColor: Colors.green,
                            colorText: Colors.white,
                          );
                        } else if (value == 4) {
                          // حذف کامل
                          await homeController.completeRemoveDevice(device.deviceId);
                          await homeController.refreshAllData();
                          Get.snackbar(
                            'موفقیت',
                            'دستگاه با موفقیت حذف شد',
                            backgroundColor: Colors.green,
                            colorText: Colors.white,
                          );
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
                    textDirection: TextDirection.rtl,
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
                    textDirection: TextDirection.rtl,
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
                    textDirection: TextDirection.rtl,
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
                            textDirection: TextDirection.rtl,
                            children: [
                              SvgPicture.asset(
                                'assets/svg/edit.svg',
                                width: 20,
                                height: 20,
                                color: Colors.blueAccent,
                              ),
                              const SizedBox(width: 2),
                              const Text('ویرایش کلید',
                                  style: TextStyle(color: Colors.black)),
                            ],
                          ),
                        ),
                        // PopupMenuItem<int>(
                        //   value: 0,
                        //   child: Row(
                        //     textDirection: TextDirection.rtl,
                        //     children: [
                        //       SvgPicture.asset(
                        //         'assets/svg/settings.svg',
                        //         width: 20,
                        //         height: 20,
                        //       ),
                        //       const SizedBox(width: 2),
                        //       const Text('تنظیمات پیشرفته',
                        //           style: TextStyle(color: Colors.black)),
                        //     ],
                        //   ),
                        // ),
                        if (!homeController.dashboardDevices.any(
                          (d) => d.deviceId == device.deviceId,
                        ))
                          PopupMenuItem<int>(
                            value: 2,
                            child: Row(
                              textDirection: TextDirection.rtl,
                              children: [
                                SvgPicture.asset(
                                    'assets/svg/add_dashboard.svg',
                                    width: 20,
                                    height: 20),
                                const SizedBox(width: 2),
                                const Text('افزودن به داشبورد',
                                    style: TextStyle(color: Colors.black)),
                              ],
                            ),
                          ),
                        PopupMenuItem<int>(
                          value: 5,
                          child: Row(
                            textDirection: TextDirection.rtl,
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
                          value: 3,
                          child: Row(
                            textDirection: TextDirection.rtl,
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
                            textDirection: TextDirection.rtl,
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
                    const SizedBox(width: 6),
                    // SVG تنظیمات/LED
                    GestureDetector(
                      onTap: () {
                        showLedColorDialog(device: device);
                      },
                      child: SvgPicture.asset(
                        'assets/svg/advanced_settings.svg',
                        width: 20,
                        height: 20,
                        color: Colors.black87,
                      ),
                    ),
                    const Spacer(),
                    // آخرین همگام‌سازی
                    Obx(() {
                      final lastSeen =
                          reliableController.lastDeviceActivity[deviceId];
                      String lastActivityText;

                      if (lastSeen != null) {
                        final formattedDate =
                            "${lastSeen.year}/${lastSeen.month.toString().padLeft(2, '0')}/${lastSeen.day.toString().padLeft(2, '0')}";
                        final formattedTime =
                            "${lastSeen.hour.toString().padLeft(2, '0')}:${lastSeen.minute.toString().padLeft(2, '0')}:${lastSeen.second.toString().padLeft(2, '0')}";
                        lastActivityText =
                            "آخرین همگام سازی: $formattedDate - $formattedTime";
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
      titlePadding: EdgeInsets.zero, // حذف padding پیش‌فرض
      title: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: const BoxDecoration(
          color: Colors.blue, // پس‌زمینه آبی برای هدر
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: const Text(
          'افزودن مکان',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white, // متن سفید
            fontSize: 18,
          ),
          textAlign: TextAlign.center,
        ),
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              textAlign: TextAlign.right, // متن راست‌چین
              decoration: InputDecoration(
                label: Align(
                  alignment: Alignment.centerRight, // لیبل راست‌چین
                  child: const Text('نام مکان'),
                ),
                hintText: 'نام مکان را وارد کنید',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.blue, width: 2),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade400, width: 1),
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
        Row(
          mainAxisSize: MainAxisSize.min, // فقط به اندازه محتوا
          children: [
            SizedBox(
              width: 100,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFFF39530),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(
                      color: Color(0xFFF39530),
                      width: 2,
                    ),
                  ),
                ),
                child: const Text(
                  'انصراف',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 4),
            SizedBox(
              width: 100,
              child: ElevatedButton(
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
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'ثبت',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
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
