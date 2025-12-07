import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:my_app32/features/groups/controllers/group_controller.dart';
import 'package:my_app32/core/lang/lang.dart';

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
      appBar: AppBar(title: Text("${Lang.t('group_customers')}: ${widget.groupName}")), // 🔹 چندزبانه
      body: Stack(
        children: [
          Column(
            children: [
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  Lang.t('group_customers_list'), // 🔹 چندزبانه
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.right,
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Obx(() {
                  if (controller.groupUsers.isEmpty) {
                    return Center(
                      child: Text(Lang.t('no_customers_registered')), // 🔹 چندزبانه
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
                                  Lang.t('error'), // 🔹 چندزبانه
                                  Lang.t('customer_no_id_error'), // 🔹 چندزبانه
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
                  label: Text(
                    Lang.t('add_new_customer'), // 🔹 چندزبانه
                    style: const TextStyle(
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
                  _buildTextField(firstNameCtrl, Lang.t('first_name')), // 🔹 چندزبانه
                  const SizedBox(height: 12),
                  _buildTextField(lastNameCtrl, Lang.t('last_name')), // 🔹 چندزبانه
                  const SizedBox(height: 12),
                  _buildTextField(
                    phoneCtrl,
                    Lang.t('phone_number_with_98'), // 🔹 چندزبانه
                    TextInputType.phone,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: _buildTextField(codeCtrl, Lang.t('verification_code'))), // 🔹 چندزبانه
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
                        child: Text(Lang.t('send_code')), // 🔹 چندزبانه
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
                        Get.snackbar(Lang.t('success'), Lang.t('new_customer_registered')); // 🔹 چندزبانه
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
  final customerId = widget.user['id'];
  if (customerId == null || customerId.isEmpty) {
    Get.snackbar(
      Lang.t('error'), // 🔹 چندزبانه
      Lang.t('customer_no_id_error'), // 🔹 چندزبانه
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
    return;
  }

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
          child: Center(
            child: Text(
              Lang.t('remove_customer_from_group'), // 🔹 چندزبانه
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.white,
              ),
            ),
          ),
        ),
        content: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          child: Text(
            Lang.t('confirm_remove_customer_from_group'), // 🔹 چندزبانه
            textAlign: TextAlign.center,
            style: const TextStyle(
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
                    child: Text(
                      Lang.t('cancel'), // 🔹 چندزبانه
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
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
                    child: Text(
                      Lang.t('delete'), // 🔹 چندزبانه
                      style: const TextStyle(
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

  setState(() => isLoading = true);
  final controller = Get.find<HomeControllerGroup>();
  final success = await controller.removeCustomerFromGroup(customerId, widget.groupId);
  if (!mounted) return;
  setState(() => isLoading = false);

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        success
            ? Lang.t('customer_removed_from_group_success') // 🔹 چندزبانه
            : Lang.t('customer_remove_from_group_error'), // 🔹 چندزبانه
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
                            children: [
                              const Icon(Icons.delete, color: Colors.red),
                              const SizedBox(width: 8),
                              Text(
                                Lang.t('remove_customer_from_group'), // 🔹 چندزبانه
                                style: const TextStyle(color: Colors.red),
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