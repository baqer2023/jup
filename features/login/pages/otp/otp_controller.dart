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
  RxString timerText = '2:00'.obs;
  int counter = 120;
  Timer? _timer;

  @override
  void onInit() {
    super.onInit();
    var data = Get.arguments;
    if (data != null) {
      phoneNumber = data['phoneNumber'];
    } else {
      phoneNumber = '';
    }
    startTimer();
    initSmsAutoFill();
  }

  void startTimer() {
    counter = 120;
    timerText.value = '2:00';
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

  // todo: pending for backend
  /// for autofill verify code
  void initSmsAutoFill() async {
    try {
      await SmsAutoFill().unregisterListener();
    } catch (error) {
      debugPrint('*****************');
      debugPrint('Error unregisterListener: $error');
      debugPrint('-----------------');
    }
    try {
      await SmsAutoFill().listenForCode();
      SmsAutoFill().code.listen((event) {
        event.trim();
        List<String> sms = [];
        for (int i = 0; i < event.length; i++) {
          String t = event.substring(i, i + 1);
          sms.add(t);
        }
        String code = '';
        for (int i = 0; i < sms.length; i++) {
          code = code + sms[i];
        }
        verifyCodeTEC.text = code.trim();
        if (verifyCodeTEC.text.length == 5) {
          onTapVerifyCodeButton();
        }
      });
    } catch (error) {
      debugPrint('*****************');
      debugPrint('Error listenForCode: $error');
      debugPrint('-----------------');
    }
  }

  /// back to login page for edit phone number
  void onTapEditButton() => Get.back();

  /// enable verify button when fill text field
  void onChangeOTPCode({required String value}) {
    print('OTP Code changed: $value');
    print('Length: ${value.length}');
    isVerifyOtp.value = value.length == 5;
    print('isVerifyOtp: ${isVerifyOtp.value}');
  }

  /// resend verify Code request
  void onTapResendOTPButton() {
    if (resendOTPEnable.value) {
      resendOTPEnable.value = false;
      startTimer();
      resendOTPRequest();
    }
  }

  /// request resend verify code
  void resendOTPRequest() {
    isLoadingResendCode.value = true;
    SignupRequestModel requestModel = SignupRequestModel(
      phoneNumber: phoneNumber,
    );
    _loginRepo.login(requestModel: requestModel).then((ResponseModel response) {
      isLoadingResendCode.value = false;
      responseHandler(
        statusCode: response.statusCode!,
        message: response.message!,
        onSuccess: () {
          if (response.success) {
            Get.snackbar(
              'Success',
              'OTP sent successfully',
              snackPosition: SnackPosition.TOP,
              duration: const Duration(seconds: 3),
              backgroundColor: Colors.green,
              colorText: Colors.white,
            );
          }
        },
      );
    });
  }

  /// request confirm verify code
  void onTapVerifyCodeButton() {
    if (!isVerifyOtp.value) {
      print('Verify button pressed but OTP is not valid');
      return;
    }

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
              'Error',
              'OTP verified, but no token received.',
              snackPosition: SnackPosition.TOP,
              duration: const Duration(seconds: 3),
              backgroundColor: Colors.red,
              colorText: Colors.white,
            );
          }
        },
        onFailure: () {
          Get.snackbar(
            'Error',
            response.message ?? '',
            snackPosition: SnackPosition.TOP,
            duration: const Duration(seconds: 3),
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
