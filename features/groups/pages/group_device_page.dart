import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:my_app32/app/services/realable_controller.dart';
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
  RxString selectedLocationId = "".obs;

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
    body: Stack(
      children: [
        Column(
          children: [
            const SizedBox(height: 8),
            /// فیلتر لوکیشن‌ها
/// فیلتر لوکیشن‌ها با گزینه "همه" و رفتار مشابه نمونه
Obx(() {
  final locations = controller.userLocationsGroup
      .where((loc) => loc.title != "میانبر")
      .toList();
  final selectedId = selectedLocationId.value;

  return SizedBox(
    height: 50,
    child: ListView.separated(
      scrollDirection: Axis.horizontal,
      separatorBuilder: (_, __) => const SizedBox(width: 8),
      itemCount: locations.length + 1, // +1 برای "همه"
      itemBuilder: (context, index) {
        final id = index == 0 ? "all" : locations[index - 1].id ?? 'unknown';
        final title = index == 0 ? "همه" : locations[index - 1].title;
        final isSelected = selectedId == id; // بررسی دقیق

        return GestureDetector(
          onTap: () async {
            // ریست کوتاه برای انیمیشن
            selectedLocationId.value = '';
            await Future.delayed(const Duration(milliseconds: 10));
            selectedLocationId.value = id;

            await fetchFilteredDevices();
          },
          child: Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(
                color: isSelected ? Colors.yellow.shade700 : Colors.grey.shade300,
                width: isSelected ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(30), // کاملاً گرد
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
                title,
                style: TextStyle(
                  color: isSelected ? Colors.yellow.shade700 : Colors.grey,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        );
      },
    ),
  );
})

,
            const SizedBox(height: 16),

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
      groupId: widget.groupId,
      customerDevice: customerDevice,
      deviceItem: deviceItem,
      onDeleted: () {
  filteredDevices.removeWhere((d) => d.id == customerDevice.id);
  groupDeviceIds.remove(customerDevice.id); // اختیاری ولی بهتره
}
,

    ),
  );
}).toList(),

                  ),
                );
              }),
            ),
            const SizedBox(height: 70), // فاصله برای دکمه
          ],
        ),

        /// دکمه پایین وسط صفحه
        Positioned(
          bottom: 62,
          left: 0,
          right: 0,
          child: Center(
            child: SizedBox(
              width: 200, // کوچکتر
              height: 45,
              child: ElevatedButton.icon(
                icon: const Icon(
                  Icons.add,
                  color: Colors.white,
                  size: 20,
                ),
                label: const Text(
                  "افزودن دستگاه به گروه",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                onPressed: () {
                  Get.to(() => CreateGroupStep2Page(
                        groupName: widget.groupName,
                        groupDescription: widget.groupDescription,
                        groupId: widget.groupId,
                      ));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue, // بک‌گراند آبی
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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

class DeviceCardSimpleCustom extends StatefulWidget {
  final String? groupId;
  final CustomerDevice customerDevice;
  final DeviceItem? deviceItem;

  
  /// callback وقتی دستگاه حذف شد
  final VoidCallback? onDeleted;

  const DeviceCardSimpleCustom({
    super.key,
    this.groupId,
    required this.customerDevice,
    this.deviceItem,
    this.onDeleted,
  });

  @override
  State<DeviceCardSimpleCustom> createState() => _DeviceCardSimpleCustomState();
}

class _DeviceCardSimpleCustomState extends State<DeviceCardSimpleCustom> {
  bool isActive = false;
  bool isLoading = false;

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

  Future<void> _unassignDevice() async {
    final confirm = await showDialog<bool>(
  context: context,
  builder: (context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      titlePadding: const EdgeInsets.all(0),
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
            'حذف دستگاه از گروه',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Colors.white,
            ),
          ),
        ),
      ),
      content: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        child: Text(
          'آیا از حذف این دستگاه از گروه اطمینان دارید؟',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 15,
            color: Colors.black87,
            height: 1.5,
          ),
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
                  onPressed: () => Navigator.of(context).pop(false),
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
              const SizedBox(width: 8),

              // دکمه حذف (آبی)
              SizedBox(
                width: 100,
                height: 44,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
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
                    'حذف',
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


    if (confirm != true) return;

    setState(() => isLoading = true);
    final controller = Get.find<HomeControllerGroup>();

    final success = await controller.unassignDeviceFromCustomer(
      customerId: widget.groupId!,
      deviceId: widget.customerDevice.id,
    );

    if (success) {
  widget.onDeleted?.call();
}

    if (!mounted) return;
    setState(() => isLoading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success ? '✅ دستگاه با موفقیت از گروه حذف شد' : '❌ خطا در حذف دستگاه از گروه',
        ),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double cardHeight = 180;
    final double circleSize = 42;
    final double cardWidth = MediaQuery.of(context).size.width * 0.9;
    final borderColor = isActive ? Colors.blue.shade400 : Colors.grey.shade400;

    final displayName = widget.deviceItem?.title ?? widget.customerDevice.label;
    final deviceType = getDeviceTypeName();

    ReliableSocketController? reliableController;
    if (Get.isRegistered<ReliableSocketController>(tag: 'smartDevicesController')) {
      reliableController = Get.find<ReliableSocketController>(tag: 'smartDevicesController');
    }

    String lastActivityText = "آخرین همگام سازی: نامشخص";
    if (reliableController != null) {
      final lastSeen = reliableController.lastDeviceActivity[widget.deviceItem?.deviceId ?? ''];
      if (lastSeen != null) {
        final formattedDate =
            "${lastSeen.year}/${lastSeen.month.toString().padLeft(2, '0')}/${lastSeen.day.toString().padLeft(2, '0')}";
        final formattedTime =
            "${lastSeen.hour.toString().padLeft(2, '0')}:${lastSeen.minute.toString().padLeft(2, '0')}:${lastSeen.second.toString().padLeft(2, '0')}";
        lastActivityText = "آخرین همگام سازی: $formattedDate - $formattedTime";
      }
    }

    return Center(
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
                circleSize / 1.5 + 24,
                16,
                16,
              ),
              child: Stack(
                children: [
                  Row(
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
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // وضعیت آنلاین/نوع کلید
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (reliableController != null)
                                  Obx(() {
                                    final lastSeen =
                                        reliableController!.lastDeviceActivity[widget.deviceItem?.deviceId ?? ''];
                                    final isOnline = lastSeen != null &&
                                        DateTime.now().difference(lastSeen) < const Duration(seconds: 30);
                                    return Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: isOnline ? Colors.blue : Colors.grey,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        isOnline ? "آنلاین" : "آفلاین",
                                        style: const TextStyle(
                                            color: Colors.white, fontSize: 10, fontWeight: FontWeight.w500),
                                      ),
                                    );
                                  }),
                                const SizedBox(width: 6),
                                Flexible(
                                  child: Text(
                                    deviceType,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Flexible(
                              child: Text(
                                displayName,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.right,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Flexible(
                                  child: Text(
                                    widget.deviceItem?.dashboardTitle ?? "بدون مکان",
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey.shade600,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    textAlign: TextAlign.right,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                SvgPicture.asset('assets/svg/location.svg', width: 20, height: 20),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Flexible(
                              child: Text(
                                lastActivityText,
                                style: TextStyle(color: Colors.grey.shade600, fontSize: 10),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.right,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  // 🔹 منوی سه‌نقطه پایین سمت چپ
                  Positioned(
                    bottom: 0,
                    left: 0,
                    child: PopupMenuButton<int>(
                      color: Colors.white,
                      icon: const Icon(Icons.more_vert, color: Colors.black54),
                      onSelected: (value) {
                        if (value == 0) _unassignDevice();
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem<int>(
                          value: 0,
                          child: Row(
                            textDirection: TextDirection.rtl,
                            children: [
                              const Icon(Icons.delete, color: Colors.red),
                              const SizedBox(width: 8),
                              const Text(
                                'حذف دستگاه از گروه',
                                style: TextStyle(color: Colors.red),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // دایره وضعیت بالا وسط
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
