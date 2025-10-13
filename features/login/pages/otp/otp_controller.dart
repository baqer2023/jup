import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sms_autofill/sms_autofill.dart';
import 'package:my_app32/app/core/app_utils_mixin.dart';
import 'package:my_app32/app/models/response_model.dart';
import 'package:my_app32/app/routes/app_routes.dart';
import 'package:my_app32/app/store/user_store_service.dart';
import 'package:my_app32/features/login/models/otp_request_model.dart';
import 'package:my_app32/features/login/models/otp_response_model.dart';
import 'package:my_app32/features/login/models/signup_request_model.dart';
import 'package:my_app32/features/login/repository/login_repository.dart';
import 'package:my_app32/features/login/repository/otp_repository.dart';

class OtpController extends GetxController with AppUtilsMixin {
  OtpController(this._repo, this._loginRepo);

  final OtpRepository _repo;
  final LoginRepository _loginRepo;

  late final String phoneNumber;
  TextEditingController verifyCodeTEC = TextEditingController();

  RxBool isLoadingConfirmCode = false.obs;
  RxBool isLoadingResendCode = false.obs;
  RxBool isVerifyOtp = false.obs;
  RxBool resendOTPEnable = false.obs;

  RxString timerText = '02:00'.obs;
  int counter = 120;
  Timer? _timer;

  @override
  void onInit() {
    super.onInit();
    var data = Get.arguments;
    phoneNumber = data?['phoneNumber'] ?? '';
    startTimer();
    initSmsAutoFill();
  }

  /// شروع تایمر ۲ دقیقه‌ای
  void startTimer() {
    resendOTPEnable.value = false;
    counter = 120;
    timerText.value = '02:00';
    _timer?.cancel();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (counter > 0) {
        counter--;
        int minutes = counter ~/ 60;
        int seconds = counter % 60;
        timerText.value =
            '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
      } else {
        _timer?.cancel();
        resendOTPEnable.value = true;
      }
    });
  }

  /// فعال‌سازی شنود SMS
  void initSmsAutoFill() async {
    try {
      await SmsAutoFill().unregisterListener();
      await SmsAutoFill().listenForCode();
      SmsAutoFill().code.listen((event) {
        verifyCodeTEC.text = event.trim();
        if (verifyCodeTEC.text.length == 5) {
          onTapVerifyCodeButton();
        }
      });
    } catch (error) {
      debugPrint('SMS autofill error: $error');
    }
  }

  /// برگشت به صفحه لاگین برای ویرایش شماره
  void onTapEditButton() => Get.back();

  /// فعال‌سازی دکمه تأیید وقتی کد کامل شد
  void onChangeOTPCode({required String value}) {
    isVerifyOtp.value = value.length == 5;
  }

  /// وقتی کاربر روی "ارسال مجدد کد" کلیک می‌کند
  void onTapResendOTPButton() {
    if (resendOTPEnable.value) {
      resendOTPEnable.value = false;
      startTimer();
      resendOTPRequest();
    }
  }

  /// درخواست ارسال مجدد OTP
  void resendOTPRequest() {
    isLoadingResendCode.value = true;
    SignupRequestModel requestModel = SignupRequestModel(
      phoneNumber: phoneNumber,
    );

    _loginRepo.login(requestModel: requestModel).then((ResponseModel response) {
      isLoadingResendCode.value = false;
      responseHandler(
        statusCode: response.statusCode!,
        message: response.message ?? '',
        onSuccess: () {
          Get.snackbar(
            'موفقیت',
            'کد تأیید با موفقیت ارسال شد.',
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
        },
        onFailure: () {
          Get.snackbar(
            'خطا',
            response.message ?? 'ارسال مجدد کد با خطا مواجه شد.',
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        },
      );
    });
  }

  /// بررسی و ارسال کد OTP به سرور
  void onTapVerifyCodeButton() {
    if (!isVerifyOtp.value) return;

    isLoadingConfirmCode.value = true;

    OtpRequestModel requestModel = OtpRequestModel(
      phoneNumber: phoneNumber,
      verifyCode: verifyCodeTEC.text,
    );

    _repo.sendOtp(requestModel: requestModel).then((OtpResponseModel response) {
      isLoadingConfirmCode.value = false;
      responseHandler(
        statusCode: response.statusCode!,
        message: response.message ?? '',
        onSuccess: () {
          if (response.data?.token != null &&
              response.data?.refreshToken != null) {
            UserStoreService.to.saveToken(response.data!.token!);
            UserStoreService.to.saveRefreshToken(response.data!.refreshToken!);
            Get.offAllNamed(AppRoutes.HOME);
          } else {
            Get.snackbar(
              'خطا',
              'کد تأیید درست است اما توکن دریافت نشد.',
              snackPosition: SnackPosition.TOP,
              backgroundColor: Colors.red,
              colorText: Colors.white,
            );
          }
        },
        onFailure: () {
          Get.snackbar(
            'خطا',
            response.message ?? 'کد وارد شده اشتباه است.',
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        },
      );
    });
  }

  @override
  void onClose() {
    _timer?.cancel();
    verifyCodeTEC.dispose();
    SmsAutoFill().unregisterListener();
    super.onClose();
  }
}
