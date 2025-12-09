import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_app32/features/groups/controllers/group_controller.dart';
import 'package:my_app32/features/groups/pages/group_page.dart';
import 'package:my_app32/core/lang/lang.dart';
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

   final isEnglish = Lang.current.value == 'en';

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
        Lang.t('error'), // 🔹 چندزبانه
        Lang.t('group_update_failed'), // 🔹 چندزبانه
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    
return Scaffold(
  appBar: AppBar(title: Text(Lang.t('edit_group'))), // 🔹 چندزبانه
  body: SafeArea(
  child: Padding(
    padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
    child: Column(
      children: [
TextField(
  controller: nameController,
  textAlign: isEnglish ? TextAlign.left : TextAlign.right,
  decoration: InputDecoration(
    label: Align(
      alignment:
          isEnglish ? Alignment.centerLeft : Alignment.centerRight,
      child: Text(
        Lang.t('group_name'),
      ),
    ),
    border: const OutlineInputBorder(),
    focusedBorder: const OutlineInputBorder(
      borderSide: BorderSide(color: Colors.blue, width: 2),
    ),
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(
        color: Colors.grey.shade400,
        width: 1,
      ),
    ),
  ),
),

const SizedBox(height: 16),

TextField(
  controller: descController,
  textAlign: isEnglish ? TextAlign.left : TextAlign.right,
  decoration: InputDecoration(
    label: Align(
      alignment:
          isEnglish ? Alignment.centerLeft : Alignment.centerRight,
      child: Text(
        Lang.t('description'),
      ),
    ),
    border: const OutlineInputBorder(),
    focusedBorder: const OutlineInputBorder(
      borderSide: BorderSide(color: Colors.blue, width: 2),
    ),
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(
        color: Colors.grey.shade400,
        width: 1,
      ),
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
              child: Text(
                Lang.t('cancel'), // 🔹 چندزبانه
                style: const TextStyle(
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
                  : Text(
                      Lang.t('update'), // 🔹 چندزبانه
                      style: const TextStyle(
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