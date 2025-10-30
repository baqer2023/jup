import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:my_app32/app/store/user_store_service.dart';
import 'package:my_app32/features/main/pages/home/home_page.dart';
import 'package:my_app32/features/main/pages/home/home_controller.dart';
import 'package:my_app32/features/widgets/custom_appbar.dart';
import 'package:my_app32/features/widgets/sidebar.dart';

class AddDevicePage extends StatelessWidget {
  const AddDevicePage({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController serialController = TextEditingController();
    final TextEditingController deviceNameController = TextEditingController();
    final RxString selectedDashboardId = ''.obs;

    final homeController = Get.find<HomeController>();
    final dio = Dio();

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

      final token = await UserStoreService.to.getToken();
      if (token == null) {
        Get.snackbar('خطا', 'توکن معتبر پیدا نشد');
        return;
      }

      final headers = {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };

      final data = {
        "serialNumber": serial,
        "label": name,
        "dashboardId": dashboardId,
      };

      try {
        final response = await dio.post(
          'http://45.149.76.245:8080/api/addDevice',
          data: data,
          options: Options(headers: headers),
        );

        if (response.statusCode == 200 || response.statusCode == 201) {
          Get.snackbar(
            'موفقیت',
            'دستگاه با موفقیت ثبت شد',
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );

          await homeController.refreshAllData();
          Get.offAll(() =>  HomePage());
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
      body: SafeArea(
  child: Padding(
    padding: const EdgeInsets.fromLTRB(16, 16, 16, 24), // 🔹 پایینش کمی فاصله بیشتر داره
    child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 16),
            TextField(
              controller: serialController,
              textAlign: TextAlign.right,
              decoration: InputDecoration(
                label: Align(
                  alignment: Alignment.centerRight,
                  child: const Text('شماره سریال'),
                ),
                border: const OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue, width: 2),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey.shade400, width: 1),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: deviceNameController,
              textAlign: TextAlign.right,
              decoration: InputDecoration(
                label: Align(
                  alignment: Alignment.centerRight,
                  child: const Text('نام دستگاه'),
                ),
                border: const OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue, width: 2),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey.shade400, width: 1),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // لیست مکان‌ها افقی + دکمه افزودن
// جایگزین بخش Obx و SingleChildScrollView فعلی
SizedBox(
  height: 60, // ارتفاع مناسب برای کارت‌ها
  child: Obx(() {
    final locations = homeController.userLocations;
    return ListView(
      scrollDirection: Axis.horizontal,
      children: [
        // دکمه افزودن مکان
        GestureDetector(
          onTap: () => _showAddLocationDialog(homeController),
          child: Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey.shade300, width: 1),
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: const [
                Icon(Icons.add, size: 18, color: Colors.black87),
                SizedBox(width: 6),
                Text(
                  'افزودن',
                  style: TextStyle(color: Colors.black87, fontSize: 14),
                ),
              ],
            ),
          ),
        ),
        // لیست مکان‌ها
        ...locations.map((loc) {
          final isSelected = selectedDashboardId.value == loc.id;
          return GestureDetector(
            onTap: () => selectedDashboardId.value = loc.id,
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(
                  color: isSelected ? Colors.yellow.shade700 : Colors.grey.shade300,
                  width: isSelected ? 2 : 1,
                ),
                borderRadius: BorderRadius.circular(30),
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
                    color: isSelected ? Colors.yellow.shade700 : Colors.grey.shade700,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ],
    );
  }),
)
,
            const Spacer(),
            // دکمه‌ها
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                OutlinedButton(
                  onPressed: () => Get.back(),
                  style: OutlinedButton.styleFrom(
                    side:
                        const BorderSide(color: Color(0xFFF39530), width: 1.5),
                    backgroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    minimumSize: const Size.fromHeight(50),
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
                  onPressed: submitDevice,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    minimumSize: const Size.fromHeight(50),
                  ),
                  child: const Text(
                    'ثبت دستگاه',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
    );
  }

  void _showAddLocationDialog(HomeController homeController) {
    final TextEditingController nameController = TextEditingController();

    showDialog(
      context: Get.context!,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: SizedBox(
            width: 360,
            child: AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              titlePadding: EdgeInsets.zero,
              title: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: const BoxDecoration(
                  color: Colors.blue,
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: const Text(
                  'افزودن مکان',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 18),
                  textAlign: TextAlign.center,
                ),
              ),
              contentPadding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              content: TextField(
                controller: nameController,
                textAlign: TextAlign.right,
                decoration: InputDecoration(
                  label: Align(
                      alignment: Alignment.centerRight,
                      child: const Text('نام مکان')),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.blue, width: 2),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        BorderSide(color: Colors.grey.shade400, width: 1),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 10),
                ),
              ),
              actionsPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              actions: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
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
                                  color: Color(0xFFF39530), width: 2),
                            ),
                          ),
                          child: const Text(
                            'انصراف',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 14),
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
                            await homeController.addLocation(name);
                            Navigator.of(context).pop();
                            Get.snackbar(
                              'موفق',
                              'مکان اضافه شد',
                              backgroundColor: Colors.green,
                              colorText: Colors.white,
                            );
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
                                fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
