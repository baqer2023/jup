import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:my_app32/features/widgets/custom_appbar.dart';
import 'package:my_app32/features/widgets/sidebar.dart';
import 'package:my_app32/features/main/pages/home/home_controller.dart';

class AddDevicePage extends StatelessWidget {
  const AddDevicePage({super.key});

  static const String apiUrl = "https://your-api-endpoint.com/addDevice";

  @override
  Widget build(BuildContext context) {
    final TextEditingController serialController = TextEditingController();
    final TextEditingController deviceNameController = TextEditingController();
    final RxString selectedDashboardId = ''.obs;

    final homeController = Get.find<HomeController>();

    Future<void> submitDevice() async {
      final serial = serialController.text.trim();
      final name = deviceNameController.text.trim();
      final dashboardId = selectedDashboardId.value;

      if (serial.isEmpty || name.isEmpty || dashboardId.isEmpty) {
        Get.snackbar(
          'خطا',
          'لطفاً همه فیلدها و مکان را انتخاب کنید',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      final payload = {
        "serialNumber": serial,
        "label": name,
        "dashboardId": dashboardId,
      };

      try {
        final response = await http.post(
          Uri.parse(apiUrl),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(payload),
        );

        if (response.statusCode == 200 || response.statusCode == 201) {
          Get.snackbar(
            'موفقیت',
            'دستگاه با موفقیت ثبت شد',
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
          Get.back(); // برگشت به صفحه قبل
        } else {
          Get.snackbar(
            'خطا',
            'ثبت دستگاه موفقیت‌آمیز نبود: ${response.statusCode}',
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
              decoration: const InputDecoration(
                labelText: 'شماره سریال',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: deviceNameController,
              decoration: const InputDecoration(
                labelText: 'نام دستگاه',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // 🔹 لیست مکان‌ها
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
            final isSelected = selectedDashboardId.value == loc.id;
            return GestureDetector(
              onTap: () => selectedDashboardId.value = loc.id,
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
          }).toList(),
        ),
      ),
      const SizedBox(width: 8),
      // 🔹 دکمه افزودن مکان
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

            // 🔹 دکمه‌ها به صورت ستون
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                OutlinedButton(
                  onPressed: () {
                    Get.back();
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.yellow, width: 1.5),
                    backgroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    'انصراف',
                    style: TextStyle(color: Colors.yellow),
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: submitDevice,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    'ثبت',
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
        backgroundColor: Colors.white, // رنگ پس‌زمینه مدال
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          'افزودن مکان',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'نام مکان',
                  border: OutlineInputBorder(),
                  hintText: 'نام مکان را وارد کنید',
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(
              backgroundColor: Colors.white, // پس‌زمینه دکمه انصراف
            ),
            child: const Text(
              'انصراف',
              style: TextStyle(color: Colors.yellow), // متن زرد
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
              await homeController.addLocation(name);
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue, // پس‌زمینه آبی
            ),
            child: const Text(
              'ثبت',
              style: TextStyle(color: Colors.white), // متن سفید
            ),
          ),
        ],
      );
    },
  );
}


  
}
