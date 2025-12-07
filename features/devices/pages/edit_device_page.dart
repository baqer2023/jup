import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:my_app32/features/main/pages/home/home_controller.dart';
import 'package:my_app32/features/main/pages/home/home_page.dart';
import 'package:my_app32/features/widgets/custom_appbar.dart';
import 'package:my_app32/features/widgets/sidebar.dart';
import 'package:my_app32/core/lang/lang.dart';

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
    final RxString selectedDashboardId = initialDashboardId.obs;

    final homeController = Get.find<HomeController>();

    Future<void> updateDevice() async {
      final name = nameController.text.trim();
      final dashboardId = selectedDashboardId.value;

      if (name.isEmpty || dashboardId.isEmpty) {
        Get.snackbar(
          Lang.t('error'), // 🔹 چندزبانه
          Lang.t('fill_all_fields'), // 🔹 چندزبانه
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      
      await homeController.renameDevice(
        deviceId: deviceId,
        label: name,
        oldDashboardId: initialDashboardId,
        newDashboardId: dashboardId,
      );

      await homeController.refreshAllData();
      Get.offAll(() =>  HomePage());
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
              enabled: false,
              textAlign: TextAlign.right,
              decoration: InputDecoration(
                label: Align(
                  alignment: Alignment.centerRight,
                  child: Text(Lang.t('serial_number')), // 🔹 چندزبانه
                ),
                border: const OutlineInputBorder(),
                filled: true,
                fillColor: Colors.grey.shade200,
              ),
            ),
            const SizedBox(height: 16),

TextField(
  controller: nameController,
  textAlign: TextAlign.right,
  maxLength: 8,
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
      borderSide:
          BorderSide(color: Colors.grey.shade400, width: 1),
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
...locations
    .where((loc) => loc.title != "میانبر")
    .map((loc) {
      final isSelected = selectedDashboardId.value == loc.id;
          return GestureDetector(
            onTap: () => selectedDashboardId.value = loc.id,
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(
                  color: isSelected
                      ? Colors.yellow.shade700
                      : Colors.grey.shade300,
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
                  onPressed: updateDevice,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    minimumSize: const Size.fromHeight(50),
                  ),
                  child: Text(
                    Lang.t('edit_device'), // 🔹 چندزبانه
                    style: const TextStyle(color: Colors.white, fontSize: 16),
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
}

  // void _showAddLocationDialog(HomeController homeController) {
  //   final TextEditingController nameController = TextEditingController();

  //   showDialog(
  //     context: Get.context!,
  //     builder: (context) {
  //       return Dialog(
  //         backgroundColor: Colors.transparent,
  //         child: SizedBox(
  //           width: 360,
  //           child: AlertDialog(
  //             backgroundColor: Colors.white,
  //             shape: RoundedRectangleBorder(
  //               borderRadius: BorderRadius.circular(16),
  //             ),
  //             titlePadding: EdgeInsets.zero,
  //             title: Container(
  //               width: double.infinity,
  //               padding: const EdgeInsets.symmetric(vertical: 16),
  //               decoration: const BoxDecoration(
  //                 color: Colors.blue,
  //                 borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
  //               ),
  //               child: const Text(
  //                 'افزودن مکان',
  //                 style: TextStyle(
  //                   fontWeight: FontWeight.bold,
  //                   color: Colors.white,
  //                   fontSize: 18,
  //                 ),
  //                 textAlign: TextAlign.center,
  //               ),
  //             ),
  //             contentPadding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
  //             content: TextField(
  //               controller: nameController,
  //               textAlign: TextAlign.right,
  //               decoration: InputDecoration(
  //                 label: Align(
  //                   alignment: Alignment.centerRight,
  //                   child: const Text('نام مکان'),
  //                 ),
  //                 border: OutlineInputBorder(
  //                   borderRadius: BorderRadius.circular(12),
  //                 ),
  //                 focusedBorder: OutlineInputBorder(
  //                   borderRadius: BorderRadius.circular(12),
  //                   borderSide: const BorderSide(color: Colors.blue, width: 2),
  //                 ),
  //                 enabledBorder: OutlineInputBorder(
  //                   borderRadius: BorderRadius.circular(12),
  //                   borderSide:
  //                       BorderSide(color: Colors.grey.shade400, width: 1),
  //                 ),
  //                 contentPadding: const EdgeInsets.symmetric(
  //                   horizontal: 12,
  //                   vertical: 10,
  //                 ),
  //               ),
  //             ),
  //             actionsPadding: const EdgeInsets.symmetric(
  //               horizontal: 16,
  //               vertical: 8,
  //             ),
  //             actions: [
  //               Align(
  //                 alignment: Alignment.centerLeft,
  //                 child: Row(
  //                   mainAxisSize: MainAxisSize.min,
  //                   children: [
  //                     SizedBox(
  //                       width: 100,
  //                       child: ElevatedButton(
  //                         onPressed: () => Navigator.of(context).pop(),
  //                         style: ElevatedButton.styleFrom(
  //                           backgroundColor: Colors.white,
  //                           foregroundColor: const Color(0xFFF39530),
  //                           padding: const EdgeInsets.symmetric(vertical: 12),
  //                           shape: RoundedRectangleBorder(
  //                             borderRadius: BorderRadius.circular(12),
  //                             side: const BorderSide(
  //                               color: Color(0xFFF39530),
  //                               width: 2,
  //                             ),
  //                           ),
  //                         ),
  //                         child: const Text(
  //                           'انصراف',
  //                           style: TextStyle(
  //                             fontWeight: FontWeight.bold,
  //                             fontSize: 14,
  //                           ),
  //                         ),
  //                       ),
  //                     ),
  //                     const SizedBox(width: 4),
  //                     SizedBox(
  //                       width: 100,
  //                       child: ElevatedButton(
  //                         onPressed: () async {
  //                           final name = nameController.text.trim();
  //                           if (name.isEmpty) {
  //                             Get.snackbar(
  //                               'خطا',
  //                               'لطفاً نام مکان را وارد کنید',
  //                               backgroundColor: Colors.red,
  //                               colorText: Colors.white,
  //                             );
  //                             return;
  //                           }
  //                           await homeController.addLocation(name);
  //                           Navigator.of(context).pop();
  //                           Get.snackbar(
  //                             'موفق',
  //                             'مکان اضافه شد',
  //                             backgroundColor: Colors.green,
  //                             colorText: Colors.white,
  //                           );
  //                         },
  //                         style: ElevatedButton.styleFrom(
  //                           backgroundColor: Colors.blue,
  //                           foregroundColor: Colors.white,
  //                           padding: const EdgeInsets.symmetric(vertical: 12),
  //                           shape: RoundedRectangleBorder(
  //                             borderRadius: BorderRadius.circular(12),
  //                           ),
  //                         ),
  //                         child: const Text(
  //                           'ثبت',
  //                           style: TextStyle(
  //                             fontWeight: FontWeight.bold,
  //                             fontSize: 14,
  //                           ),
  //                         ),
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ),
  //       );
  //     },
  //   );
  // }

