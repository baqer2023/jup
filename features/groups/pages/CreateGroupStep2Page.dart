import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:my_app32/features/groups/controllers/group_controller.dart';
import 'package:my_app32/features/groups/pages/group_page.dart';
import 'package:my_app32/features/main/models/home/device_item_model.dart';
import 'CreateGroupStep3Page.dart';

class CreateGroupStep2Page extends StatefulWidget {
  final String groupName;
  final String groupDescription;
  final String groupId;

  const CreateGroupStep2Page({
    super.key,
    required this.groupName,
    required this.groupDescription,
    required this.groupId,
  });

  @override
  State<CreateGroupStep2Page> createState() => _CreateGroupStep2PageState();
}

class _CreateGroupStep2PageState extends State<CreateGroupStep2Page> {
  final HomeControllerGroup controller = Get.put(HomeControllerGroup(Get.find()));

  /// دستگاه‌هایی که کاربر انتخاب کرده
  RxList<DeviceItem> selectedDevices = <DeviceItem>[].obs;

  /// id دستگاه‌های موجود در گروه
  RxSet<String> groupDeviceIds = <String>{}.obs;

  @override
  void initState() {
    super.initState();
    initializeData();
  }

  Future<void> initializeData() async {
    // 1. دریافت id دستگاه‌های گروه
    final customerDevices = await controller.fetchCustomerDeviceInfos(widget.groupId);
    groupDeviceIds.value = customerDevices.map((d) => d.id).toSet();

    // 2. دریافت لوکیشن‌ها
    await controller.fetchUserLocationsGroup();

    // 3. بار اول همه دستگاه‌ها
    await controller.fetchAllDevicesGroup();
  }

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
    return Scaffold(
      appBar: AppBar(title: const Text("ایجاد گروه - مرحله ۲")),
      body: SafeArea(
  child: Padding(
    padding: const EdgeInsets.fromLTRB(16, 16, 16, 24), // 🔹 پایینش کمی فاصله بیشتر داره
    child: Column(
          children: [
            const Text("دستگاه‌هایی که می‌خواهید اضافه کنید را انتخاب کنید:"),
            const SizedBox(height: 16),

            /// فیلتر لوکیشن‌ها
            Obx(() {
              final locations = controller.userLocationsGroup;
              final selectedId = controller.selectedLocationIdGroup.value;

              return SizedBox(
                height: 45,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: locations.length + 1,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final id = index == 0 ? 'all' : locations[index - 1].id ?? 'unknown';
                    final title = index == 0 ? 'همه' : locations[index - 1].title;
                    final isSelected = selectedId == id;

                    return GestureDetector(
                      onTap: () async {
                        controller.selectedLocationIdGroup.value = id;
                        if (id == 'all') {
                          await controller.fetchAllDevicesGroup();
                        } else {
                          await controller.fetchDevicesByLocationGroup(id);
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

            /// لیست دستگاه‌ها
            Expanded(
              child: Obx(() {
                final allDevices = controller.deviceListGroup;
                final selectedLocationId = controller.selectedLocationIdGroup.value;

                final filteredByLocation = selectedLocationId == 'all'
                    ? allDevices
                    : allDevices.where((d) => d.dashboardId == selectedLocationId).toList();

                // فقط دستگاه‌هایی که جزو گروه نیستند
                final devicesNotInGroup = filteredByLocation
                    .where((d) => !groupDeviceIds.contains(d.deviceId))
                    .toList();

                if (devicesNotInGroup.isEmpty) {
                  return const Center(child: Text("هیچ دستگاهی برای اضافه کردن وجود ندارد"));
                }

                return SingleChildScrollView(
  child: Padding(
    padding: const EdgeInsets.only(right: 16, top: 12), // 🔹 فاصله از بالا اضافه شد
    child: Column(

                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: devicesNotInGroup.map((device) {
                        final locationTitle = device.dashboardTitle.isNotEmpty
                            ? device.dashboardTitle
                            : "نامشخص";
                        final isSelected = selectedDevices.contains(device);

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: DeviceCardSimple(
  device: device,
  deviceType: getDeviceStepType(device),
  locationTitle: locationTitle,
  selectedDevices: selectedDevices, // اینجا لیست Rx را پاس بده
)
,
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
    // دکمه انصراف پایین سمت چپ
    SizedBox(
      width: 100,
      height: 44,
      child: TextButton(
        style: TextButton.styleFrom(
          backgroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: const BorderSide(
              color: Color(0xFFF39530),
              width: 2,
            ),
          ),
        ),
        onPressed: () {
          // برگرد به GroupsPage و دوباره گروه‌ها رو لود کن
          Get.offAll(() => GroupsPage());
          final controller = Get.find<HomeControllerGroup>();
          controller.fetchGroups();
        },
        child: const Text(
          "انصراف",
          style: TextStyle(
            color: Color(0xFFF39530),
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    ),

    // دکمه ثبت / بعدی
    SizedBox(
      width: 100,
      height: 44,
      child: ElevatedButton(
        onPressed: () async {
          if (selectedDevices.isEmpty) {
            Get.to(() => CreateGroupStep3Page(
                  groupName: widget.groupName,
                  groupDescription: widget.groupDescription,
                  groupId: widget.groupId,
                ));
            return;
          }

          final success = await controller.assignDevicesPayload(
            selectedDevices,
            widget.groupId,
          );

          if (success) {
            Get.to(() => CreateGroupStep3Page(
                  groupName: widget.groupName,
                  groupDescription: widget.groupDescription,
                  groupId: widget.groupId,
                ));
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: const Text(
          "ثبت / بعدی",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
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

/// کارت دستگاه با تاگل و SVG
/// کارت دستگاه با تاگل و SVG (اصلاح‌شده)
class DeviceCardSimple extends StatefulWidget {
  final DeviceItem device;
  final String deviceType;
  final String locationTitle;
  final RxList<DeviceItem> selectedDevices; // اضافه شد
  final VoidCallback? onTap;

  const DeviceCardSimple({
    super.key,
    required this.device,
    required this.deviceType,
    required this.locationTitle,
    required this.selectedDevices,
    this.onTap,
  });

  @override
  State<DeviceCardSimple> createState() => _DeviceCardSimpleState();
}

class _DeviceCardSimpleState extends State<DeviceCardSimple> {
  late bool isActive;

  @override
  void initState() {
    super.initState();
    // مقدار اولیه بر اساس اینکه دستگاه در selectedDevices هست یا نه
    isActive = widget.selectedDevices.contains(widget.device);
  }

  void toggleSelection() {
    setState(() => isActive = !isActive);
    if (isActive) {
      if (!widget.selectedDevices.contains(widget.device)) {
        widget.selectedDevices.add(widget.device);
      }
    } else {
      widget.selectedDevices.remove(widget.device);
    }

    // فراخوانی callback اختیاری
    if (widget.onTap != null) widget.onTap!();
  }

  @override
  Widget build(BuildContext context) {
    final double cardHeight = 180;
    final double circleSize = 42;
    final double cardWidth = MediaQuery.of(context).size.width * 0.9;
    final borderColor = isActive ? Colors.blue.shade400 : Colors.grey.shade400;

    return Center(
      child: GestureDetector(
        onTap: toggleSelection,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
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
                  circleSize / 1.5 + 24,
                  16,
                  16,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Switch(
                      value: isActive,
                      onChanged: (val) => toggleSelection(), // هماهنگ با کارت
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            widget.device.title,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.deviceType,
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.locationTitle,
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: -circleSize / 4,
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
