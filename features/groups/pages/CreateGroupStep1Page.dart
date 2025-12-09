import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_app32/features/groups/pages/CreateGroupStep2Page.dart';
import 'package:my_app32/features/groups/controllers/group_controller.dart';
import 'package:my_app32/features/groups/pages/group_page.dart';
import 'package:my_app32/core/lang/lang.dart';
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
   final isEnglish = Lang.current.value == 'en';

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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            children: [
TextField(
  controller: nameController,
  textAlign: isEnglish ? TextAlign.left : TextAlign.right,
  decoration: InputDecoration(
    label: Align(
      alignment:
          isEnglish ? Alignment.centerLeft : Alignment.centerRight,
      child: Text(
        Lang.t('group_name'),
      ),
    ),
    border: const OutlineInputBorder(),
    focusedBorder: const OutlineInputBorder(
      borderSide: BorderSide(color: Colors.blue, width: 2),
    ),
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(
        color: Colors.grey.shade400,
        width: 1,
      ),
    ),
  ),
),

              const SizedBox(height: 16),
TextField(
  controller: descController,
  textAlign: isEnglish ? TextAlign.left : TextAlign.right,
  decoration: InputDecoration(
    label: Align(
      alignment:
          isEnglish ? Alignment.centerLeft : Alignment.centerRight,
      child: Text(
        Lang.t('description'),
      ),
    ),
    border: const OutlineInputBorder(),
    focusedBorder: const OutlineInputBorder(
      borderSide: BorderSide(color: Colors.blue, width: 2),
    ),
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(
        color: Colors.grey.shade400,
        width: 1,
      ),
    ),
  ),
),

              const Spacer(),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Align(
                    alignment: Alignment.bottomLeft,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: SizedBox(
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
                            Lang.t('cancel'),
                            style: const TextStyle(
                              color: Color(0xFFF39530),
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  if (savedId == null)
                    SizedBox(
                      width: 100,
                      height: 44,
                      child: ElevatedButton(
                        onPressed: isSubmitting ? null : handleSave,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: isSubmitting
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                Lang.t('save'),
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                      ),
                    ),

                  if (savedId != null)
                    SizedBox(
                      width: 100,
                      height: 44,
                      child: ElevatedButton(
                        onPressed: () {
                          Get.to(() => CreateGroupStep2Page(
                                groupName: nameController.text,
                                groupDescription: descController.text,
                                groupId: extractCustomerId(savedId!),
                              ));
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          Lang.t('next'),
                          style: const TextStyle(
                              fontWeight: FontWeight.bold),
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
}

String extractCustomerId(String rawId) {
  final regex = RegExp(r'id:\s*([a-f0-9-]+)');
  final match = regex.firstMatch(rawId);
  if (match != null) return match.group(1)!;
  return rawId;
}
