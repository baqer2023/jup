import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_app32/features/groups/controllers/group_controller.dart';

class CreateGroupStep3Page extends StatefulWidget {
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
  State<CreateGroupStep3Page> createState() => _CreateGroupStep3PageState();
}

class _CreateGroupStep3PageState extends State<CreateGroupStep3Page> {
  late final HomeControllerGroup controller;

  @override
  void initState() {
    super.initState();
    controller = Get.find<HomeControllerGroup>();
    // گرفتن لیست کاربرهای گروه
    controller.fetchGroupUsers(widget.groupId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("ایجاد گروه - مرحله ۳")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("لیست مشتریان گروه", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),

            // لیست کاربران
            Expanded(
              child: Obx(() {
                if (controller.groupUsers.isEmpty) {
                  return const Center(child: Text("هیچ مشتری‌ای برای این گروه ثبت نشده"));
                }
                return ListView.builder(
                  itemCount: controller.groupUsers.length,
                  itemBuilder: (context, index) {
                    final user = controller.groupUsers[index];
                    return Card(
                      child: ListTile(
                        leading: const Icon(Icons.person),
                        title: Text("${user['firstName']} ${user['lastName']}"),
                        subtitle: Text(user['phoneNumber']),
                      ),
                    );
                  },
                );
              }),
            ),

            const SizedBox(height: 16),

            // دکمه افزودن مشتری
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
                customerId: widget.groupId,
                firstName: firstNameCtrl.text.trim(),
                lastName: lastNameCtrl.text.trim(),
                phoneNumber: phoneCtrl.text.trim(),
                verificationCode: codeCtrl.text.trim(),
              );

              if (success) {
                Get.back();
                Get.snackbar("موفقیت", "مشتری جدید ثبت شد");
                // دوباره لیست مشتری‌ها رو لود کن
                controller.fetchGroupUsers(widget.groupId);
              }
            },
            child: const Text("ثبت"),
          ),
        ],
      ),
    );
  }
}
