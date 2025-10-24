import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_app32/features/groups/controllers/group_controller.dart';
import 'package:my_app32/features/groups/pages/group_page.dart';
import '../../widgets/custom_appbar.dart';
import '../../widgets/sidebar.dart';

class EditGroupPage extends StatefulWidget {
  final String groupId;
  final String initialTitle;
  final String initialDescription;

  const EditGroupPage({
    super.key,
    required this.groupId,
    required this.initialTitle,
    required this.initialDescription,
  });

  @override
  State<EditGroupPage> createState() => _EditGroupPageState();
}

class _EditGroupPageState extends State<EditGroupPage> {
  final nameController = TextEditingController();
  final descController = TextEditingController();
  final HomeControllerGroup controller = Get.find();
  bool isSubmitting = false;

  @override
  void initState() {
    super.initState();
    nameController.text = widget.initialTitle;
    descController.text = widget.initialDescription;
  }

  Future<void> handleUpdate() async {
    setState(() => isSubmitting = true);

    final savedId = await controller.updateGroup(
      id: widget.groupId,
      title: nameController.text,
      description: descController.text,
    );

    setState(() => isSubmitting = false);

    if (savedId != null) {
      Get.offAll(() => GroupsPage());
      controller.fetchGroups();
    } else {
      Get.snackbar(
        'خطا',
        'به‌روزرسانی گروه موفق نبود',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      appBar: AppBar(title: const Text("ویرایش گروه")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: "نام گروه",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descController,
              decoration: const InputDecoration(
                labelText: "توضیحات",
                border: OutlineInputBorder(),
              ),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: isSubmitting ? null : handleUpdate,
              child: isSubmitting
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("به‌روزرسانی"),
            ),
          ],
        ),
      ),
    );
  }
}
