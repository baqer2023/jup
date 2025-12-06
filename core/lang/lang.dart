// core/lang/lang.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class Lang {
  static RxString current = "fa".obs;
  static Map<String, dynamic> _data = {};
  
  // 🔹 جهت متن - پیش‌فرض LTR برای فارسی (چپ‌چین)
  static Rx<TextDirection> textDirection = TextDirection.ltr.obs;

  static Future<void> load([String locale = "fa"]) async {
    final jsonStr = await rootBundle.loadString("assets/lang/$locale.json");
    _data = json.decode(jsonStr);
    
    // 🔹🔹 فارسی (fa) = LTR = چپ‌چین ✅
    // 🔹🔹 انگلیسی (en) = RTL = راست‌چین ✅
    if (locale == 'en') {
      textDirection.value = TextDirection.rtl; // انگلیسی راست‌چین
    } else {
      textDirection.value = TextDirection.ltr; // فارسی چپ‌چین
    }
  }

  static String t(String key, {Map<String, Object>? params}) {
    if (!_data.containsKey(key)) return key;
    String text = _data[key].toString();
    if (params != null) {
      params.forEach((k, v) {
        text = text.replaceAll("{$k}", v.toString());
      });
    }
    return text;
  }

  static Future<void> setLocale(String locale) async {
    await load(locale);
    current.value = locale;
    
    // 🔹🔹 فارسی = LTR (چپ‌چین)، انگلیسی = RTL (راست‌چین)
    if (locale == 'en') {
      textDirection.value = TextDirection.rtl; // انگلیسی راست‌چین
    } else {
      textDirection.value = TextDirection.ltr; // فارسی چپ‌چین
    }
    
    print("🔹 Locale changed to: $locale");
    print("🔹 TextDirection is now: ${textDirection.value}");
    
    Get.forceAppUpdate();
  }
}