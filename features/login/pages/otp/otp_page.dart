import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:my_app32/app/theme/app_colors.dart';
import 'package:my_app32/app/core/base/base_view.dart';
import 'package:my_app32/features/login/pages/otp/otp_controller.dart';
import 'package:my_app32/features/widgets/outline_button_widget.dart';
import 'package:my_app32/features/widgets/text_form_field_widget.dart';

class OtpPage extends BaseView<OtpController> {
  const OtpPage({super.key});

  @override
  Widget body() {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // لوگوی سایت و سه SVG پایین آن
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
                      'otp_title'.tr,
                      style: const TextStyle(
                        fontFamily: 'IranYekan',
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: const TextStyle(
                        fontFamily: 'IranYekan',
                        fontSize: 16,
                        color: Colors.black,
                      ),
                      children: [
                        TextSpan(text: 'otp_description'.tr),
                        TextSpan(
                          text: ' ${controller.phoneNumber} ',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: TextFormFieldWidget(
                          controller: controller.verifyCodeTEC,
                          keyboardType: TextInputType.number,
                          maxLength: 5,
                          onChanged: (value) => controller.onChangeOTPCode(value: value),
                          label: Text(
                            'otp_textField_hint'.tr,
                            style: const TextStyle(fontFamily: 'IranYekan'),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 1,
                        child: SizedBox(
                          height: 56,
                          child: OutlineButtonWidget(
                            onTap: () => controller.onTapResendOTPButton(),
                            color: controller.resendOTPEnable.value
                                ? AppColors.primaryColor
                                : AppColors.gray[400]!,
                            child: Obx(
                              () => controller.resendOTPEnable.value
                                  ? Text(
                                      'otp_send_sms'.tr,
                                      style: const TextStyle(
                                        fontFamily: 'IranYekan',
                                        fontSize: 14,
                                        color: AppColors.primaryColor,
                                      ),
                                    )
                                  : Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          controller.timerText.value,
                                          style: const TextStyle(
                                            fontFamily: 'IranYekan',
                                            fontSize: 14,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        SvgPicture.asset(
                                          'assets/svg/ic_timer.svg',
                                          width: 24,
                                          height: 24,
                                          color: AppColors.gray[600],
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 48),
                  Obx(
                    () => ElevatedButton(
                      onPressed: controller.isVerifyOtp.value && !controller.isLoadingConfirmCode.value
                          ? () => controller.onTapVerifyCodeButton()
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        disabledBackgroundColor: AppColors.primaryColor.withOpacity(0.3),
                        minimumSize: Size(Get.width, 48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: controller.isLoadingConfirmCode.value
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              'ورود',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontFamily: 'IranYekan',
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'otp_description_wrong_number'.tr,
                        style: const TextStyle(
                          fontFamily: 'IranYekan',
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () => controller.onTapEditButton(),
                        child: Text(
                          'otp_number_edit'.tr,
                          style: const TextStyle(
                            fontFamily: 'IranYekan',
                            fontSize: 14,
                            color: AppColors.backgroundBottomNavColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
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
