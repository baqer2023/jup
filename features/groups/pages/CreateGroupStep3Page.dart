import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_app32/features/groups/controllers/group_controller.dart';
import 'package:my_app32/features/groups/pages/group_page.dart';
import 'package:my_app32/core/lang/lang.dart';

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
    controller.fetchGroupUsers(widget.groupId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(Lang.t('create_group_step_3'))), // 🔹 چندزبانه
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                Lang.t('group_customers_list'), // 🔹 چندزبانه
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              Expanded(
                child: Obx(() {
                  if (controller.groupUsers.isEmpty) {
                    return Center(
                      child: Text(Lang.t('no_customers_registered')), // 🔹 چندزبانه
                    );
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

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
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
                        Get.offAll(() => GroupsPage());
                        final controller = Get.find<HomeControllerGroup>();
                        controller.fetchGroups();
                      },
                      child: Text(
                        Lang.t('cancel'), // 🔹 چندزبانه
                        style: const TextStyle(
                          color: Color(0xFFF39530),
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(
                    height: 44,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        _showAddCustomerDialog(context, controller);
                      },
                      icon: const Icon(Icons.person_add, color: Colors.white),
                      label: Text(
                        Lang.t('add_new_customer'), // 🔹 چندزبانه
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
              ),
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
            child: Text(
              Lang.t('add_new_customer'), // 🔹 چندزبانه
              style: const TextStyle(
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
                        child: Text(Lang.t('first_name')), // 🔹 چندزبانه
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
                        child: Text(Lang.t('last_name')), // 🔹 چندزبانه
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
                        child: Text(Lang.t('phone_number_with_98')), // 🔹 چندزبانه
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
                              child: Text(Lang.t('verification_code')), // 🔹 چندزبانه
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
                        child: Text(Lang.t('send_code')), // 🔹 چندزبانه
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
                    child: Text(
                      Lang.t('cancel'), // 🔹 چندزبانه
                      style: const TextStyle(
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
                        Get.snackbar(
                          Lang.t('success'), // 🔹 چندزبانه
                          Lang.t('new_customer_registered'), // 🔹 چندزبانه
                        );
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
                    child: Text(
                      Lang.t('submit'), // 🔹 چندزبانه
                      style: const TextStyle(
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