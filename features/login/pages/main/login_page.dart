import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';
import 'package:country_picker/country_picker.dart';
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
        resizeToAvoidBottomInset: false,
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 48),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // بخش لوگو با گرادینت و لوگوی وسط
              SizedBox(
                width: double.infinity,
                height: 120,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Color(0xFF007DC0),
                            Color(0xFF00B8E7),
                          ],
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
                    SvgPicture.asset(
                      'assets/svg/1.svg',
                      fit: BoxFit.fill,
                    ),
                    SvgPicture.asset(
                      'assets/svg/2.svg',
                      fit: BoxFit.fill,
                    ),
                    SvgPicture.asset(
                      'assets/svg/3.svg',
                      fit: BoxFit.fill,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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

                    // شماره تلفن سمت چپ و کد کشور سمت راست با قابلیت انتخاب
                    Obx(() => Row(
                          children: [
                            // شماره تلفن سمت چپ
Expanded(
  child: TextField(
    controller: controller.userNameTEC,
    keyboardType: TextInputType.phone,
    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
    decoration: InputDecoration(
      hintText: 'شماره تلفن',
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: AppColors.gray[400]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: AppColors.primaryColor),
      ),
      filled: true,
      fillColor: Colors.white,
    ),
    onChanged: (value) {
      String phone = value;

      // اگر کد کشور ایران انتخاب شده باشه و شماره با 0 شروع نشده
      if (controller.selectedCountryCode.value == '+98') {
        if (phone.startsWith('0')) {
          phone = phone.substring(1); // حذف صفر اول
        }
        // اضافه کردن صفر اول برای ارسال
        controller.userNameTEC.text = '0$phone';
      } else {
        // برای کشور دیگه بدون تغییر
        controller.userNameTEC.text = phone;
      }

      controller.onTapCheckLoginOrSignup();
      controller.userNameTEC.selection = TextSelection.fromPosition(
          TextPosition(offset: controller.userNameTEC.text.length));
    },
  ),
),

                            const SizedBox(width: 12),

                            // کد کشور سمت راست و قابل انتخاب
                            GestureDetector(
                              onTap: () {
                                showCountryPicker(
                                  context: Get.context!,
                                  showPhoneCode: true,
                                  countryListTheme: CountryListThemeData(
                                    backgroundColor: Colors.white,
                                    textStyle: const TextStyle(
                                        color: Colors.black, fontSize: 14),
                                    bottomSheetHeight: 400,
                                    inputDecoration: InputDecoration(
                                      labelText: 'جستجوی کشور',
                                      labelStyle: const TextStyle(
                                          color: Colors.black, fontSize: 14),
                                      border: OutlineInputBorder(
                                        borderSide:
                                            BorderSide(color: Colors.grey),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide:
                                            BorderSide(color: Colors.blue),
                                      ),
                                    ),
                                  ),
                                  onSelect: (Country country) {
                                    controller.selectedCountryCode.value =
                                        '+${country.phoneCode}';
                                  },
                                );
                              },
                              child: Container(
                                width: 80,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                      color: AppColors.gray[400]!),
                                ),
                                child: Center(
                                  child: Text(
                                    controller.selectedCountryCode.value,
                                    style: const TextStyle(
                                        fontFamily: 'IranYekan', fontSize: 14),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )),

                    const SizedBox(height: 24),
                    Obx(
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
                    const SizedBox(height: 50),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
