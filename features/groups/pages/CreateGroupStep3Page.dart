import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CreateGroupStep3Page extends StatelessWidget {
  final String groupName;
  final String groupDescription;
  final List<String> devices;

  const CreateGroupStep3Page({
    super.key,
    required this.groupName,
    required this.groupDescription,
    required this.devices,
  });

  @override
  Widget build(BuildContext context) {
    final members = <String>[
      "کاربر ۱",
      "کاربر ۲",
      "کاربر ۳",
    ].obs;

    final selectedMembers = <String>[].obs;

    return Scaffold(
      appBar: AppBar(title: const Text("ایجاد گروه - مرحله ۳")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text("اعضای گروه را انتخاب کنید:"),
            const SizedBox(height: 16),
            Expanded(
              child: Obx(
                () => ListView.builder(
                  itemCount: members.length,
                  itemBuilder: (context, index) {
                    final member = members[index];
                    final isSelected = selectedMembers.contains(member);

                    return ListTile(
                      title: Text(member),
                      trailing: Checkbox(
                        value: isSelected,
                        onChanged: (val) {
                          if (val == true) {
                            selectedMembers.add(member);
                          } else {
                            selectedMembers.remove(member);
                          }
                        },
                      ),
                    );
                  },
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () => Get.back(),
                  child: const Text("قبلی"),
                ),
                TextButton(
                  onPressed: () => Get.back(),
                  child: const Text("انصراف"),
                ),
                ElevatedButton(
                  onPressed: () {
                    // ثبت گروه و اعضا
                    Get.snackbar("موفقیت", "گروه $groupName با موفقیت ایجاد شد");
                    Get.back(); // برگشت به صفحه گروه‌ها
                  },
                  child: const Text("ثبت"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
