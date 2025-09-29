import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_app32/features/groups/pages/CreateGroupStep2Page.dart';
import 'package:my_app32/features/groups/controllers/group_controller.dart';
import 'package:my_app32/features/groups/pages/group_page.dart';
import '../../widgets/custom_appbar.dart';
import '../../widgets/sidebar.dart';

class CreateGroupStep1Page extends StatefulWidget {
  const CreateGroupStep1Page({super.key});

  @override
  State<CreateGroupStep1Page> createState() => _CreateGroupStep1PageState();
}

class _CreateGroupStep1PageState extends State<CreateGroupStep1Page> {
  final nameController = TextEditingController();
  final descController = TextEditingController();
  final HomeControllerGroup controller = Get.put(HomeControllerGroup(Get.find()));

  bool isSubmitting = false;
  String? savedId;

  Future<void> handleSave() async {
    setState(() => isSubmitting = true);

    final id = await controller.saveGroup(
      nameController.text,
      descController.text,
    );

    if (id != null) {
      setState(() {
        savedId = id;
      });
    }

    setState(() => isSubmitting = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      endDrawer: const Sidebar(),
      appBar: CustomAppBar(isRefreshing: controller.isRefreshing),
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
                Align(
  alignment: Alignment.bottomLeft, // پایین سمت چپ
  child: Padding(
    padding: const EdgeInsets.all(16.0),
    child: TextButton(
      style: TextButton.styleFrom(
        backgroundColor: Colors.white, // بک‌گراند سفید
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      onPressed: () {
        // وقتی زد انصراف، برگرد به GroupsPage و همه گروه‌ها رو دوباره لود کن
        Get.offAll(() => GroupsPage());
        final controller = Get.find<HomeControllerGroup>();
        controller.fetchGroups(); // داده‌ها رو دوباره لود کن
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
  ),
),

                if (savedId == null)
                  ElevatedButton(
  onPressed: isSubmitting ? null : handleSave,
  style: ElevatedButton.styleFrom(
    backgroundColor: Colors.blue, // ✅ بک‌گراند آبی
    foregroundColor: Colors.white, // ✅ متن و آیکن سفید
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8), // گوشه‌های کمی گرد
    ),
  ),
  child: isSubmitting
      ? const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Colors.white, // ✅ لودینگ هم سفید
          ),
        )
      : const Text("ثبت"),
),

                if (savedId != null)
                  ElevatedButton(
  onPressed: () {
    Get.to(() => CreateGroupStep2Page(
          groupName: nameController.text,
          groupDescription: descController.text,
          groupId: extractCustomerId(savedId!), // پاس دادن آی‌دی
        ));
  },
  style: ElevatedButton.styleFrom(
    backgroundColor: Colors.blue, // ✅ پس‌زمینه آبی
    foregroundColor: Colors.white, // ✅ متن سفید
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
  ),
  child: const Text("بعدی"),
)
,
              ],
            ),
          ],
        ),
      ),
    );
  }
}

String extractCustomerId(String rawId) {
  final regex = RegExp(r'id:\s*([a-f0-9-]+)');
  final match = regex.firstMatch(rawId);
  if (match != null) return match.group(1)!;
  return rawId; // fallback
}
