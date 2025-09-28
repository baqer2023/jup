import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:my_app32/features/groups/controllers/group_controller.dart';
import 'package:my_app32/features/groups/pages/CreateGroupStep2Page.dart';
import 'package:my_app32/features/main/models/home/device_item_model.dart';

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
  final HomeControllerGroup controller =
      Get.put(HomeControllerGroup(Get.find()));
  RxList<Map<String, dynamic>> customerDevices = <Map<String, dynamic>>[].obs;

  @override
  void initState() {
    super.initState();
    fetchGroupDevices();
    if (controller.userLocationsGroup.isEmpty) {
      controller.fetchUserLocationsGroup();
    }
  }

  Future<void> fetchGroupDevices() async {
    final devices = await controller.fetchCustomerDeviceInfos(widget.groupId);
    customerDevices.value = devices;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("دستگاه‌های گروه: ${widget.groupName}")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ElevatedButton.icon(
              onPressed: () {
                Get.to(() => CreateGroupStep2Page(
                      groupName: widget.groupName,
                      groupDescription: widget.groupDescription,
                      groupId: widget.groupId,
                    ));
              },
              icon: const Icon(Icons.add),
              label: const Text("اضافه کردن دستگاه به گروه"),
            ),
            const SizedBox(height: 16),
            const Text(
              "لیست دستگاه‌های گروه:",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
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
                    final id =
                        index == 0 ? 'all' : groups[index - 1].id ?? 'unknown';
                    final title = index == 0 ? 'همه' : groups[index - 1].title;
                    final isSelected = selectedId == id && selectedId.isNotEmpty;

                    return GestureDetector(
                      onTap: () async {
                        controller.selectedLocationIdGroup.value = id;
                        if (id == 'all') {
                          await controller.fetchAllDevicesGroup();
                        } else {
                          await controller.fetchDevicesByLocationGroup(id);
                        }
                        await fetchGroupDevices(); // همیشه به‌روز
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(
                            color: isSelected ? Colors.blue : Colors.grey.shade300,
                            width: isSelected ? 2 : 1,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            title,
                            style: TextStyle(
                              color: isSelected ? Colors.blue : Colors.grey,
                              fontWeight:
                                  isSelected ? FontWeight.bold : FontWeight.normal,
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

            // نمایش دستگاه‌ها
            Expanded(
              child: Obx(() {
                final allDevices = controller.deviceListGroup;

                // فقط دستگاه‌هایی که در customerDevices هستند
                final devicesInGroup = allDevices.where((device) {
                  final deviceIdStr = device.deviceId?.toString().trim() ?? '';
                  return customerDevices.any((cd) =>
                      (cd['deviceId']?.toString().trim() ?? '') == deviceIdStr);
                }).toList();

                if (devicesInGroup.isEmpty) {
                  return const Center(child: Text("هیچ دستگاهی در این گروه موجود نیست"));
                }

                final double cardWidth = 300;
                final double cardHeight = 220;
                final double circleSize = 42;

                return SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 40, right: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: devicesInGroup.map((device) {
                        final locationTitle = device.dashboardTitle.isNotEmpty
                            ? device.dashboardTitle
                            : "نامشخص";

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: DeviceCard(
                            device: device,
                            locationTitle: locationTitle,
                            cardWidth: cardWidth,
                            cardHeight: cardHeight,
                            circleSize: circleSize,
                            isAlreadyInGroup: true,
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class DeviceCard extends StatefulWidget {
  final DeviceItem device;
  final String locationTitle;
  final double cardWidth;
  final double cardHeight;
  final double circleSize;
  final bool isAlreadyInGroup;

  const DeviceCard({
    super.key,
    required this.device,
    required this.locationTitle,
    required this.cardWidth,
    required this.cardHeight,
    required this.circleSize,
    required this.isAlreadyInGroup,
  });

  @override
  State<DeviceCard> createState() => _DeviceCardState();
}

class _DeviceCardState extends State<DeviceCard> {
  bool isActive = false;

  String getKeyType(String typeName) {
    switch (typeName) {
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
    final borderColor = Colors.green.shade400;

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
              width: widget.cardWidth,
              height: widget.cardHeight,
              padding: EdgeInsets.fromLTRB(
                  16, widget.circleSize / 1.2, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const SizedBox(width: 50),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            getKeyType(widget.device.deviceTypeName),
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            widget.device.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            widget.locationTitle,
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                          ),
                          const Text(
                            "اضافه شده قبلاً",
                            style: TextStyle(fontSize: 12, color: Colors.green),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const Spacer(),
                ],
              ),
            ),
          ),
          Positioned(
            top: -widget.circleSize / 3,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: widget.circleSize,
                height: widget.circleSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: borderColor,
                    width: 3,
                  ),
                ),
                child: ClipOval(
                  child: SvgPicture.asset(
                    'assets/svg/on.svg',
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
