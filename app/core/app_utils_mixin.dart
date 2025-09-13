import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:my_app32/app/core/app_dialog.dart';
import 'package:my_app32/app/core/app_icons.dart';
import 'package:my_app32/app/routes/app_routes.dart';
import 'package:my_app32/app/store/user_store_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

mixin AppUtilsMixin {
  void removeFocus() => FocusManager.instance.primaryFocus?.unfocus();

  void logoutFromApp() {
    UserStoreService.to.deleteAll();
    Get.offAndToNamed(AppRoutes.LOGIN);
  }

  // mixin AppUtilsMixin {
  //   void removeFocus() => FocusManager.instance.primaryFocus!.unfocus();
  //
  //   void logoutFromApp() {
  //     UserStoreService.to.deleteAll();
  //     Get.offAndToNamed(AppRoutes.LOGIN);
  //   }

  void responseHandler({
    required int statusCode,
    required String message,
    required VoidCallback onSuccess,
    VoidCallback? onFailure,
  }) {
    if (statusCode == 200) {
      onSuccess();
    } else if (statusCode == 401) {
      return;
    }

    //  #add device to wifi condition
    // else {
    //   if (onFailure != null) {
    //     onFailure();
    //   } else {
    //     AppDialog dialog = AppDialog(
    //       title: 'عدم اتصال ',
    //       subTitle: message,
    //     );
    //     dialog.showAppDialog();
    //   }
    // }
  }

  void logoutDialog() {
    AppDialog dialog = AppDialog(
      title: 'Something went wrong',
      subTitle: 'Please Login again',
      mainTaskTitle: 'Log Out',
      mainTask: () {
        Get.back();
        logoutFromApp();
      },
    );
    bool isOpenDialog = Get.isDialogOpen ?? false;
    if (!isOpenDialog) {
      dialog.showAppDialog();
    }
  }
  //------------------- COMMENTED this is default response for no internet connection   ----------------

  // void noInternetConnectionDialog({required VoidCallback mainTask}) {
  //   AppDialog dialog = AppDialog(
  //     title: 'Error to Access Internet',
  //     subTitle: 'Please check your internet connection and try again',
  //     mainTaskTitle: 'Try Again',
  //     mainTask: () {
  //       Get.back();
  //       mainTask();
  //     },
  //     icon: AppIcons.icNoConnection,
  //   );
  //   dialog.showAppDialog();
  // }

  void noInternetConnectionDialog({required VoidCallback mainTask}) {
    Get.dialog(
      GestureDetector(
        onTap: () {
          Get.back();
          mainTask();
        },
        child: Container(
          color: Colors.blueGrey.shade200,
          child: SvgPicture.asset(
            'assets/images/no_internet.svg',
            fit: BoxFit.contain,
            width: 300,
            height: 200,
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  void showErrorSnackbar(String message) {
    Get.snackbar(
      'خطا', // or 'Error'
      message,
      backgroundColor: Colors.red.withOpacity(0.85),
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(12),
      borderRadius: 8,
      duration: const Duration(seconds: 3),
    );
  }

  void showSuccessSnackbar(String message) {
    Get.snackbar(
      'موفق', // or 'Success'
      message,
      backgroundColor: Colors.green.withOpacity(0.85),
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(12),
      borderRadius: 8,
      duration: const Duration(seconds: 3),
    );
  }

  void showInfoSnackbar(String message) {
    Get.snackbar(
      'اطلاع‌رسانی', // or 'Info'
      message,
      backgroundColor: Colors.blue.withOpacity(0.85),
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(12),
      borderRadius: 8,
      duration: const Duration(seconds: 3),
    );
  }

  /// Converts English digits in a string to Persian digits
  static String toPersianNumber(dynamic input) {
    final en = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    final fa = ['۰', '۱', '۲', '۳', '۴', '۵', '۶', '۷', '۸', '۹'];
    String s = input.toString();
    for (int i = 0; i < en.length; i++) {
      s = s.replaceAll(en[i], fa[i]);
    }
    return s;
  }
}
