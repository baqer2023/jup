import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_app32/app/core/app_constants.dart';
import 'package:my_app32/app/core/app_regex.dart';
import 'package:my_app32/app/core/app_utils_mixin.dart';
import 'package:my_app32/app/models/response_model.dart';
import 'package:my_app32/app/routes/app_routes.dart';
import 'package:my_app32/app/store/user_store_service.dart';
import 'package:my_app32/features/login/models/signup_request_model.dart';
import 'package:my_app32/features/login/repository/login_repository.dart';

class LoginController extends GetxController with AppUtilsMixin {
  LoginController(this._repo);

  final LoginRepository _repo;
  TextEditingController userNameTEC = TextEditingController();
  TextEditingController passwordTEC = TextEditingController();
  RxBool isLoading = false.obs;
  RxBool isEnableConfirmButton = false.obs;
  RxBool isValid = true.obs;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  /// request login
  void onTapCheckLoginOrSignup() {
    String phoneNumber = userNameTEC.text;
    print('Raw phone number from field: $phoneNumber');

    // Clean the phone number
    phoneNumber = phoneNumber.replaceAll(RegExp(r'[^0-9]'), '');
    print('Cleaned phone number: $phoneNumber');

    // If it starts with 98 (Iran country code), remove it
    if (phoneNumber.startsWith('98')) {
      phoneNumber = phoneNumber.substring(2);
      print('Removed country code, new number: $phoneNumber');
    }

    print('Final phone number length: ${phoneNumber.length}');
    print('Starts with 09: ${phoneNumber.startsWith('09')}');

    // Check if the phone number is exactly 11 digits and starts with 09
    if (phoneNumber.length == 11 && phoneNumber.startsWith('09')) {
      print('Phone number is valid - Enabling button');
      isValid.value = true;
      isEnableConfirmButton.value = true;
    } else {
      print('Phone number is invalid - Disabling button');
      print('Length check failed: ${phoneNumber.length != 11}');
      print('Prefix check failed: ${!phoneNumber.startsWith('09')}');
      isEnableConfirmButton.value = false;
      isValid.value = false;
      isLoading.value = false;
    }
  }

  void onTapLogin() {
    String phoneNumber = userNameTEC.text;
    // Clean the phone number
    phoneNumber = phoneNumber.replaceAll(RegExp(r'[^0-9]'), '');

    // If it starts with 98 (Iran country code), remove it
    if (phoneNumber.startsWith('98')) {
      phoneNumber = phoneNumber.substring(2);
    }

    if (phoneNumber.length == 11 && phoneNumber.startsWith('09')) {
      print('Attempting login with phone number: $phoneNumber');
      isLoading.value = true;
      SignupRequestModel requestModel = SignupRequestModel(
        phoneNumber: phoneNumber,
      );
      _repo.login(requestModel: requestModel).then((ResponseModel response) {
        isLoading.value = false;
        responseHandler(
          statusCode: response.statusCode!,
          message: response.message ?? '',
          onSuccess: () {
            UserStoreService.to.save(
              key: AppConstants.USER_NAME,
              value: phoneNumber,
            );
            Get.toNamed(AppRoutes.OTP, arguments: {'phoneNumber': phoneNumber});
          },
          onFailure: () {},
        );
      });
    } else {
      print('Login attempt failed - Invalid phone number');
    }
  }

  @override
  void onInit() {
    super.onInit();
    // Initialize the button state
    isEnableConfirmButton.value = false;
    isValid.value = false;
  }
}
