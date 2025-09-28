import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:my_app32/features/groups/controllers/group_controller.dart';
import 'package:my_app32/features/groups/models/customer_device_model.dart';
import 'package:my_app32/features/main/models/home/device_item_model.dart';
import 'CreateGroupStep2Page.dart';

class GroupDevicesPage extends StatefulWidget {
  final String groupName;
  final String groupDescription;
  final String groupId;

  const GroupDevicesPage({
    super.key,
    required this.groupName,
    required this.groupDescription,
    required this.groupId,
  });

  @override
  State<GroupDevicesPage> createState() => _GroupDevicesPageState();
}

class _GroupDevicesPageState extends State<GroupDevicesPage> {
  final HomeControllerGroup controller = Get.put(HomeControllerGroup(Get.find()));

  /// لیست id هایی که از fetchCustomerDeviceInfos میاد
  RxSet<String> groupDeviceIds = <String>{}.obs;

  /// لیست دستگاه‌های نهایی (بعد از فیلتر شدن)
  RxList<CustomerDevice> filteredDevices = <CustomerDevice>[].obs;

  /// برای فیلتر لوکیشن
  RxString selectedLocationId = "all".obs;

  @override
  void initState() {
    super.initState();
    initializeData();
  }

  Future<void> initializeData() async {
    await fetchGroupDeviceIds();
    await controller.fetchUserLocationsGroup();
    await fetchFilteredDevices();
  }

  Future<void> fetchGroupDeviceIds() async {
    final rawDevices = await controller.fetchCustomerDeviceInfos(widget.groupId);
    groupDeviceIds.value = rawDevices.map((d) => d.id).toSet();
  }

  Future<void> fetchFilteredDevices() async {
    List<DeviceItem> rawDevices = [];

    if (selectedLocationId.value == "all") {
      await controller.fetchAllDevicesGroup();
      rawDevices = controller.deviceListGroup;
    } else {
      await controller.fetchDevicesByLocationGroup(selectedLocationId.value);
      rawDevices = controller.deviceListGroup;
    }

    // تبدیل DeviceItem به CustomerDevice برای فیلتر گروه
    final allDevices = rawDevices.map((d) {
      return CustomerDevice(
        id: d.deviceId,
        name: d.title,
        label: d.title,
        deviceProfileName: d.deviceTypeName ?? '',
      );
    }).toList();

    // فقط دستگاه‌های موجود در گروه
    filteredDevices.value =
        allDevices.where((d) => groupDeviceIds.contains(d.id)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("دستگاه‌های گروه: ${widget.groupName}")),
      body: Column(
        children: [
          const SizedBox(height: 8),

          /// فیلتر لوکیشن‌ها
          Obx(() {
            final locations = controller.userLocationsGroup;
            return SizedBox(
              height: 45,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: locations.length + 1,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final id = index == 0 ? "all" : locations[index - 1].id ?? "unknown";
                  final title = index == 0 ? "همه" : locations[index - 1].title;

                  return GestureDetector(
                    onTap: () async {
                      selectedLocationId.value = id;
                      await fetchFilteredDevices();
                    },
                    child: Obx(() {
                      final isSelected = selectedLocationId.value == id;
                      return AnimatedContainer(
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
                      );
                    }),
                  );
                },
              ),
            );
          }),

          const SizedBox(height: 16),

          /// دکمه افزودن دستگاه به گروه
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text("افزودن دستگاه به گروه"),
                onPressed: () {
                  Get.to(() => CreateGroupStep2Page(
                        groupName: widget.groupName,
                        groupDescription: widget.groupDescription,
                        groupId: widget.groupId,
                      ));
                },
              ),
            ),
          ),

          const SizedBox(height: 8),

          /// لیست دستگاه‌ها
          Expanded(
            child: Obx(() {
              if (filteredDevices.isEmpty) {
                return const Center(child: Text("هیچ دستگاهی یافت نشد"));
              }

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: filteredDevices.map((customerDevice) {
                    // پیدا کردن DeviceItem متناظر برای نمایش بهتر
                    DeviceItem? deviceItem;
try {
  deviceItem = controller.deviceListGroup.firstWhere(
    (d) => d.deviceId == customerDevice.id,
  );
} catch (_) {
  deviceItem = null;
}


                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: DeviceCardSimpleCustom(
                        customerDevice: customerDevice,
                        deviceItem: deviceItem,
                      ),
                    );
                  }).toList(),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class DeviceCardSimpleCustom extends StatefulWidget {
  final CustomerDevice customerDevice;
  final DeviceItem? deviceItem;

  const DeviceCardSimpleCustom({
    super.key,
    required this.customerDevice,
    this.deviceItem,
  });

  @override
  State<DeviceCardSimpleCustom> createState() => _DeviceCardSimpleCustomState();
}

class _DeviceCardSimpleCustomState extends State<DeviceCardSimpleCustom> {
  bool isActive = false;

  String getDeviceTypeName() {
    final type = widget.deviceItem?.deviceTypeName ?? widget.customerDevice.deviceProfileName;
    switch (type) {
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
    final double cardHeight = 180;
    final double circleSize = 42;
    final double cardWidth = MediaQuery.of(context).size.width * 0.9;
    final borderColor = isActive ? Colors.blue.shade400 : Colors.grey.shade400;

    // استفاده از اطلاعات کامل DeviceItem در صورت وجود
    final displayName = widget.deviceItem?.title ?? widget.customerDevice.label;
    final deviceType = getDeviceTypeName();

    return Center(
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
                    onChanged: (val) => setState(() => isActive = val),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          displayName,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "نوع: $deviceType",
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
    );
  }
}
