import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:my_app32/features/groups/pages/CreateGroupStep1Page.dart';
import 'package:my_app32/features/groups/pages/group_device_page.dart';
import 'package:my_app32/features/groups/pages/group_customers_page.dart'; // اضافه شد
import 'package:my_app32/features/widgets/custom_appbar.dart';
import 'package:my_app32/features/widgets/sidebar.dart';
import '../controllers/group_controller.dart';

class GroupsPage extends StatelessWidget {
  GroupsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final HomeControllerGroup controller = Get.put(HomeControllerGroup(Get.find()));

    if (controller.groups.isEmpty && !controller.isLoading.value) {
      controller.initializeTokenGroup().then((_) => controller.fetchGroups());
    }

    return Scaffold(
      endDrawer: const Sidebar(),
      appBar: CustomAppBar(isRefreshing: controller.isRefreshing),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.groups.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    height: 180,
                    child: SvgPicture.asset('assets/svg/NGroupF.svg', fit: BoxFit.fill),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "تا کنون گروهی ایجاد نشده‌است، جهت ایجاد گروه جدید روی دکمه پایین صفحه کلیک کنید",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.groups.length,
          itemBuilder: (context, index) {
            final group = controller.groups[index];
            return GroupCard(
              title: group['title'] ?? 'بدون عنوان',
              description: group['description'] ?? '',
              groupId: group['id'] ?? '',
              isActive: group['isActive'] ?? false,
              onUserInfo: (id, name, desc) {
                // رفتن به صفحه اطلاعات مشتری‌ها
                Get.to(() => GroupCustomersPage(
                      groupId: id,
                      groupName: name,
                      groupDescription: desc,
                    ));
              },
              onDeviceInfo: (id, name, desc) {
                // رفتن به صفحه اطلاعات دستگاه‌ها
                Get.to(() => GroupDevicesPage(
                      groupId: id,
                      groupName: name,
                      groupDescription: desc,
                    ));
              },
            );
          },
        );
      }),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.to(() => CreateGroupStep1Page()),
        label: const Text("ایجاد گروه جدید"),
        icon: const Icon(Icons.add),
      ),
    );
  }
}

class GroupCard extends StatefulWidget {
  final String title;
  final String description;
  final String groupId;
  final bool isActive;
  final Function(String id, String name, String description) onUserInfo; // تغییر کرد
  final Function(String id, String name, String description) onDeviceInfo;

  const GroupCard({
    super.key,
    required this.title,
    required this.description,
    required this.groupId,
    this.isActive = false,
    required this.onUserInfo,
    required this.onDeviceInfo,
  });

  @override
  State<GroupCard> createState() => _GroupCardState();
}

class _GroupCardState extends State<GroupCard> {
  late bool _isActive;

  @override
  void initState() {
    super.initState();
    _isActive = widget.isActive;
  }

  @override
  Widget build(BuildContext context) {
    Color borderColor = _isActive ? Colors.blue.shade400 : Colors.grey.shade400;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Card(
                color: Colors.white,
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: borderColor, width: 2),
                ),
                shadowColor: Colors.black12,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 32, 12, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Switch(
                            value: _isActive,
                            onChanged: (val) {
                              setState(() => _isActive = val);
                            },
                            activeColor: Colors.blue,
                          ),
                          Text(
                            widget.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        widget.description,
                        style: const TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: PopupMenuButton<int>(
                          icon: const Icon(Icons.more_vert, size: 20, color: Colors.black87),
                          onSelected: (value) {
                            if (value == 0) {
                              widget.onUserInfo(widget.groupId, widget.title, widget.description);
                            } else if (value == 1) {
                              widget.onDeviceInfo(widget.groupId, widget.title, widget.description);
                            }
                          },
                          itemBuilder: (context) => const [
                            PopupMenuItem(
                              value: 0,
                              child: Text('اطلاعات کاربران'),
                            ),
                            PopupMenuItem(
                              value: 1,
                              child: Text('اطلاعات دستگاه‌ها'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: -20,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    width: 45,
                    height: 45,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: borderColor, width: 3),
                      boxShadow: [
                        if (_isActive)
                          BoxShadow(
                            color: Colors.blue.shade200.withOpacity(0.5),
                            blurRadius: 5,
                            spreadRadius: 1,
                          ),
                      ],
                    ),
                    child: ClipOval(
                      child: SvgPicture.asset(
                        _isActive ? 'assets/svg/group_on.svg' : 'assets/svg/group_off.svg',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
