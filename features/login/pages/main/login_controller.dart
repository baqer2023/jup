import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_app32/app/core/app_constants.dart';
import 'package:my_app32/app/core/app_utils_mixin.dart';
import 'package:my_app32/app/models/response_model.dart';
import 'package:my_app32/app/routes/app_routes.dart';
import 'package:my_app32/app/store/user_store_service.dart';
import 'package:my_app32/features/login/models/signup_request_model.dart';
import 'package:my_app32/features/login/repository/login_repository.dart';

class LoginController extends GetxController with AppUtilsMixin {
  LoginController(this._repo);
  final LoginRepository _repo;

  // مقدار واقعی که به سرور ارسال می‌شود
  TextEditingController userNameTEC = TextEditingController();

  // برای نمایش داخل TextField
  final TextEditingController visiblePhoneTEC = TextEditingController();

  TextEditingController passwordTEC = TextEditingController();

  RxBool isLoading = false.obs;
  RxBool isEnableConfirmButton = false.obs;
  RxBool isValid = true.obs;

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // برای پشتیبانی از "ارسال دوباره در کمتر از 2 دقیقه"
  String? lastRequestedPhone;
  DateTime? lastRequestTime;

  /// بررسی صحت شماره
  void onTapCheckLoginOrSignup() {
    String phoneNumber = userNameTEC.text.trim();

    // فقط ارقام رو نگه دار
    phoneNumber = phoneNumber.replaceAll(RegExp(r'[^0-9]'), '');

    // چک می‌کنیم که شماره 11 رقم و با 09 شروع شود
    if (phoneNumber.length == 11 && phoneNumber.startsWith('09')) {
      isValid.value = true;
      isEnableConfirmButton.value = true;
    } else {
      isValid.value = false;
      isEnableConfirmButton.value = false;
    }
  }

  /// ارسال درخواست ورود
  void onTapLogin() async {
    String phoneNumber = userNameTEC.text.trim();
    phoneNumber = phoneNumber.replaceAll(RegExp(r'[^0-9]'), '');

    // اعتبارسنجی پایه
    if (!(phoneNumber.length == 11 && phoneNumber.startsWith('09'))) {
      Get.rawSnackbar(
        messageText: Text(
          'شماره موبایل نامعتبر است. فرمت موردنظر: 0912xxxxxxx',
          style: const TextStyle(color: Colors.white, fontFamily: 'IranYekan'),
        ),
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.redAccent,
        margin: const EdgeInsets.all(16),
        borderRadius: 8,
        duration: const Duration(seconds: 2),
      );
      return;
    }

    // اگر قبلاً همین شماره ارسال شده و کمتر از 2 دقیقه گذشته باشه،
    // ما اجازه میدیم دوباره ارسال بشه (رفتار قبلی که مد نظر تو بود)
    final bool allowRepeatWithin2Min = (lastRequestedPhone == phoneNumber &&
        lastRequestTime != null &&
        DateTime.now().difference(lastRequestTime!) < const Duration(minutes: 2));

    // در هر صورت (چه تکراری باشه چه نباشه) تلاش می‌کنیم درخواست بفرستیم.
    // isLoading رو فعال می‌کنیم تا UI درست رفتار کنه.
    isLoading.value = true;

    try {
      lastRequestedPhone = phoneNumber;
      lastRequestTime = DateTime.now();

      SignupRequestModel requestModel = SignupRequestModel(phoneNumber: phoneNumber);

      ResponseModel response = await _repo.login(requestModel: requestModel);

      isLoading.value = false;

      // ✅ اگر سرور 200 داد -> موفق
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
        return;
      }

      // اگر سرور 400 یا هر وضعیت دیگه ای داد، پیامِ سرور رو با الویت body نمایش میدیم
      String serverMessage = '';
      try {
        // اگر body وجود داره و قابل خواندن، ازش استفاده کن
        if (response.body != null && response.body.toString().trim().isNotEmpty) {
          serverMessage = response.body.toString();
        } else if (response.message != null && response.message!.trim().isNotEmpty) {
          serverMessage = response.message!;
        } else {
          serverMessage = 'مشکلی پیش آمده است.';
        }
      } catch (_) {
        serverMessage = response.message ?? 'مشکلی پیش آمده است.';
      }

      // نمایش پیام خطا به کاربر (بالا و زیبا)
      Get.rawSnackbar(
        messageText: Text(
          serverMessage,
          style: const TextStyle(color: Colors.white, fontFamily: 'IranYekan'),
        ),
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.redAccent,
        margin: const EdgeInsets.all(16),
        borderRadius: 8,
        duration: const Duration(seconds: 4),
      );

      // نکته: اگر نیاز داری که در حالت خاصی (مثلاً کد خطای خاص)
      // رفتار متفاوت باشه (مثلاً باز کردن دیالوگ یا ریست فیلد) می‌تونم اضافه کنم.

    } catch (error) {
      isLoading.value = false;
      Get.snackbar(
        'خطا',
        'مشکلی در ارتباط با سرور رخ داد.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    }
  }

  @override
  void onInit() {
    super.onInit();
    isEnableConfirmButton.value = false;
    isValid.value = true;

    // همگام‌سازی اولیه بین visiblePhoneTEC و userNameTEC
    visiblePhoneTEC.addListener(() {
      if (visiblePhoneTEC.text != userNameTEC.text) {
        userNameTEC.text = visiblePhoneTEC.text;
        onTapCheckLoginOrSignup();
      }
    });
  }

  @override
  void onClose() {
    userNameTEC.dispose();
    visiblePhoneTEC.dispose();
    passwordTEC.dispose();
    super.onClose();
  }
}
