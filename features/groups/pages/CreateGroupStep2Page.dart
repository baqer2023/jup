import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_app32/features/groups/controllers/group_controller.dart';
import 'package:my_app32/features/main/models/home/device_item_model.dart';
import 'CreateGroupStep3Page.dart';


class CreateGroupStep2Page extends StatelessWidget {
  final String groupName;
  final String groupDescription;

  const CreateGroupStep2Page({
    super.key,
    required this.groupName,
    required this.groupDescription,
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

  @override
  Widget build(BuildContext context) {
    final HomeControllerGroup controller = Get.put(HomeControllerGroup(Get.find()));
    final selectedDevices = <DeviceItem>[].obs;

    // وقتی صفحه لود شد، می‌تونیم گروه‌ها رو بگیریم
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
            // اول مقدار selectedLocationIdGroup رو تغییر بده
            controller.selectedLocationIdGroup.value = id;

            // بعد fetch دیتا
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
})
,
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
                    final isSelected = selectedDevices.contains(device);
                    return ListTile(
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(device.title),
                          Text(getDeviceStepType(device),
                              style: const TextStyle(fontSize: 12, color: Colors.grey)),
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
                  onPressed: () {
                    final selectedDeviceNames = selectedDevices.map((d) => d.title).toList();
                    Get.to(() => CreateGroupStep3Page(
                          groupName: groupName,
                          groupDescription: groupDescription,
                          devices: selectedDeviceNames,
                        ));
                  },
                  child: const Text("بعدی"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
