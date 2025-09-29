import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:my_app32/features/groups/pages/CreateGroupStep1Page.dart';
import 'package:my_app32/features/groups/pages/group_device_page.dart';
import 'package:my_app32/features/groups/pages/group_customers_page.dart';
import 'package:my_app32/features/widgets/custom_appbar.dart';
import 'package:my_app32/features/widgets/sidebar.dart';
import '../controllers/group_controller.dart';

class GroupsPage extends StatefulWidget {
  const GroupsPage({super.key});

  @override
  State<GroupsPage> createState() => _GroupsPageState();
}

class _GroupsPageState extends State<GroupsPage> {
  final HomeControllerGroup controller =
      Get.put(HomeControllerGroup(Get.find()));

  @override
  void initState() {
    super.initState();
    _loadGroups();
  }

  /// متد برای اطمینان از آماده بودن توکن قبل از fetchGroups
  void _loadGroups() {
    controller.initializeTokenGroup().then((_) {
      controller.fetchGroups();
    });
  }

  /// وقتی صفحه دوباره برگشته شد یا از صفحه‌ای دیگر برگشتیم، دوباره داده‌ها لود می‌شوند
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadGroups();
  }

  @override
  Widget build(BuildContext context) {
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
                    child: SvgPicture.asset(
                      'assets/svg/NGroupF.svg',
                      fit: BoxFit.fill,
                    ),
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
              allocatedDevices: group['allocatedDevices'] ?? 0,
              allocatedUsers: group['allocatedUsers'] ?? 0,
              onUserInfo: (id, name, desc) {
                Get.to(() => GroupCustomersPage(
                      groupId: id,
                      groupName: name,
                      groupDescription: desc,
                    ))?.then((_) => _loadGroups());
              },
              onDeviceInfo: (id, name, desc) {
                Get.to(() => GroupDevicesPage(
                      groupId: id,
                      groupName: name,
                      groupDescription: desc,
                    ))?.then((_) => _loadGroups());
              },
              onDelete: (id) async {
  final confirm = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: Colors.white, // بک‌گراند کلی سفید
      titlePadding: EdgeInsets.zero, // حذف padding پیش‌فرض برای هدر سفارشی
      title: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        color: Colors.blue, // هدر آبی
        child: const Text(
          "حذف گروه",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      content: const Text(
        "آیا مطمئن هستید که می‌خواهید این گروه را حذف کنید؟",
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          style: TextButton.styleFrom(
            backgroundColor: Colors.white, // بک‌گراند سفید
            foregroundColor: Colors.yellow, // متن زرد
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          child: const Text("انصراف"),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(ctx, true),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue, // بک‌گراند آبی
            foregroundColor: Colors.white, // متن سفید
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          child: const Text("حذف"),
        ),
      ],
    ),
  );

  if (confirm == true) {
    await controller.deleteGroup(id);
    _loadGroups(); // دوباره لود کردن گروه‌ها
  }
},

            );
          },
        );
      }),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Get.to(() => CreateGroupStep1Page())?.then((_) => _loadGroups());
        },
        label: const Text(
          "ایجاد گروه جدید",
          style: TextStyle(color: Colors.white),
        ),
        icon: const Icon(Icons.add, color: Colors.white),
        backgroundColor: Colors.blue,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

class GroupCard extends StatefulWidget {
  final String title;
  final String description;
  final String groupId;
  final bool isActive;
  final int allocatedDevices;
  final int allocatedUsers;
  final Function(String id, String name, String description) onUserInfo;
  final Function(String id, String name, String description) onDeviceInfo;
  final Function(String id) onDelete;

  const GroupCard({
    super.key,
    required this.title,
    required this.description,
    required this.groupId,
    this.isActive = false,
    required this.allocatedDevices,
    required this.allocatedUsers,
    required this.onUserInfo,
    required this.onDeviceInfo,
    required this.onDelete,
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
    Color borderColor =
        _isActive ? Colors.blue.shade400 : Colors.grey.shade400;

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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Switch(
                            value: _isActive,
                            onChanged: (val) {
                              setState(() => _isActive = val);
                            },
                            activeColor: Colors.blue,
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  widget.title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    const SizedBox(width: 4),
                                    Text(
                                      "دستگاه‌ها: ${widget.allocatedDevices}",
                                      style: const TextStyle(fontSize: 13),
                                    ),
                                    const SizedBox(width: 4),
                                    const Icon(Icons.devices,
                                        size: 16, color: Colors.blueGrey),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    const SizedBox(width: 4),
                                    Text(
                                      "کاربران: ${widget.allocatedUsers}",
                                      style: const TextStyle(fontSize: 13),
                                    ),
                                    const SizedBox(width: 4),
                                    const Icon(Icons.person,
                                        size: 16, color: Colors.blueGrey),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      if (widget.description.isNotEmpty)
                        Text(
                          widget.description,
                          style: const TextStyle(color: Colors.grey, fontSize: 14),
                        ),
                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: PopupMenuButton<int>(
                          icon: const Icon(Icons.more_vert,
                              size: 20, color: Colors.black87),
                          onSelected: (value) {
                            if (value == 0) {
                              widget.onUserInfo(widget.groupId, widget.title,
                                  widget.description);
                            } else if (value == 1) {
                              widget.onDeviceInfo(widget.groupId, widget.title,
                                  widget.description);
                            } else if (value == 2) {
                              widget.onDelete(widget.groupId);
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
                            PopupMenuItem(
                              value: 2,
                              child: Text('حذف گروه',
                                  style: TextStyle(color: Colors.red)),
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
                    child: SvgPicture.asset(
                      _isActive
                          ? 'assets/svg/group_on.svg'
                          : 'assets/svg/group_off.svg',
                      fit: BoxFit.cover,
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
