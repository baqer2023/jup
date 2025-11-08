import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:my_app32/app/theme/app_colors.dart';
import 'package:my_app32/app/core/base/base_view.dart';
import 'package:my_app32/features/login/pages/otp/otp_controller.dart';
import 'package:my_app32/features/widgets/outline_button_widget.dart';
import 'package:my_app32/features/widgets/text_form_field_widget.dart';
import 'package:url_launcher/url_launcher.dart';

class OtpPage extends BaseView<OtpController> {
  const OtpPage({super.key});

  // تابعی برای باز کردن لینک
  Future<void> _launchURL() async {
    final Uri url = Uri.parse('https://jupiniot.ir/home');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw 'Could not launch $url';
    }
  }
  @override
  Widget body() {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // 🔹 هدر با لوگو
              SizedBox(
                width: double.infinity,
                child: Column(
                  children: [
                    Container(
                      height: 120,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF007DC0), Color(0xFF00B8E7)],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                      child: Center(
                        child: SvgPicture.asset(
                          'assets/svg/Login.svg',
                          width: 120,
                          height: 80,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 60,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          SvgPicture.asset('assets/svg/logo1.svg',
                              fit: BoxFit.fill),
                          SvgPicture.asset('assets/svg/logo2.svg',
                              fit: BoxFit.fill),
                          SvgPicture.asset('assets/svg/logo3.svg',
                              fit: BoxFit.fill),
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
                        'کد تأیید را وارد کنید',
                        style: const TextStyle(
                          fontFamily: 'IranYekan',
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    Center(
                      child: RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          style: const TextStyle(
                            fontFamily: 'IranYekan',
                            fontSize: 16,
                            color: Colors.black,
                          ),
                          children: [
                            const TextSpan(text: 'کد ارسال‌شده به شماره '),
                            TextSpan(
                              text: controller.phoneNumber,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // 🔹 فیلد ورود کد تأیید
                          Expanded(
                            flex: 3,
                            child: TextFormFieldWidget(
                              controller: controller.verifyCodeTEC,
                              keyboardType: TextInputType.number,
                              maxLength: 5,
                              onChanged: (value) =>
                                  controller.onChangeOTPCode(value: value),
                              label: const Text(
                                'کد تأیید',
                                style: TextStyle(fontFamily: 'IranYekan'),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),

                          // 🔹 دکمه ارسال مجدد
                          Expanded(
                            flex: 1,
                            child: Obx(
                              () => OutlineButtonWidget(
                                onTap: controller.resendOTPEnable.value
                                    ? () => controller.onTapResendOTPButton()
                                    : null,
                                color: controller.resendOTPEnable.value
                                    ? AppColors.primaryColor
                                    : AppColors.gray[400]!,
                                child: controller.resendOTPEnable.value
                                    ? const Text(
                                        'ارسال مجدد',
                                        style: TextStyle(
                                          fontFamily: 'IranYekan',
                                          fontSize: 14,
                                          color: AppColors.primaryColor,
                                        ),
                                      )
                                    : Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            controller.timerText.value,
                                            style: const TextStyle(
                                              fontFamily: 'IranYekan',
                                              fontSize: 14,
                                              color: Colors.grey,
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          SvgPicture.asset(
                                            'assets/svg/ic_timer.svg',
                                            width: 20,
                                            height: 20,
                                            color: AppColors.gray[600],
                                          ),
                                        ],
                                      ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 48),

                    // 🔹 دکمه تأیید
                    Obx(
                      () => ElevatedButton(
                        onPressed: controller.isVerifyOtp.value &&
                                !controller.isLoadingConfirmCode.value
                            ? () => controller.onTapVerifyCodeButton()
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
                        child: controller.isLoadingConfirmCode.value
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'ورود',
                                style: TextStyle(
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
                        const Text(
                          'شماره اشتباه است؟',
                          style: TextStyle(
                              fontFamily: 'IranYekan', fontSize: 14),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () => controller.onTapEditButton(),
                          child: const Text(
                            'ویرایش شماره',
                            style: TextStyle(
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

        // 🔹 سه بخش پایین با آیکون سمت راست متن و "|" زیر دکمه ورود
        bottomNavigationBar: SafeArea(
          minimum: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),

              // سه بخش پایین
              Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // بخش اول
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SvgPicture.asset(
                            'assets/svg/Social Media-Icon.svg',
                            width: 18,
                            height: 18,
                          ),
                          const SizedBox(width: 4),
                          const Text(
                            textDirection: TextDirection.ltr,
                            '۰۹۰۲ ۲۱۱ ۸۱ ۰۷',
                            style: TextStyle(
                              fontFamily: 'IranYekan',
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const Text('|',
                        style: TextStyle(fontSize: 14, color: Colors.grey)),
                    const SizedBox(width: 8),

                    // بخش دوم
                    Expanded(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            'assets/svg/Social Media-Icon(1).svg',
            width: 18,
            height: 18,
          ),
          const SizedBox(width: 4),
          InkWell(
            onTap: _launchURL,
            child: const Text(
              'jupinshop.ir',
              style: TextStyle(
                fontFamily: 'IranYekan',
                fontSize: 10,
                color: Colors.blue, // رنگ آبی برای حالت لینک
                decoration: TextDecoration.underline, // خط زیر برای شبیه لینک
              ),
            ),
          ),
        ],
      ),
    ),

                    const Text('|',
                        style: TextStyle(fontSize: 14, color: Colors.grey)),
                    const SizedBox(width: 8),

                    // بخش سوم
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SvgPicture.asset(
                            'assets/svg/Social Media-Icon(2).svg',
                            width: 18,
                            height: 18,
                          ),
                          const SizedBox(width: 4),
                          const Text(
                            textDirection: TextDirection.ltr,
                            '۰۲۱  ۸۲ ۸۰ ۴۲ ۵۹',
                            style: TextStyle(
                              fontFamily: 'IranYekan',
                              fontSize: 10,
                            ),
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
    );
  }
}
