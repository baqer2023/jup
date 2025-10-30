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
      customerId: widget.groupId,
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
  body: SafeArea(
  child: Padding(
    padding: const EdgeInsets.fromLTRB(16, 16, 16, 24), // 🔹 پایینش کمی فاصله بیشتر داره
    child: Column(
      children: [
        TextField(
  textAlign: TextAlign.right,
  controller: nameController,
  decoration: InputDecoration(
    label: Align(
      alignment: Alignment.centerRight,
      child: const Text("نام گروه"),
    ),
    border: const OutlineInputBorder(),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.blue, width: 2),
    ),
  ),
),

        const SizedBox(height: 16),
        TextField(
  textAlign: TextAlign.right, // متن راست‌چین
  controller: descController,
  decoration: InputDecoration(
    label: Align(
      alignment: Alignment.centerRight, // لیبل راست‌چین
      child: const Text("توضیحات"),
    ),
    border: const OutlineInputBorder(),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.blue, width: 2), // حاشیه آبی هنگام فوکوس
    ),
  ),
),

        const Spacer(),
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            OutlinedButton(
              onPressed: () {
                Get.back();
              },
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFFF39530), width: 1.5),
                backgroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                minimumSize: const Size.fromHeight(50),
              ),
              child: const Text(
                'انصراف',
                style: TextStyle(
                  color: Color(0xFFF39530),
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: isSubmitting ? null : handleUpdate,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                minimumSize: const Size.fromHeight(50),
              ),
              child: isSubmitting
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      "به‌روزرسانی",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
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
