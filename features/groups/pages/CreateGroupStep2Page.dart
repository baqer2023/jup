import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:my_app32/features/groups/controllers/group_controller.dart';
import 'package:my_app32/features/main/models/home/device_item_model.dart';
import 'dart:convert';
import 'package:dio/dio.dart';
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
        return 'تک‌پل';
      case 'key-2':
        return 'دوپل';
      default:
        return 'نامشخص';
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

            // فیلتر گروه‌ها
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
                    final isSelected = selectedId == id && selectedId.isNotEmpty;

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

            // کارت‌های دستگاه‌ها
            Expanded(
              child: Obx(() {
                final allDevices = controller.deviceListGroup;
                final selectedLocationId = controller.selectedLocationIdGroup.value;

                final filteredByLocation = selectedLocationId == 'all'
                    ? allDevices
                    : allDevices.where((d) => d.dashboardId == selectedLocationId).toList();

                return SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: filteredByLocation.map((device) {
                        final isSelected = selectedDevices.contains(device);
                        final locationTitle = device.dashboardTitle.isNotEmpty
                            ? device.dashboardTitle
                            : "نامشخص";

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: DeviceCardSimple(
  device: device,
  deviceType: getDeviceStepType(device), // اینجا
  locationTitle: locationTitle,
  onTap: () {
    if (isSelected) {
      selectedDevices.remove(device);
    } else {
      selectedDevices.add(device);
    }
  },
),

                        );
                      }).toList(),
                    ),
                  ),
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
                    if (selectedDevices.isEmpty) {
                      Get.to(() => CreateGroupStep3Page(
                            groupName: groupName,
                            groupDescription: groupDescription,
                            groupId: groupId,
                          ));
                      return;
                    }

                    List<Map<String, dynamic>> payload = selectedDevices.map((device) {
                      return {
                        "customerId": groupId,
                        "deviceId": device.deviceId,
                        "dashboardId": device.dashboardId,
                      };
                    }).toList();

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

// کارت دستگاه ساده با تاگل و SVG
class DeviceCardSimple extends StatefulWidget {
  final DeviceItem device;
  final String deviceType;
  final String locationTitle;
  final VoidCallback onTap;

  const DeviceCardSimple({
    super.key,
    required this.device,
    required this.deviceType,
    required this.locationTitle,
    required this.onTap,
  });

  @override
  State<DeviceCardSimple> createState() => _DeviceCardSimpleState();
}

class _DeviceCardSimpleState extends State<DeviceCardSimple> {
  bool isActive = false;

  @override
  Widget build(BuildContext context) {
    final double cardHeight = 180;       // ارتفاع کارت
    final double circleSize = 42;        // اندازه آیکن بالای کارت
    final double cardWidth = MediaQuery.of(context).size.width * 0.9; // عرض کمی کمتر
    final borderColor = isActive ? Colors.blue.shade400 : Colors.grey.shade400;

    return Center(
      child: GestureDetector(
        onTap: widget.onTap,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // کارت اصلی
            Card(
              color: Colors.white,
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: borderColor, width: 2.5),
              ),
              child: Container(
                width: cardWidth,
                height: cardHeight,
                padding: EdgeInsets.fromLTRB(
                  16,
                  circleSize / 1.5 + 24, // شروع پایین‌تر کل کارت
                  16,
                  16,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start, // متن‌ها و switch بالاتر
                  children: [
                    // Switch سمت چپ
                    Switch(
                      value: isActive,
                      onChanged: (val) => setState(() => isActive = val),
                    ),
                    const SizedBox(width: 12),

                    // ستون اطلاعات سمت راست
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.start, // بالاتر قرار گرفتن متن‌ها
                        children: [
                          Text(
                            widget.device.title,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.deviceType,
                            style: const TextStyle(
                                fontSize: 12, color: Colors.grey),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.locationTitle,
                            style: const TextStyle(
                                fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // آیکن بالای کارت
            Positioned(
              top: -circleSize / 4, // کمی پایین‌تر نسبت به قبل
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  width: circleSize,
                  height: circleSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: borderColor, width: 3),
                  ),
                  child: ClipOval(
                    child: SvgPicture.asset(
                      isActive ? 'assets/svg/on.svg' : 'assets/svg/off.svg',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
