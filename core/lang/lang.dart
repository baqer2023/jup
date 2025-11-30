import 'dart:convert';
import 'dart:ui';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class Lang {
  static RxString current = "fa".obs;
  static Map<String, dynamic> _data = {};

  static Future<void> load([String locale = "fa"]) async {
    final jsonStr = await rootBundle.loadString("assets/lang/$locale.json");
    _data = json.decode(jsonStr);
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
    current.value = locale; // فقط متن‌ها رفرش می‌شوند
    // ⚡️ هیچ رفرشی روی کل اپ انجام نمی‌شود
  }
}
