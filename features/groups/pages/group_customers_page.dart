import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:my_app32/features/groups/controllers/group_controller.dart';

class GroupCustomersPage extends StatefulWidget {
  final String groupId;
  final String groupName;
  final String groupDescription;

  const GroupCustomersPage({
    super.key,
    required this.groupId,
    required this.groupName,
    required this.groupDescription,
  });

  @override
  State<GroupCustomersPage> createState() => _GroupCustomersPageState();
}

class _GroupCustomersPageState extends State<GroupCustomersPage> {
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
      appBar: AppBar(title: Text("مشتریان گروه: ${widget.groupName}")),
      body: Stack(
        children: [
          Column(
            children: [
              const SizedBox(height: 8),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  "لیست مشتریان گروه",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.right,
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Obx(() {
                  if (controller.groupUsers.isEmpty) {
                    return const Center(
                      child: Text("هیچ مشتری‌ای برای این گروه ثبت نشده"),
                    );
                  }

                  return SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 16,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: controller.groupUsers.map((user) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: CustomerCard(
                            user: user,
                            groupId: widget.groupId,
                            onDeleted: () {
                              final id = user['id'] as String?;
                              if (id != null) {
                                controller.groupUsers.removeWhere(
                                  (u) => u['id'] == id,
                                );
                                setState(() {});
                              } else {
                                Get.snackbar(
                                  "خطا",
                                  "کاربر فاقد شناسه است و نمی‌تواند حذف شود",
                                  backgroundColor: Colors.red,
                                  colorText: Colors.white,
                                );
                              }
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 70),
            ],
          ),
          Positioned(
            bottom: 62,
            left: 0,
            right: 0,
            child: Center(
              child: SizedBox(
                width: 200,
                height: 45,
                child: ElevatedButton.icon(
                  icon: const Icon(
                    Icons.person_add,
                    color: Colors.white,
                    size: 20,
                  ),
                  label: const Text(
                    "افزودن مشتری جدید",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  onPressed: () => _showAddCustomerDialog(context, controller),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddCustomerDialog(
    BuildContext context,
    HomeControllerGroup controller,
  ) {
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
                  _buildTextField(firstNameCtrl, "نام"),
                  const SizedBox(height: 12),
                  _buildTextField(lastNameCtrl, "نام خانوادگی"),
                  const SizedBox(height: 12),
                  _buildTextField(
                    phoneCtrl,
                    "شماره موبایل (با 98 یا 0)",
                    TextInputType.phone,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: _buildTextField(codeCtrl, "کد تایید")),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () async {
                          final phone = phoneCtrl.text.trim();
                          if (phone.isNotEmpty)
                            await controller.sendVerificationCode(phone);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
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
          actionsPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
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

  Widget _buildTextField(
    TextEditingController controller,
    String label, [
    TextInputType keyboardType = TextInputType.text,
  ]) {
    return TextField(
      controller: controller,
      textAlign: TextAlign.right,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        label: Align(alignment: Alignment.centerRight, child: Text(label)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 10,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.blue, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade400, width: 1),
        ),
      ),
    );
  }
}

class CustomerCard extends StatefulWidget {
  final Map<String, dynamic> user;
  final String groupId;
  final VoidCallback onDeleted;

  const CustomerCard({
    super.key,
    required this.user,
    required this.groupId,
    required this.onDeleted,
  });

  @override
  State<CustomerCard> createState() => _CustomerCardState();
}

class _CustomerCardState extends State<CustomerCard> {
  bool isActive = true;
  bool isLoading = false;

Future<void> _removeCustomer() async {
  // Step 1: check if user ID exists
  final customerId = widget.user['id'];
  if (customerId == null || customerId.isEmpty) {
    Get.snackbar(
      "خطا",
      "کاربر فاقد شناسه است و نمی‌تواند حذف شود",
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
    return;
  }

  // Step 2: confirm deletion with styled dialog
  final confirm = await showDialog<bool>(
    context: context,
    builder: (ctx) {
      return AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        titlePadding: const EdgeInsets.all(0),
        title: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            border: Border.all(color: Colors.blue, width: 2),
          ),
          child: const Center(
            child: Text(
              'حذف مشتری از گروه',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.white,
              ),
            ),
          ),
        ),
        content: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          child: Text(
            'آیا از حذف این مشتری از گروه اطمینان دارید؟',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: Colors.black87,
              height: 1.5,
            ),
          ),
        ),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        actions: [
          Align(
            alignment: Alignment.centerLeft,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // دکمه انصراف
                SizedBox(
                  width: 100,
                  height: 44,
                  child: TextButton(
                    onPressed: () => Navigator.of(ctx).pop(false),
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFFF39530),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: const BorderSide(color: Color(0xFFF39530), width: 2),
                      ),
                    ),
                    child: const Text(
                      "انصراف",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // دکمه حذف
                SizedBox(
                  width: 100,
                  height: 44,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(ctx).pop(true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 2,
                    ),
                    child: const Text(
                      'حذف',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    },
  );

  if (confirm != true) return;

  // Step 3: call removeCustomerFromGroup safely
  setState(() => isLoading = true);
  final controller = Get.find<HomeControllerGroup>();
  final success = await controller.removeCustomerFromGroup(customerId, widget.groupId);
  if (!mounted) return;
  setState(() => isLoading = false);

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        success
            ? '✅ مشتری با موفقیت از گروه حذف شد'
            : '❌ خطا در حذف مشتری از گروه',
      ),
      backgroundColor: success ? Colors.green : Colors.red,
    ),
  );

  if (success) widget.onDeleted();
}


  @override
  Widget build(BuildContext context) {
    final borderColor = isActive ? Colors.blue.shade400 : Colors.grey.shade400;
    final double circleSize = 50;

    return Center(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Card(
            color: Colors.white,
            elevation: 5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: borderColor, width: 2.5),
            ),
            child: Padding(
              padding: EdgeInsets.fromLTRB(16, circleSize / 2, 16, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Switch(
                        value: isActive,
                        activeColor: Colors.blue,
                        onChanged: (val) => setState(() => isActive = val),
                      ),
                      const SizedBox(),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        "${widget.user['firstName'] ?? ''} ${widget.user['lastName'] ?? ''}",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.right,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        widget.user['phoneNumber'] ?? "",
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.bottomLeft,
                    child: PopupMenuButton<int>(
                      color: Colors.white,
                      icon: const Icon(Icons.more_vert, color: Colors.black54),
                      onSelected: (value) {
                        if (value == 0) _removeCustomer();
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem<int>(
                          value: 0,
                          child: Row(
                            textDirection: TextDirection.rtl,
                            children: const [
                              Icon(Icons.delete, color: Colors.red),
                              SizedBox(width: 8),
                              Text(
                                'حذف مشتری از گروه',
                                style: TextStyle(color: Colors.red),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: -circleSize / 3,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: circleSize,
                height: circleSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: borderColor, width: 3),
                ),
                child: SvgPicture.asset(
                  isActive
                      ? 'assets/svg/user_on.svg'
                      : 'assets/svg/user_off.svg',
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          if (isLoading)
            Positioned.fill(
              child: Container(
                color: Colors.black26,
                child: const Center(child: CircularProgressIndicator()),
              ),
            ),
        ],
      ),
    );
  }
}
