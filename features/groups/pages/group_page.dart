import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:my_app32/features/groups/pages/CreateGroupStep1Page.dart';
import '../controllers/group_controller.dart';

class GroupsPage extends StatelessWidget {
  const GroupsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // کنترلر را بارگذاری می‌کنیم
    final HomeControllerGroup controller = Get.put(HomeControllerGroup(Get.find()));

    // اطمینان از اینکه fetchGroups پس از بارگذاری توکن اجرا شود
    if (controller.groups.isEmpty && !controller.isLoading.value) {
      controller.initializeTokenGroup().then((_) => controller.fetchGroups());
    }

    return Scaffold(
      appBar: AppBar(title: const Text("گروه‌ها")),
      body: Obx(() {
        // حالت loading
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        // وقتی هیچ گروهی وجود ندارد
        if (controller.groups.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    height: 180,
                    child: SvgPicture.asset('assets/svg/NGroupF.svg', fit: BoxFit.fill),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "تا کنون گروهی ایجاد نشده‌است، جهت ایجاد گروه جدید روی دکمه زیر کلیک کنید",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Get.to(() => const CreateGroupStep1Page());
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                      textStyle: const TextStyle(fontSize: 16),
                    ),
                    child: const Text("ایجاد گروه جدید"),
                  ),
                ],
              ),
            ),
          );
        }

        // نمایش لیست گروه‌ها اگر موجود باشند
        return ListView.builder(
          itemCount: controller.groups.length,
          itemBuilder: (context, index) {
            final group = controller.groups[index];
            return ListTile(
              title: Text(group['title'] ?? 'بدون عنوان'),
              onTap: () {
                // می‌توان به صفحه جزئیات گروه رفت
              },
            );
          },
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.to(() => const CreateGroupStep1Page());
        },
        child: const Icon(Icons.add),
        tooltip: "ایجاد گروه جدید",
      ),
    );
  }
}
