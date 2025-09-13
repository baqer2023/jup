import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppFlushBarUtil {
  static void showFlushBarNoInternet() {
    showFlushBar(
      message: 'به اینترنت متصل نیستید',
      duration: const Duration(seconds: 3),
      buttonText: '',
      buttonFunction: () {},
    );
  }

  static void showFlushBarServerError() {
    showFlushBar(
        message: 'خطا در درخواست شما. دقایقی دیگر تلاش کنید',
        duration: const Duration(seconds: 3),
        buttonText: '',
        buttonFunction: () {});
  }

  static void showFlushBarNoInternetRetry({required Function buttonFunction}) {
    showFlushBar(
        message: 'خطا در ارتباط با اینترنت. دوباره تلاش کنید',
        duration: const Duration(days: 365),
        buttonText: 'تلاش مجدد',
        buttonFunction: buttonFunction());
  }

  static void showFlushBar(
      {required String message,
      Duration duration =const Duration(seconds: 3),
      String? buttonText,
      void Function()? buttonFunction,
      bool show = true}) {
    show
        ? Flushbar(
            animationDuration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.only(
              bottom: 56,
              left: 8.0,
              right: 8.0,
            ),
            borderRadius: BorderRadius.circular(8),
            backgroundColor: Colors.black87,
            messageText: Directionality(
              textDirection: TextDirection.rtl,
              child: Row(children: <Widget>[
                Expanded(
                  child: Text(
                    message,
                    textScaleFactor: 1,
                    style: const TextStyle(color: Colors.white),
                    textDirection: TextDirection.rtl,
                  ),
                ),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      Get.back();
                      buttonFunction != null ? buttonFunction() : null;
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Text(
                        buttonText ?? '',
                        textScaleFactor: 1,
                        style: const TextStyle(color: Colors.amber),
                      ),
                    ),
                  ),
                ),
              ]),
            ),
            duration: duration,
          ).show(Get.context!)
        : Container();
  }
}
