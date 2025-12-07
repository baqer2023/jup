import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:my_app32/features/groups/pages/CreateGroupStep1Page.dart';
import 'package:my_app32/features/groups/pages/EditGroupPage.dart';
import 'package:my_app32/features/groups/pages/group_device_page.dart';
import 'package:my_app32/features/groups/pages/group_customers_page.dart';
import 'package:my_app32/features/widgets/custom_appbar.dart';
import 'package:my_app32/features/widgets/sidebar.dart';
import 'package:my_app32/core/lang/lang.dart';
import '../controllers/group_controller.dart';

class GroupsPage extends StatefulWidget {
  const GroupsPage({super.key});

  @override
  State<GroupsPage> createState() => _GroupsPageState();
}

class _GroupsPageState extends State<GroupsPage> {
  final HomeControllerGroup controller = Get.put(
    HomeControllerGroup(Get.find()),
  );

  @override
  void initState() {
    super.initState();
    _loadGroups();
  }

  void _loadGroups() {
    controller.initializeTokenGroup().then((_) {
      controller.fetchGroups();
    });
  }

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
                  Text(
                    Lang.t('no_group_created_message'), // 🔹 چندزبانه
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
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
              title: group['title'] ?? Lang.t('untitled'), // 🔹 چندزبانه
              description: group['description'] ?? '',
              groupId: group['customerId'] ?? '',
              isActive: group['isActive'] ?? false,
              allocatedDevices: group['allocatedDevices'] ?? 0,
              allocatedUsers: group['allocatedUsers'] ?? 0,
              onUserInfo: (customerId, name, desc) {
                Get.to(
                  () => GroupCustomersPage(
                    groupId: customerId,
                    groupName: name,
                    groupDescription: desc,
                  ),
                )?.then((_) => _loadGroups());
              },
              onDeviceInfo: (customerId, name, desc) {
                Get.to(
                  () => GroupDevicesPage(
                    groupId: customerId,
                    groupName: name,
                    groupDescription: desc,
                  ),
                )?.then((_) => _loadGroups());
              },
              onDelete: (customerId) async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    backgroundColor: Colors.white,
                    titlePadding: EdgeInsets.zero,
                    title: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      color: Colors.blue,
                      child: Text(
                        Lang.t('delete_group'), // 🔹 چندزبانه
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    content: Text(
                      Lang.t('confirm_delete_group'), // 🔹 چندزبانه
                    ),
                    actions: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 100,
                            height: 44,
                            child: ElevatedButton(
                              onPressed: () => Navigator.pop(ctx, false),
                              style: ElevatedButton.styleFrom(
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
                                elevation: 0,
                              ),
                              child: Text(
                                Lang.t('cancel'), // 🔹 چندزبانه
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          SizedBox(
                            width: 100,
                            height: 44,
                            child: ElevatedButton(
                              onPressed: () => Navigator.pop(ctx, true),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Text(
                                Lang.t('delete'), // 🔹 چندزبانه
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );

                if (confirm == true) {
                  await controller.deleteGroup(customerId);
                  _loadGroups();
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
        label: Text(
          Lang.t('create_new_group'), // 🔹 چندزبانه
          style: const TextStyle(color: Colors.white),
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
  final Function(String customerId, String name, String description) onUserInfo;
  final Function(String customerId, String name, String description) onDeviceInfo;
  final Function(String customerId) onDelete;

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
                                      "${Lang.t('devices')}: ${widget.allocatedDevices}", // 🔹 چندزبانه
                                      style: const TextStyle(fontSize: 13),
                                    ),
                                    const SizedBox(width: 4),
                                    const Icon(
                                      Icons.devices,
                                      size: 16,
                                      color: Colors.blueGrey,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    const SizedBox(width: 4),
                                    Text(
                                      "${Lang.t('users')}: ${widget.allocatedUsers}", // 🔹 چندزبانه
                                      style: const TextStyle(fontSize: 13),
                                    ),
                                    const SizedBox(width: 4),
                                    const Icon(
                                      Icons.person,
                                      size: 16,
                                      color: Colors.blueGrey,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: PopupMenuButton<int>(
                          color: Colors.white,
                          icon: const Icon(
                            Icons.more_vert,
                            size: 20,
                            color: Colors.black87,
                          ),
                          onSelected: (value) {
                            if (value == 0) {
                              print(widget.description);
                              Get.to(
                                () => EditGroupPage(
                                  groupId: widget.groupId,
                                  initialTitle: widget.title,
                                  initialDescription: widget.description,
                                ),
                              );
                            } else if (value == 1) {
                              widget.onUserInfo(
                                widget.groupId,
                                widget.title,
                                widget.description,
                              );
                            } else if (value == 2) {
                              widget.onDeviceInfo(
                                widget.groupId,
                                widget.title,
                                widget.description,
                              );
                            } else if (value == 3) {
                              print(
                                'افزودن گروه به داشبورد: ${widget.groupId}',
                              );
                            } else if (value == 4) {
                              widget.onDelete(widget.groupId);
                            }
                          },
                          itemBuilder: (context) => [
                            PopupMenuItem<int>(
                              value: 0,
                              child: Row(
                                textDirection: TextDirection.rtl,
                                children: [
                                  const SizedBox(width: 8),
                                  SvgPicture.asset(
                                    'assets/svg/edit_group.svg',
                                    width: 20,
                                    height: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      Lang.t('edit_group'), // 🔹 چندزبانه
                                      textDirection: TextDirection.rtl,
                                      style: const TextStyle(color: Colors.black),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            PopupMenuItem<int>(
                              value: 1,
                              child: Row(
                                textDirection: TextDirection.rtl,
                                children: [
                                  const SizedBox(width: 8),
                                  SvgPicture.asset(
                                    'assets/svg/custommers_info_froup.svg',
                                    width: 20,
                                    height: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      Lang.t('users_info'), // 🔹 چندزبانه
                                      textDirection: TextDirection.rtl,
                                      style: const TextStyle(color: Colors.black),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            PopupMenuItem<int>(
                              value: 2,
                              child: Row(
                                textDirection: TextDirection.rtl,
                                children: [
                                  const SizedBox(width: 8),
                                  SvgPicture.asset(
                                    'assets/svg/device_info_group.svg',
                                    width: 20,
                                    height: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      Lang.t('devices_info'), // 🔹 چندزبانه
                                      textDirection: TextDirection.rtl,
                                      style: const TextStyle(color: Colors.black),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            PopupMenuItem<int>(
                              value: 3,
                              child: Row(
                                textDirection: TextDirection.rtl,
                                children: [
                                  const SizedBox(width: 8),
                                  SvgPicture.asset(
                                    'assets/svg/add_dashboard.svg',
                                    width: 20,
                                    height: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      Lang.t('add_group_to_dashboard'), // 🔹 چندزبانه
                                      textDirection: TextDirection.rtl,
                                      style: const TextStyle(color: Colors.black),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const PopupMenuDivider(),
                            PopupMenuItem<int>(
                              value: 4,
                              child: Row(
                                textDirection: TextDirection.rtl,
                                children: [
                                  const SizedBox(width: 8),
                                  SvgPicture.asset(
                                    'assets/svg/deleting.svg',
                                    width: 20,
                                    height: 20,
                                    color: Colors.red,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      Lang.t('delete_group'), // 🔹 چندزبانه
                                      textDirection: TextDirection.rtl,
                                      style: const TextStyle(color: Colors.red),
                                    ),
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