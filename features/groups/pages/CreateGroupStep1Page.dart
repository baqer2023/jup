import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_app32/features/groups/pages/CreateGroupStep2Page.dart';
import 'package:my_app32/features/groups/controllers/group_controller.dart';

class CreateGroupStep1Page extends StatefulWidget {
  const CreateGroupStep1Page({super.key});

  @override
  State<CreateGroupStep1Page> createState() => _CreateGroupStep1PageState();
}

class _CreateGroupStep1PageState extends State<CreateGroupStep1Page> {
  final nameController = TextEditingController();
  final descController = TextEditingController();
  final HomeControllerGroup controller = Get.put(HomeControllerGroup(Get.find()));

  bool isSubmitting = false;
  String? savedId;

  Future<void> handleSave() async {
    setState(() => isSubmitting = true);

    final id = await controller.saveGroup(
      nameController.text,
      descController.text,
    );

    if (id != null) {
      setState(() {
        savedId = id;
      });
    }

    setState(() => isSubmitting = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("ایجاد گروه - مرحله ۱")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(onPressed: () => Get.back(), child: const Text("انصراف")),
                if (savedId == null)
                  ElevatedButton(
                    onPressed: isSubmitting ? null : handleSave,
                    child: isSubmitting
                        ? const SizedBox(
                            width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Text("ثبت"),
                  ),
                if (savedId != null)
                  ElevatedButton(
                    onPressed: () {
                      Get.to(() => CreateGroupStep2Page(
                            groupName: nameController.text,
                            groupDescription: descController.text,
                            groupId: extractCustomerId(savedId!),// پاس دادن آی‌دی
                          ));
                    },
                    child: const Text("بعدی"),
                  ),
              ],
            )
          ],
        ),
      ),
    );
  }
}


String extractCustomerId(String rawId) {
  final regex = RegExp(r'id:\s*([a-f0-9-]+)');
  final match = regex.firstMatch(rawId);
  if (match != null) return match.group(1)!;
  return rawId; // fallback
}

