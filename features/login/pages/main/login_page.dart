import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:flutter/services.dart';
import 'package:my_app32/app/theme/app_colors.dart';
import 'package:my_app32/features/login/pages/main/login_controller.dart';
import 'package:my_app32/features/widgets/fill_button_widget.dart';
import 'package:my_app32/features/widgets/text_form_field_widget.dart';
import 'package:my_app32/app/core/base/base_view.dart';

class LoginPage extends BaseView<LoginController> {
  const LoginPage({super.key});

  @override
  Widget body() {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Stack(
          children: [
            SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.only(bottom: 48),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  // لوگوی سایت و سه SVG زیر آن
                  SizedBox(
                    width: double.infinity,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SvgPicture.asset(
                          'assets/svg/Wrapper.svg',
                          fit: BoxFit.fill,
                          width: double.infinity,
                          height: 80,
                        ),
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
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.all(24),
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
                        IntlPhoneField(
                          controller: controller.userNameTEC,
                          decoration: InputDecoration(
                            labelText: 'login_phone_number_textField_label'.tr,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: AppColors.gray[400]!,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: AppColors.gray[400]!,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: AppColors.primaryColor,
                              ),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          dropdownIcon: const Icon(
                            Icons.arrow_drop_down,
                            color: Colors.blueAccent,
                          ),
                          initialCountryCode: 'IR',
                          onChanged: (phone) {
                            String number = phone.number;
                            if (number.startsWith('0')) number = number.substring(1);
                            if (!number.startsWith('9')) number = '9$number';
                            if (number.length > 10) number = number.substring(0, 10);
                            controller.userNameTEC.text = '0$number';
                            controller.onTapCheckLoginOrSignup();
                          },
                          keyboardType: TextInputType.phone,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          showDropdownIcon: false,
                          disableLengthCheck: true,
                        ),
                        const SizedBox(height: 24),
                        Obx(
                          () => ElevatedButton(
                            onPressed: controller.isEnableConfirmButton.value && !controller.isLoading.value
                                ? () => controller.onTapLogin()
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryColor,
                              disabledBackgroundColor: AppColors.primaryColor.withOpacity(0.3),
                              minimumSize: Size(Get.width, 48),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: controller.isLoading.value
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
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
          ],
        ),
      ),
    );
  }
}
