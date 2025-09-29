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
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              "لیست مشتریان گروه",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            // const SizedBox(height: 16),

Expanded(
  child: Obx(() {
    if (controller.groupUsers.isEmpty) {
      return const Center(
        child: Text("هیچ مشتری‌ای برای این گروه ثبت نشده"),
      );
    }

    final double cardWidth = 300;
    final double cardHeight = 250;
    final double circleSize = 50;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.only(top: 50, right: 16), // فاصله از بالا و سمت راست
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end, // کارت‌ها سمت راست
          children: controller.groupUsers.map((user) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12), // فاصله بین کارت‌ها
              child: CustomerCard(
                user: user,
                cardWidth: cardWidth,
                cardHeight: cardHeight,
                circleSize: circleSize,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }),
),





            const SizedBox(height: 16),

            ElevatedButton.icon(
    onPressed: () {
      _showAddCustomerDialog(context, controller);
    },
    icon: const Icon(
      Icons.person_add,
      color: Colors.white, // آیکون سفید
    ),
    label: const Text(
      "افزودن مشتری جدید",
      style: TextStyle(
        color: Colors.white, // متن سفید
        fontWeight: FontWeight.bold,
      ),
    ),
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.blue, // بک‌گراند آبی
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),
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

class CustomerCard extends StatefulWidget {
  final Map<String, dynamic> user;
  final double cardWidth;
  final double cardHeight;
  final double circleSize;

  const CustomerCard({
    super.key,
    required this.user,
    required this.cardWidth,
    required this.cardHeight,
    required this.circleSize,
  });

  @override
  State<CustomerCard> createState() => _CustomerCardState();
}

class _CustomerCardState extends State<CustomerCard> {
  bool isActive = true;

  @override
  Widget build(BuildContext context) {
    final borderColor =
        isActive ? Colors.blue.shade400 : Colors.grey.shade400;

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
            child: Container(
              width: widget.cardWidth,
              height: widget.cardHeight,
              padding: EdgeInsets.fromLTRB(
                16,
                widget.circleSize / 1.2,
                16,
                16,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ردیف بالا: تاگل سمت چپ
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Switch(
                        value: isActive,
                        activeColor: Colors.blue,
                        onChanged: (val) {
                          setState(() => isActive = val);
                        },
                      ),
                      const SizedBox(),
                    ],
                  ),

                  // اطلاعات مشتری
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        "${widget.user['firstName']} ${widget.user['lastName']}",
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

                  const Spacer(),

                  // سه نقطه پایین سمت چپ
                  Align(
                    alignment: Alignment.bottomLeft,
                    child: IconButton(
                      icon: const Icon(Icons.more_vert),
                      onPressed: () {
                        // TODO: منوی عملیات مشتری
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          // آیکن گرد بالا
          Positioned(
            top: -widget.circleSize / 3,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: widget.circleSize,
                height: widget.circleSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: borderColor,
                    width: 3,
                  ),
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
        ],
      ),
    );
  }
}
