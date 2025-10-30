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
      body: SafeArea(
  child: Padding(
    padding: const EdgeInsets.fromLTRB(16, 16, 16, 24), // 🔹 پایینش کمی فاصله بیشتر داره
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
    SizedBox(
      width: 100,
      height: 44,
      child: TextButton(
        style: TextButton.styleFrom(
          backgroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: const BorderSide(
              color: Color(0xFFF39530),
              width: 2,
            ),
          ),
        ),
        onPressed: () {
          // برگرد به GroupsPage و دوباره گروه‌ها را لود کن
          Get.offAll(() => GroupsPage());
          final controller = Get.find<HomeControllerGroup>();
          controller.fetchGroups();
        },
        child: const Text(
          "انصراف",
          style: TextStyle(
            color: Color(0xFFF39530),
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    ),

    // دکمه افزودن مشتری جدید
    SizedBox(
      height: 44,
      child: ElevatedButton.icon(
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
    ),
  ],
)
,

          ],
        ),
      ),
    ),
    );
  }
void _showAddCustomerDialog(BuildContext context, HomeControllerGroup controller) {
  final firstNameCtrl = TextEditingController();
  final lastNameCtrl = TextEditingController();
  final phoneCtrl = TextEditingController(text: "98");
  final codeCtrl = TextEditingController();

  showDialog(
    context: context,
    builder: (ctx) {
      return AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 10,
        titlePadding: EdgeInsets.zero,
        title: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: const BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: const Text(
            "افزودن مشتری جدید",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: 18,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        content: SingleChildScrollView(
          child: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: firstNameCtrl,
                  textAlign: TextAlign.right,
                  decoration: InputDecoration(
                    label: Align(
                      alignment: Alignment.centerRight,
                      child: const Text('نام'),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.blue, width: 2),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade400, width: 1),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: lastNameCtrl,
                  textAlign: TextAlign.right,
                  decoration: InputDecoration(
                    label: Align(
                      alignment: Alignment.centerRight,
                      child: const Text('نام خانوادگی'),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.blue, width: 2),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade400, width: 1),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: phoneCtrl,
                  textAlign: TextAlign.right,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    label: Align(
                      alignment: Alignment.centerRight,
                      child: const Text('شماره موبایل (با 98 یا 0)'),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.blue, width: 2),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade400, width: 1),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: codeCtrl,
                        textAlign: TextAlign.right,
                        decoration: InputDecoration(
                          label: Align(
                            alignment: Alignment.centerRight,
                            child: const Text('کد تایید'),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.blue, width: 2),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade400, width: 1),
                          ),
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
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text("ارسال کد"),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        actionsAlignment: MainAxisAlignment.spaceBetween,
        actions: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 100,
                child: ElevatedButton(
                  onPressed: () => Get.back(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFFF39530),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(
                        color: Color(0xFFF39530),
                        width: 2,
                      ),
                    ),
                  ),
                  child: const Text(
                    'انصراف',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 4),
              SizedBox(
                width: 100,
                child: ElevatedButton(
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
                      controller.fetchGroupUsers(widget.groupId);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'ثبت',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      );
    },
  );
}


}
