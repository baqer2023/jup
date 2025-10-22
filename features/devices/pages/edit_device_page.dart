import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:my_app32/app/store/user_store_service.dart';
import 'package:my_app32/features/main/pages/home/home_controller.dart';
import 'package:my_app32/features/main/pages/home/home_page.dart';
import 'package:my_app32/features/widgets/custom_appbar.dart';
import 'package:my_app32/features/widgets/sidebar.dart';

class EditDevicePage extends StatelessWidget {
  final String deviceId;
  final String serialNumber;
  final String initialName;
  final String initialDashboardId;

  const EditDevicePage({
    super.key,
    required this.deviceId,
    required this.serialNumber,
    required this.initialName,
    required this.initialDashboardId,
  });

  @override
  Widget build(BuildContext context) {
    final TextEditingController serialController =
        TextEditingController(text: serialNumber);
    final TextEditingController nameController =
        TextEditingController(text: initialName);
    final RxString selectedDashboardId =
        initialDashboardId.obs;

    final homeController = Get.find<HomeController>();
    final dio = Dio();

Future<void> updateDevice() async {
  final name = nameController.text.trim();
  final dashboardId = selectedDashboardId.value;

  if (name.isEmpty || dashboardId.isEmpty) {
    Get.snackbar(
      'خطا',
      'لطفاً همه فیلدها و مکان را پر کنید',
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
    return;
  }

  final homeController = Get.find<HomeController>();

  await homeController.renameDevice(
    deviceId: deviceId,
    label: name,
    oldDashboardId: initialDashboardId,
    newDashboardId: dashboardId,
  );

  // بعد از تغییر موفقیت‌آمیز
  await homeController.refreshAllData();
  Get.offAll(() => const HomePage());
}



    return Scaffold(
      endDrawer: const Sidebar(),
      appBar: CustomAppBar(isRefreshing: false.obs),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 16),
            TextField(
              controller: serialController,
              enabled: false,
              decoration: InputDecoration(
                labelText: 'شماره سریال',
                border: const OutlineInputBorder(),
                filled: true,
                fillColor: Colors.grey.shade200,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'نام دستگاه',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Obx(() {
              final locations = homeController.userLocations;
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Wrap(
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
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton(
                    onPressed: () => _showAddLocationDialog(homeController),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.white,
                      side: const BorderSide(color: Colors.black, width: 1.5),
                    ),
                    child: const Text(
                      'افزودن',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ],
              );
            }),
            const Spacer(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                OutlinedButton(
                  onPressed: () => Get.back(),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFF39530), width: 1.5),
                    backgroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    'انصراف',
                    style: TextStyle(
                      color: Color(0xFFF39530),
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: updateDevice,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    'ویرایش دستگاه',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showAddLocationDialog(HomeController homeController) {
    final TextEditingController nameController = TextEditingController();

    showDialog(
      context: Get.context!,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text('افزودن مکان',
              style: TextStyle(fontWeight: FontWeight.bold)),
          content: TextField(
            controller: nameController,
            decoration: const InputDecoration(
              labelText: 'نام مکان',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('انصراف'),
            ),
            ElevatedButton(
              onPressed: () async {
                final name = nameController.text.trim();
                if (name.isEmpty) {
                  Get.snackbar('خطا', 'نام مکان را وارد کنید',
                      backgroundColor: Colors.red, colorText: Colors.white);
                  return;
                }
                await homeController.addLocation(name);
                Navigator.of(context).pop();
                Get.snackbar('موفق', 'مکان اضافه شد',
                    backgroundColor: Colors.green, colorText: Colors.white);
              },
              child: const Text('ثبت'),
            ),
          ],
        );
      },
    );
  }
}
