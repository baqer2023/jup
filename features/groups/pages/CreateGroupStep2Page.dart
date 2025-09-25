import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_app32/features/groups/controllers/group_controller.dart';
import 'package:my_app32/features/main/models/home/device_item_model.dart';
import 'package:dio/dio.dart';
import 'dart:convert';
import 'CreateGroupStep3Page.dart';

class CreateGroupStep2Page extends StatelessWidget {
  final String groupName;
  final String groupDescription;
  final String groupId;

  const CreateGroupStep2Page({
    super.key,
    required this.groupName,
    required this.groupDescription,
    required this.groupId,
  });

  String getDeviceStepType(DeviceItem device) {
    switch (device.deviceTypeName) {
      case 'key-1':
        return 'تک پله';
      case 'key-2':
        return 'دو پله';
      default:
        return 'نامشخص';
    }
  }

  // گرفتن لیست دستگاه‌ها از سرور
  Future<List<Map<String, dynamic>>> fetchDevicesFromServer(String token) async {
    final headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
    final data = json.encode({"page": 0, "pageSize": 100});
    final dio = Dio();

    final response = await dio.request(
      'http://45.149.76.245:8080/api/device/getAllDevices',
      options: Options(method: 'POST', headers: headers),
      data: data,
    );

    if (response.statusCode == 200) {
      final devicesData = response.data['data'] as List;
      return devicesData.map((d) => {
        "customerId": groupId,  // **رشته خالص**
        "deviceId": d['deviceId'],
        "dashboardId": d['dashboardId'],
      }).toList();
    } else {
      Get.snackbar('خطا', 'دریافت دستگاه‌ها ناموفق بود');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final HomeControllerGroup controller = Get.put(HomeControllerGroup(Get.find()));
    final selectedDevices = <DeviceItem>[].obs;

    if (controller.userLocationsGroup.isEmpty) {
      controller.fetchUserLocationsGroup();
    }

    return Scaffold(
      appBar: AppBar(title: const Text("ایجاد گروه - مرحله ۲")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text("دستگاه‌هایی که می‌خواهید اضافه کنید را انتخاب کنید:"),
            const SizedBox(height: 16),

            // لیست گروه‌ها
            Obx(() {
              final groups = controller.userLocationsGroup;
              final selectedId = controller.selectedLocationIdGroup.value;

              return SizedBox(
                height: 45,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: groups.length + 1,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final id = index == 0 ? 'all' : groups[index - 1].id ?? 'unknown';
                    final title = index == 0 ? 'همه' : groups[index - 1].title;
                    final isSelected = selectedId == id;

                    return GestureDetector(
                      onTap: () {
                        controller.selectedLocationIdGroup.value = id;
                        if (id == 'all') {
                          controller.fetchAllDevicesGroup();
                        } else {
                          controller.fetchDevicesByLocationGroup(id);
                        }
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(
                            color: isSelected ? Colors.yellow : Colors.grey.shade300,
                            width: isSelected ? 2 : 1,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            title,
                            style: TextStyle(
                              color: isSelected ? Colors.yellow.shade700 : Colors.grey,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            }),

            const SizedBox(height: 16),

            // لیست دستگاه‌ها
            Expanded(
              child: Obx(() {
                final devices = controller.deviceListGroup;
                if (devices.isEmpty) return const Center(child: Text("دستگاهی موجود نیست"));

                return ListView.builder(
                  itemCount: devices.length,
                  itemBuilder: (context, index) {
                    final device = devices[index];

                    return Obx(() {
                      final isSelected = selectedDevices.contains(device);

                      return ListTile(
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(device.title),
                            Text(
                              getDeviceStepType(device),
                              style: const TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                          ],
                        ),
                        trailing: Switch(
                          value: isSelected,
                          onChanged: (val) {
                            if (val) {
                              selectedDevices.add(device);
                            } else {
                              selectedDevices.remove(device);
                            }
                          },
                        ),
                        onTap: () {
                          if (isSelected) {
                            selectedDevices.remove(device);
                          } else {
                            selectedDevices.add(device);
                          }
                        },
                      );
                    });
                  },
                );
              }),
            ),

            // دکمه‌ها
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(onPressed: () => Get.back(), child: const Text("قبلی")),
                TextButton(onPressed: () => Get.back(), child: const Text("انصراف")),
                ElevatedButton(
                  onPressed: () async {
                    final selectedId = controller.selectedLocationIdGroup.value;

                    if (selectedDevices.isEmpty) {
                      Get.to(() => CreateGroupStep3Page(
                            groupName: groupName,
                            groupDescription: groupDescription,
                            groupId: groupId,
                          ));
                      return;
                    }

                    List<DeviceItem> devicesToAssign = selectedDevices.toList();

                    List<Map<String, dynamic>> payload = [];

                    if (selectedId == 'all') {
                      final serverDevices = await fetchDevicesFromServer(controller.tokenGroup);

                      payload = serverDevices
                          .where((d) => devicesToAssign.any((sd) => sd.deviceId == d['deviceId']))
                          .toList();
                    } else {
                      payload = devicesToAssign.map((device) {
                        return {
                          "customerId": groupId,  // رشته خالص
                          "deviceId": device.deviceId,
                          "dashboardId": selectedId,
                        };
                      }).toList();
                    }

                    if (payload.isEmpty) {
                      Get.snackbar('خطا', 'هیچ دستگاهی برای ارسال موجود نیست');
                      return;
                    }

                    final success = await controller.assignDevicesPayload(payload);

                    if (success) {
                      Get.to(() => CreateGroupStep3Page(
                            groupName: groupName,
                            groupDescription: groupDescription,
                            groupId: groupId,
                          ));
                    }
                  },
                  child: const Text("ثبت / بعدی"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}


String extractCustomerId(String rawId) {
  final regex = RegExp(r'id:\s*([a-f0-9-]+)');
  final match = regex.firstMatch(rawId);
  if (match != null) return match.group(1)!;
  return rawId; // fallback
}
