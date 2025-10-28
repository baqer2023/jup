import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';
import 'package:my_app32/app/theme/app_colors.dart';
import 'package:my_app32/features/login/pages/main/login_controller.dart';
import 'package:my_app32/app/core/base/base_view.dart';

class LoginPage extends BaseView<LoginController> {
  const LoginPage({super.key});

  @override
  Widget body() {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                // بخش لوگو با گرادینت
                SizedBox(
                  width: double.infinity,
                  height: 120,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF007DC0), Color(0xFF00B8E7)],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                      Center(
                        child: SvgPicture.asset(
                          'assets/svg/Login.svg',
                          width: 120,
                          height: 80,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ],
                  ),
                ),

                // سه SVG زیر لوگو
                SizedBox(
                  height: 60,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      SvgPicture.asset('assets/svg/1.svg', fit: BoxFit.fill),
                      SvgPicture.asset('assets/svg/2.svg', fit: BoxFit.fill),
                      SvgPicture.asset('assets/svg/3.svg', fit: BoxFit.fill),
                    ],
                  ),
                ),

                const SizedBox(height: 24),
                Center(
                  child: Text(
                    'login_title'.tr,
                    style: const TextStyle(
                      fontFamily: 'IranYekan',
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  'login_description'.tr,
                  style: const TextStyle(
                    fontFamily: 'IranYekan',
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 24),

                // فیلد شماره موبایل
                Obx(() {
                  final bool isValid = controller.isValid.value;
                  return TextField(
                    controller: controller.visiblePhoneTEC,
                    keyboardType: TextInputType.phone,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: InputDecoration(
                      labelText:
                          'شماره موبایل خود را وارد کنید (مثال: 09123334545)',
                      labelStyle: const TextStyle(
                          fontFamily: 'IranYekan', fontSize: 13),
                      hintText: '09123334545',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: isValid ? AppColors.gray[400]! : Colors.red,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: isValid ? AppColors.primaryColor : Colors.red,
                        ),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    onChanged: (value) {
                      controller.visiblePhoneTEC.value = TextEditingValue(
                        text: value,
                        selection: TextSelection.fromPosition(
                          TextPosition(offset: value.length),
                        ),
                      );
                      controller.userNameTEC.text = value;
                      controller.onTapCheckLoginOrSignup();
                    },
                  );
                }),

                const SizedBox(height: 80), // فاصله تا پایین
              ],
            ),
          ),
        ),

        // 🔹 دکمه ورود ثابت پایین صفحه
        bottomNavigationBar: SafeArea(
          minimum: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: Obx(
            () => ElevatedButton(
              onPressed: controller.isEnableConfirmButton.value &&
                      !controller.isLoading.value
                  ? () => controller.onTapLogin()
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                disabledBackgroundColor:
                    AppColors.primaryColor.withOpacity(0.3),
                minimumSize: Size(Get.width, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: controller.isLoading.value
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      'login_button'.tr,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontFamily: 'IranYekan',
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
