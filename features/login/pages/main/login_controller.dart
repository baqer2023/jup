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

  // 🔹 اضافه کردن کد کشور و پرچم
  RxString selectedCountryCode = '+98'.obs; // پیش‌فرض ایران
  RxString selectedCountryFlag = 'IR'.obs;

  RxBool isLoading = false.obs;
  RxBool isEnableConfirmButton = false.obs;
  RxBool isValid = true.obs;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  /// request login
  void onTapCheckLoginOrSignup() {
    String phoneNumber = userNameTEC.text;
    // پاکسازی شماره
    phoneNumber = phoneNumber.replaceAll(RegExp(r'[^0-9]'), '');

    // حذف کد کشور اگر ایران باشه
    if (phoneNumber.startsWith('98')) {
      phoneNumber = phoneNumber.substring(2);
    }

    if (phoneNumber.length == 11 && phoneNumber.startsWith('09')) {
      isValid.value = true;
      isEnableConfirmButton.value = true;
    } else {
      isEnableConfirmButton.value = false;
      isValid.value = false;
      isLoading.value = false;
    }
  }

void onTapLogin() {
  String phoneNumber = userNameTEC.text;
  phoneNumber = phoneNumber.replaceAll(RegExp(r'[^0-9]'), '');

  if (phoneNumber.startsWith('98')) phoneNumber = phoneNumber.substring(2);

  if (phoneNumber.length == 11 && phoneNumber.startsWith('09')) {
    isLoading.value = true;
    SignupRequestModel requestModel = SignupRequestModel(
      phoneNumber: phoneNumber,
    );
    _repo.login(requestModel: requestModel).then((ResponseModel response) {
      isLoading.value = false;

      // ✅ بررسی statusCode
      if (response.statusCode == 200) {
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
      } else if (response.statusCode == 400) {
              // نمایش پیام واقعی سرور
              String serverMessage = '';
              try {
                // if () {
                //   serverMessage = response.data.toString();
                //   print("serverMessagezzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz");
                //   print(serverMessage);
                // } else {
                //   serverMessage = response.message ?? 'مشکلی پیش آمده است.';
                // }
              } catch (_) {
                serverMessage = response.message ?? 'مشکلی پیش آمده است.';
              }

  Get.rawSnackbar(
    messageText: Text(
      response.body.toString(),
      style: const TextStyle(color: Colors.white, fontFamily: 'IranYekan'),
    ),
    snackPosition: SnackPosition.TOP, // ✅ حتما بالا
    backgroundColor: Colors.redAccent,
    margin: const EdgeInsets.all(16),
    borderRadius: 8,
    duration: const Duration(seconds: 3),
  );
            } else {
        Get.snackbar(
          'خطا',
          response.message ?? 'مشکلی پیش آمده است.',
          snackPosition: SnackPosition.TOP, // ✅ اینجا هم بالا
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
      }
    }).catchError((error) {
      isLoading.value = false;
      Get.snackbar(
        'خطا',
        'مشکلی در اتصال به سرور رخ داد.',
        snackPosition: SnackPosition.TOP, // ✅ اینجا هم بالا
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    });
  }
}

  @override
  void onInit() {
    super.onInit();
    isEnableConfirmButton.value = false;
    isValid.value = false;
  }
}
