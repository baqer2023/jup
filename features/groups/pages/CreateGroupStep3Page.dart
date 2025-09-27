import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_app32/features/groups/controllers/group_controller.dart';

class CreateGroupStep3Page extends StatelessWidget {
  final String groupName;
  final String groupDescription;
  final String groupId;

  const CreateGroupStep3Page({
    super.key,
    required this.groupName,
    required this.groupDescription,
    required this.groupId,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeControllerGroup>();

    return Scaffold(
      appBar: AppBar(title: const Text("ایجاد گروه - مرحله ۳")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text("افزودن مشتری جدید به گروه"),
            const SizedBox(height: 16),

            ElevatedButton.icon(
              onPressed: () {
                _showAddCustomerDialog(context, controller);
              },
              icon: const Icon(Icons.person_add),
              label: const Text("افزودن مشتری جدید"),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddCustomerDialog(
      BuildContext context, HomeControllerGroup controller) {
    final firstNameCtrl = TextEditingController();
    final lastNameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController(text: "98");
    final codeCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("افزودن مشتری جدید"),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: firstNameCtrl,
                decoration: const InputDecoration(labelText: "نام"),
              ),
              TextField(
                controller: lastNameCtrl,
                decoration: const InputDecoration(labelText: "نام خانوادگی"),
              ),
              TextField(
                controller: phoneCtrl,
                decoration:
                    const InputDecoration(labelText: "شماره موبایل (با 98 یا 0)"),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: codeCtrl,
                      decoration: const InputDecoration(labelText: "کد تایید"),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () async {
                      final phone = phoneCtrl.text.trim();
                      if (phone.isNotEmpty) {
                        await controller.sendVerificationCode(phone);
                      }
                    },
                    child: const Text("ارسال کد"),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text("انصراف"),
          ),
          ElevatedButton(
            onPressed: () async {
              final success = await controller.addNewCustomer(
                customerId: groupId,
                firstName: firstNameCtrl.text.trim(),
                lastName: lastNameCtrl.text.trim(),
                phoneNumber: phoneCtrl.text.trim(),
                verificationCode: codeCtrl.text.trim(),
              );

              if (success) {
                Get.back(); // بستن مدال
                Get.snackbar("موفقیت", "مشتری جدید ثبت شد");
              }
            },
            child: const Text("ثبت"),
          ),
        ],
      ),
    );
  }
}
