import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_app32/features/groups/controllers/group_controller.dart';
import 'package:my_app32/features/groups/pages/group_page.dart';

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
// دکمه‌ها در پایین صفحه
Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: [
    // دکمه انصراف پایین سمت چپ
    TextButton(
      style: TextButton.styleFrom(
        backgroundColor: Colors.white, // بک‌گراند سفید
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      onPressed: () {
        // برگرد به GroupsPage و همه گروه‌ها را دوباره لود کن
        Get.offAll(() => GroupsPage());
        final controller = Get.find<HomeControllerGroup>();
        controller.fetchGroups();
      },
      child: const Text(
        "انصراف",
        style: TextStyle(
          color: Colors.yellow, // متن زرد
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    ),

    // دکمه افزودن مشتری جدید (همان دکمه قبلی شما)
    ElevatedButton.icon(
      onPressed: () {
        _showAddCustomerDialog(context, controller);
      },
      icon: const Icon(Icons.person_add, color: Colors.white),
      label: const Text(
        "افزودن مشتری جدید",
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
  ],
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
      backgroundColor: Colors.white, // رنگ بک‌گراند فرم‌ها سفید
      titlePadding: EdgeInsets.zero, // حذف padding پیش‌فرض برای سفارشی‌سازی هدر
      title: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        color: Colors.blue, // هدر آبی
        child: const Text(
          "افزودن مشتری جدید",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          children: [
            TextField(
              controller: firstNameCtrl,
              decoration: const InputDecoration(
                labelText: "نام",
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            TextField(
              controller: lastNameCtrl,
              decoration: const InputDecoration(
                labelText: "نام خانوادگی",
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            TextField(
              controller: phoneCtrl,
              decoration: const InputDecoration(
                labelText: "شماره موبایل (با 98 یا 0)",
                filled: true,
                fillColor: Colors.white,
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: codeCtrl,
                    decoration: const InputDecoration(
                      labelText: "کد تایید",
                      filled: true,
                      fillColor: Colors.white,
                    ),
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
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue, // پس‌زمینه آبی
                    foregroundColor: Colors.white, // متن سفید
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  child: const Text("ارسال کد"),
                ),
              ],
            ),
          ],
        ),
      ),
      actionsAlignment: MainAxisAlignment.center, // وسط چین کردن دکمه‌ها
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          style: TextButton.styleFrom(
            backgroundColor: Colors.yellow, // پس‌زمینه زرد
            foregroundColor: Colors.black, // متن مشکی
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
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
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue, // پس‌زمینه آبی
            foregroundColor: Colors.white, // متن سفید
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text("ثبت"),
        ),
      ],
    ),
  );
}

}
