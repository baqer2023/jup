import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:my_app32/app/core/base/base_view.dart';
import 'package:my_app32/app/theme/app_colors.dart';
import 'package:my_app32/features/main/pages/devices/devices_controller.dart';
import 'package:my_app32/features/widgets/app_bar_widget.dart';
import 'package:my_app32/features/widgets/fill_button_widget.dart';
import 'package:my_app32/features/widgets/text_form_field_widget.dart';

class DevicesPage extends BaseView<DevicesController> {
  const DevicesPage({super.key});

  @override
  Widget body() {
    return Column(
      children: [
        controller.isLoading.value ? const SizedBox() : const SizedBox(),
        const AppBarWidget(title: 'Devices', showBackButton: false),
        const SizedBox(height: 24),
        Expanded(
          child: controller.isLoading.value
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                  itemCount: controller.devices?.length ?? 0,
                  physics: const BouncingScrollPhysics(),
                  shrinkWrap: true,
                  itemBuilder: (context, index) => deviceItem(index),
                ),
        ),
      ],
    );
  }

  Widget deviceItem(int index) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, const Color(0xFFF8FBFF)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE3F2FD), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0676C8).withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: const Color(0xFF0676C8).withOpacity(0.04),
            blurRadius: 4,
            offset: const Offset(0, 2),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                // Icon with background
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(0xFF0676C8),
                        const Color(0xFF49A7EA),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0676C8).withOpacity(0.3),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.device_hub,
                    color: Colors.white,
                    size: 20.0,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  controller.devices?[index].name ?? '',
                  style: Get.textTheme.titleLarge?.copyWith(
                    color: const Color(0xFF1E3A8A),
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
            Row(
              children: [
                Container(
                  margin: const EdgeInsets.only(right: 8),
                  child: ElevatedButton(
                    onPressed: () {
                      String textToCopy = controller.devices![index].id!.id!;
                      Clipboard.setData(ClipboardData(text: textToCopy));
                      ScaffoldMessenger.of(Get.context!).showSnackBar(
                        const SnackBar(
                          content: Text('Device ID Copied to Clipboard'),
                          backgroundColor: Color(0xFF0676C8),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      backgroundColor: const Color(0xFF0676C8),
                      foregroundColor: Colors.white,
                      elevation: 2,
                      shadowColor: const Color(0xFF0676C8).withOpacity(0.3),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Copy Id',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(left: 4),
                  child: ElevatedButton(
                    onPressed: () {
                      String textToCopy = controller.devices![index].id!.id!;
                      Clipboard.setData(ClipboardData(text: textToCopy));
                      ScaffoldMessenger.of(Get.context!).showSnackBar(
                        const SnackBar(
                          content: Text('Token Copied to Clipboard'),
                          backgroundColor: Color(0xFF49A7EA),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      backgroundColor: const Color(0xFF49A7EA),
                      foregroundColor: Colors.white,
                      elevation: 2,
                      shadowColor: const Color(0xFF49A7EA).withOpacity(0.3),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Copy Token',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.more_vert, color: Color(0xFF0676C8)),
                  onPressed: () {
                    showModalBottomSheet(
                      context: Get.context!,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(20),
                        ),
                      ),
                      builder: (context) {
                        return Container(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ListTile(
                                leading: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                title: const Text(
                                  'Remove Device',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color: Colors.red,
                                  ),
                                ),
                                onTap: () {
                                  Navigator.pop(context);
                                  showDialog(
                                    context: Get.context!,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Remove Device'),
                                      content: Text(
                                        'Are you sure you want to remove device "${controller.devices![index].name}"?',
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context),
                                          child: const Text('Cancel'),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                            controller.removeDevice(
                                              controller
                                                  .devices![index]
                                                  .id!
                                                  .id!,
                                            );
                                          },
                                          style: TextButton.styleFrom(
                                            foregroundColor: Colors.red,
                                          ),
                                          child: const Text('Remove'),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget? floatingActionButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        shape: const CircleBorder(),
        padding: const EdgeInsets.all(15),
        backgroundColor: AppColors.primaryColor,
      ),
      onPressed: () => showCustomModal(),
      child: const Icon(Icons.add, color: Colors.white, size: 24),
    );
  }

  void showCustomModal() {
    Get.bottomSheet(
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Add Device", style: Get.textTheme.titleLarge),
            const Divider(height: 16),
            const SizedBox(height: 16),
            TextFormFieldWidget(
              controller: controller.titleController,
              label: const Text('Title*'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Title cannot be empty';
                }
                return null;
              },
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  width: 180,
                  child: FillButtonWidget(
                    onTap: () => Get.back(),
                    buttonTitle: 'Cancel',
                    isLoading: false,
                  ),
                ),
                SizedBox(
                  width: 180,
                  child: FillButtonWidget(
                    isLoading: false,
                    onTap: () {
                      String title = controller.titleController.text;
                      controller.createDevice(title);
                      Get.back();
                    },
                    buttonTitle: 'Add',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      backgroundColor: AppColors.gray[25],
      isScrollControlled: true,
    );
  }
}
