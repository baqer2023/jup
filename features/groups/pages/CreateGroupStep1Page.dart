import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_app32/features/groups/pages/CreateGroupStep2Page.dart';

class CreateGroupStep1Page extends StatelessWidget {
  const CreateGroupStep1Page({super.key});

  @override
  Widget build(BuildContext context) {
    final nameController = TextEditingController();
    final descController = TextEditingController();

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
                TextButton(
                  onPressed: () => Get.back(),
                  child: const Text("انصراف"),
                ),
                ElevatedButton(
                  onPressed: () {
                    Get.to(() => CreateGroupStep2Page(
                          groupName: nameController.text,
                          groupDescription: descController.text,
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
