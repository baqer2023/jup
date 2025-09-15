import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_app32/app/routes/app_routes.dart';
import 'package:my_app32/app/theme/app_colors.dart';
// import 'package:my_app32/features/add_device/pages/add_device_page.dart';
import 'package:my_app32/features/main/repository/home_repository.dart';
import 'package:my_app32/features/main/pages/home/home_controller.dart';

class MainController extends GetxController {
  MainController(this._repo);

  final HomeRepository _repo;
  PageController pageController = PageController();
  RxInt bottomNavigatorIndex = 0.obs;
  RxBool isLoading = RxBool(true);

  final TextEditingController serialNumberController = TextEditingController();
  final TextEditingController labelController = TextEditingController();

  void _showAddDeviceDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AddDeviceDialog(),
    );
  }

  void onTapAddDevice() {
    showDialog(
      context: Get.context!,
      builder: (context) => AlertDialog(
        title: const Text('ثبت دستگاه جدید'),
        backgroundColor: Colors.white,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: serialNumberController,
              decoration: const InputDecoration(
                labelText: 'شماره سریال',
                hintText: 'مثال: 02T34389958',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: labelController,
              decoration: const InputDecoration(
                labelText: 'برچسب',
                hintText: 'مثال: mobile',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              serialNumberController.clear();
              labelController.clear();
            },
            child: const Text('لغو'),
          ),
          ElevatedButton(
            onPressed: () async {
              final serialNumber = serialNumberController.text.trim();
              final label = labelController.text.trim();

              if (serialNumber.isEmpty || label.isEmpty) {
                Get.snackbar(
                  'خطا',
                  'لطفاً شماره سریال و برچسب را وارد کنید',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                );
                return;
              }

              Navigator.pop(context);

              showDialog(
                context: Get.context!,
                barrierDismissible: false,
                builder: (context) =>
                    const Center(child: CircularProgressIndicator()),
              );

              try {
                final homeController = Get.find<HomeController>();
                // await homeController.registerDevice(serialNumber, label);
              } finally {
                Navigator.pop(Get.context!);
                serialNumberController.clear();
                labelController.clear();
              }
            },
            child: const Text('ثبت'),
          ),
        ],
      ),
    );
  }

  void showCustomModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'انتخاب نوع ثبت دستگاه',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        onTapAddDevice();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      icon: const Icon(Icons.add_circle_outline, size: 20),
                      label: const Text(
                        "ثبت دستگاه جدید",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        onTapAddDevice();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      icon: const Icon(Icons.wifi, size: 20),
                      label: const Text(
                        "ثبت دستگاه از وایفای",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  void onTapBack() {}

  void onTapLogOut() {
    Get.defaultDialog(
      title: "خروج",
      middleText: "آیا مطمئن هستید که می‌خواهید خارج شوید؟",
      textConfirm: "بله",
      textCancel: "خیر",
      confirmTextColor: Colors.white,
      backgroundColor: Colors.white,
      onConfirm: () {
        Get.offAllNamed(AppRoutes.LOGIN);
      },
      onCancel: () {},
    );
  }

  void onTapBottomNavigationItem({required int index}) {
    bottomNavigatorIndex(index);
    pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.linear,
    );
  }
}

class AddDeviceDialog extends StatefulWidget {
  const AddDeviceDialog({super.key});

  @override
  State<AddDeviceDialog> createState() => _AddDeviceDialogState();
}

class _AddDeviceDialogState extends State<AddDeviceDialog> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _serialNumberController = TextEditingController();
  final TextEditingController _labelController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _serialNumberController.dispose();
    _labelController.dispose();
    super.dispose();
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final homeController = Get.find<HomeController>();
        // await homeController.registerDevice(
        //   _serialNumberController.text.trim(),
        //   _labelController.text.trim(),
        // );

        Navigator.pop(context);
        Get.snackbar(
          'موفق',
          'دستگاه با موفقیت ثبت شد',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } catch (e) {
        Get.snackbar(
          'خطا',
          'خطا در ثبت دستگاه: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'اطلاعات دستگاه را وارد کنید',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E3A8A),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.grey[100],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _serialNumberController,
                  decoration: InputDecoration(
                    labelText: 'شماره سریال',
                    hintText: 'مثال: 02T34389958',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.device_hub),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'لطفاً شماره سریال را وارد کنید';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _labelController,
                  decoration: InputDecoration(
                    labelText: 'برچسب',
                    hintText: 'مثال: mobile',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.label),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'لطفاً برچسب را وارد کنید';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: const Text('لغو'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _submitForm,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : const Text(
                                  'ثبت دستگاه',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
