import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:my_app32/app/store/user_store_service.dart';
import 'package:my_app32/features/main/pages/home/home_page.dart';
import 'package:my_app32/features/main/pages/home/home_controller.dart';
import 'package:my_app32/features/widgets/custom_appbar.dart';
import 'package:my_app32/features/widgets/sidebar.dart';
import 'package:my_app32/core/lang/lang.dart';

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
          Lang.t('error'), // 🔹 چندزبانه
          Lang.t('select_all_fields'), // 🔹 چندزبانه
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      final token = await UserStoreService.to.getToken();
      if (token == null) {
        Get.snackbar(
          Lang.t('error'), // 🔹 چندزبانه
          Lang.t('token_not_found'), // 🔹 چندزبانه
        );
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
            Lang.t('success'), // 🔹 چندزبانه
            Lang.t('device_registered_success'), // 🔹 چندزبانه
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );

          await homeController.refreshAllData();
          Get.offAll(() =>  HomePage());
        } else {
          Get.snackbar(
            Lang.t('error'), // 🔹 چندزبانه
            '${Lang.t('device_registration_failed')}: ${response.statusCode}', // 🔹 چندزبانه
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      } catch (e) {
        Get.snackbar(
          Lang.t('error'), // 🔹 چندزبانه
          '${Lang.t('server_error')}: $e', // 🔹 چندزبانه
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
    padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
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
                  child: Text(Lang.t('serial_number')), // 🔹 چندزبانه
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
  inputFormatters: [
    LengthLimitingTextInputFormatter(8),
  ],
  decoration: InputDecoration(
    counterText: '',
    label: Align(
      alignment: Alignment.centerRight,
      child: Text(Lang.t('device_name')), // 🔹 چندزبانه
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

SizedBox(
  height: 60,
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
              children: [
                Icon(Icons.add, size: 18, color: Colors.black87),
                SizedBox(width: 6),
                Text(
                  Lang.t('add'), // 🔹 چندزبانه
                  style: TextStyle(color: Colors.black87, fontSize: 14),
                ),
              ],
            ),
          ),
        ),
        // لیست مکان‌ها
...locations
    .where((loc) => loc.title != "میانبر")
    .map((loc) {
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
              child: Row(
  mainAxisSize: MainAxisSize.min,
  children: [
    Text(
      loc.title,
      style: TextStyle(
        color: isSelected ? Colors.yellow.shade700 : Colors.grey,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        fontSize: 14,
      ),
    ),
    if (loc.iconIndex != null) ...[
      const SizedBox(width: 4),
      SvgPicture.asset(
        'assets/svg/${loc.iconIndex}.svg',
        width: 28,
        height: 28,
        fit: BoxFit.contain,
      ),
    ],
  ],
),
            ),
          );
        }).toList(),
      ],
    );
  }),
),
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
                  child: Text(
                    Lang.t('cancel'), // 🔹 چندزبانه
                    style: const TextStyle(
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
                  child: Text(
                    Lang.t('register_device'), // 🔹 چندزبانه
                    style: const TextStyle(
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
  int? selectedIconIndex;

  showDialog(
    context: Get.context!,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
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
                    borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                  child: Text(
                    Lang.t('add_location'), // 🔹 چندزبانه
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 18),
                    textAlign: TextAlign.center,
                  ),
                ),
                contentPadding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      textAlign: TextAlign.right,
                      decoration: InputDecoration(
                        label: Align(
                            alignment: Alignment.centerRight,
                            child: Text(Lang.t('location_name'))), // 🔹 چندزبانه
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: Colors.blue, width: 2),
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
                    const SizedBox(height: 16),

SizedBox(
  height: 70,
  child: SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    child: Row(
      children: List.generate(18, (index) {
        final iconNumber = index + 1;
        final isSelected = selectedIconIndex == iconNumber;

        return GestureDetector(
          onTap: () {
            setState(() {
              selectedIconIndex = iconNumber;
            });
          },
          child: Container(
            width: 50,
            height: 50,
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected
                    ? Colors.yellow.shade700
                    : Colors.grey.shade300,
                width: isSelected ? 2.5 : 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 3,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            padding: const EdgeInsets.all(6),
            child: SvgPicture.asset(
              'assets/svg/$iconNumber.svg',
              fit: BoxFit.contain,
            ),
          ),
        );
      }),
    ),
  ),
),

                  ],
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
                            child: Text(
                              Lang.t('cancel'), // 🔹 چندزبانه
                              style: const TextStyle(
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
                                  Lang.t('error'), // 🔹 چندزبانه
                                  Lang.t('enter_location_name'), // 🔹 چندزبانه
                                  backgroundColor: Colors.red,
                                  colorText: Colors.white,
                                );
                                return;
                              }

                              await homeController.addLocation(
                                name,
                                iconIndex: selectedIconIndex,
                              );
                              Navigator.of(context).pop();
                              Get.snackbar(
                                Lang.t('success'), // 🔹 چندزبانه
                                Lang.t('location_added'), // 🔹 چندزبانه
                                backgroundColor: Colors.green,
                                colorText: Colors.white,
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              padding:
                                  const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              Lang.t('submit'), // 🔹 چندزبانه
                              style: const TextStyle(
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
    },
  );
}

}