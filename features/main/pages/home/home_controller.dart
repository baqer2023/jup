// import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:my_app32/app/models/weather_models.dart';
import 'package:my_app32/app/services/token_refresh_service.dart';
import 'package:my_app32/app/services/weather_service.dart';
import 'package:my_app32/features/main/models/home/device_item_model.dart';
import 'package:my_app32/features/main/models/home/get_dashboards_response_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_app32/app/core/app_enums.dart';
import 'package:my_app32/app/core/app_utils_mixin.dart';
import 'package:my_app32/app/routes/app_routes.dart';
import 'package:my_app32/app/store/user_store_service.dart';
import 'package:my_app32/features/main/models/home/create_dashboard_request_model.dart';
import 'package:my_app32/features/main/models/home/create_dashboard_response_model.dart';

import 'package:my_app32/features/main/models/home/get_current_user_response_model.dart';
import 'package:my_app32/features/main/models/home/get_dashboards_request_model.dart';
import 'package:my_app32/features/main/models/home/user_locations_response_model.dart';
// import 'package:my_app32/features/main/models/devices/remove_device_request_model.dart';
// import 'package:my_app32/features/main/models/devices/register_device_request_model.dart';
import 'package:my_app32/features/main/repository/home_repository.dart';
// import 'package:my_app32/features/main/pages/home/home_devices_controller.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HomeController extends GetxController with AppUtilsMixin {
  HomeController(this._repo);

  final HomeRepository _repo;
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  RxList<LocationItem> userLocations = <LocationItem>[].obs;
  // RxList<Map<String, dynamic>> deviceList = <Map<String, dynamic>>[].obs;
  final isFirstLoad = true.obs;
  RxBool isLoading = false.obs;
  RxBool isRefreshing = false.obs;
  String token = '';
  RxList<DeviceItem> deviceList = <DeviceItem>[].obs;
  RxList<DeviceItem> dashboardDevices = <DeviceItem>[].obs;
  RxString selectedLocationId = ''.obs;
  late Future<WeatherData> weatherFuture;
  String serverUrl = 'http://45.149.76.245:8080';

  @override
  void onInit() {
    super.onInit();
    // می‌توانیم فقط initData را صدا بزنیم
    initData();
  }

  Future<void> initData() async {
    print("🔹 initData called");
    token = await UserStoreService.to.getToken() ?? '';
    print("Token: $token");

    if (token.isNotEmpty) {
      await fetchUserLocations();
      await fetchHomeDevices();
    }

    selectedLocationId.value = '';
    // مقدار اولیه آب‌وهوا
    weatherFuture = WeatherApiService(
      apiKey: 'e6f7286f932ef4636fdfb82a45266d17',
    ).getWeather(lat: 35.7219, lon: 51.3347);

    print("✅ initData finished");
  }

  @override
  void onReady() {
    super.onReady();
    refreshAllData(); // هر بار صفحه باز بشه اجرا میشه
  }

  Future<void> _initializeToken() async {
    token = await UserStoreService.to.getToken() ?? '';
    if (token.isNotEmpty) {
      await fetchUserLocations();
    }
  }

  // برای رفرش دستی
  Future<void> refreshWeather() async {
    weatherFuture = WeatherApiService(
      apiKey: 'e6f7286f932ef4636fdfb82a45266d17',
    ).getWeather(lat: 35.7219, lon: 51.3347);
    update(); // باعث میشه ویجت‌هایی که به controller گوش میدن دوباره ساخته بشن
  }

  Future<void> fetchHomeDevices() async {
    try {
      final token = await UserStoreService.to.getToken();
      if (token == null) return;

      final headers = {'Authorization': 'Bearer $token'};

      final dio = Dio();
      final response = await dio.post(
        'http://45.149.76.245:8080/api/dashboard/getHome',
        options: Options(headers: headers),
      );

      if (response.statusCode == 200) {
        final data = response.data;

        final devicesJson = data as List? ?? [];

        dashboardDevices.value = devicesJson
            .map((e) => DeviceItem.fromJson(e))
            .toList();
      } else {
        Get.snackbar(
          "خطا",
          "دریافت دستگاه‌های داشبورد موفق نبود: ${response.statusCode}",
        );
      }
    } catch (e) {
      Get.snackbar("خطا", "اشکال در ارتباط با سرور: $e");
    }
  }

  // ------------------- User Locations -------------------
  Future<void> fetchUserLocations() async {
    try {
      if (token.isEmpty) return;

      final url = Uri.parse('http://45.149.76.245:8080/api/dashboard/list');
      final data = json.encode({
        "sortProperty": "createdTime",
        "pageSize": 10,
        "page": 0,
        "sortOrder": "ASC",
      });

      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: data,
      );

      if (response.statusCode == 200) {
        final model = UserLocationsResponseModel.fromJson(
          json.decode(response.body),
        );
        userLocations.value = model.data;
      } else {
        print('Failed to fetch locations: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching user locations: $e');
    }
  }

  // ------------------- Devices by Location -------------------
  Future<void> fetchDevicesByLocation(String dashboardId) async {
    try {
      print('Fetching devices for dashboardId: $dashboardId');
      if (token.isEmpty) return;

      final url = Uri.parse(
        'http://45.149.76.245:8080/api/dashboard/getDeviceList',
      );
      final body = json.encode({"dashboardId": dashboardId});

      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: body,
      );

      if (response.statusCode == 200) {
        final raw = json.decode(response.body);
        print("Raw response: $raw");

        if (raw is List) {
          // فقط Map<String, dynamic> ها رو نگه می‌داره
          final safeData = raw
              .whereType<Map<String, dynamic>>()
              .map((d) => DeviceItem.fromJson(d))
              .toList();

          deviceList.value = safeData;
          deviceList.refresh();

          print('✅ Devices parsed: ${deviceList.length}');
        } else {
          print("❌ Unexpected format: ${raw.runtimeType}");
          deviceList.clear();
        }
      } else {
        print('❌ Failed to fetch devices: ${response.statusCode}');
        deviceList.clear();
      }
    } catch (e, st) {
      print('❌ Error fetching devices: $e');
      print(st);
      deviceList.clear();
    }
  }

  // ------------------- Refresh All -------------------
  Future<void> refreshAllData() async {
    try {
      isRefreshing.value = true;
      final tokenService = Get.find<TokenRefreshService>();
      await tokenService.checkAndRefreshToken();
      await fetchUserLocations();
      deviceList.clear();
      await refreshWeather();
      await fetchHomeDevices();
    } catch (e) {
      print('Error refreshing data: $e');
    } finally {
      isRefreshing.value = false;
    }
  }

  // ------------------- Device Helpers -------------------
  String getDeviceTypeName(String code) {
    switch (code) {
      case '02':
        return 'Smart Light';
      default:
        return 'Unknown';
    }
  }

  // Future<void> removeDevice(String deviceId) async {
  //   try {
  //     final url = Uri.parse('http://45.149.76.245:8080/api/device/remove');
  //     final response = await http.post(
  //       url,
  //       headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
  //       body: json.encode({'id': deviceId}),
  //     );

  //     if (response.statusCode == 200) {
  //       deviceList.removeWhere((d) => d.deviceId == deviceId);
  //       Get.snackbar('موفق', 'دستگاه حذف شد');
  //     } else {
  //       Get.snackbar('خطا', 'حذف دستگاه موفق نبود: ${response.statusCode}');
  //     }
  //   } catch (e) {
  //     Get.snackbar('خطا', 'خطا در حذف دستگاه: $e');
  //   }
  // }

  Future<void> addLocation(String title) async {
    if (title.trim().isEmpty) {
      Get.snackbar(
        'خطا',
        'لطفاً نام مکان را وارد کنید',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    try {
      final url = Uri.parse(
        'http://45.149.76.245:8080/api/dashboard/addOrUpdate',
      );
      final headers = {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };
      final data = json.encode({"title": title.trim()});

      final response = await http.post(url, headers: headers, body: data);

      if (response.statusCode == 200) {
        Get.snackbar(
          'موفقیت',
          'مکان با موفقیت اضافه شد',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        await fetchUserLocations(); // بازخوانی لیست مکان‌ها
      } else {
        Get.snackbar(
          'خطا',
          'ثبت مکان موفقیت‌آمیز نبود: ${response.statusCode}',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'خطا',
        'خطا در افزودن مکان: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> updateLocation({
    required String title,
    String? dashboardId,
  }) async {
    if (title.trim().isEmpty) {
      Get.snackbar(
        'خطا',
        'لطفاً نام مکان را وارد کنید',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    print(dashboardId);
    try {
      final url = Uri.parse(
        'http://45.149.76.245:8080/api/dashboard/addOrUpdate',
      );

      final headers = {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };

      // ✅ اگر dashboardId وجود داشت، همراه title بفرستیم
      final body = {
        "title": title.trim(),
        if (dashboardId != null && dashboardId.isNotEmpty) "id": dashboardId,
      };

      final data = json.encode(body);

      final response = await http.post(url, headers: headers, body: data);

      if (response.statusCode == 200) {
        Get.snackbar(
          'موفقیت',
          dashboardId != null
              ? 'مکان با موفقیت ویرایش شد'
              : 'مکان با موفقیت اضافه شد',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        // بازخوانی لیست مکان‌ها پس از بروزرسانی
        await fetchUserLocations();
      } else {
        Get.snackbar(
          'خطا',
          'عملیات ناموفق بود: ${response.statusCode}',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'خطا',
        'خطا در برقراری ارتباط با سرور: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // ------------------- Remove From Dashboard (Temporary) -------------------
  Future<void> removeFromAllDashboard(String deviceId) async {
    try {
      final dio = Dio();
      final headers = {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };
      final data = json.encode({"id": deviceId});

      final response = await dio.post(
        'http://45.149.76.245:8080/api/device/removeFromAllDashboard',
        options: Options(headers: headers),
        data: data,
      );

      if (response.statusCode == 200) {
        deviceList.removeWhere((d) => d.deviceId == deviceId);
        Get.snackbar('موفق', 'دستگاه موقتاً از داشبورد حذف شد');
      } else {
        Get.snackbar('خطا', 'حذف موقت موفق نبود: ${response.statusCode}');
      }
    } catch (e) {
      Get.snackbar('خطا', 'اشکال در حذف موقت: $e');
    }
  }

  // ------------------- Complete Remove (Permanent) -------------------
  Future<void> completeRemoveDevice(String deviceId) async {
    try {
      final dio = Dio();
      final headers = {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };
      final data = json.encode({"id": deviceId});

      final response = await dio.post(
        'http://45.149.76.245:8080/api/device/completeRemove',
        options: Options(headers: headers),
        data: data,
      );

      if (response.statusCode == 200) {
        deviceList.removeWhere((d) => d.deviceId == deviceId);
        Get.snackbar('موفق', 'دستگاه به طور کامل حذف شد');
      } else {
        Get.snackbar('خطا', 'حذف کامل موفق نبود: ${response.statusCode}');
      }
    } catch (e) {
      Get.snackbar('خطا', 'اشکال در حذف کامل: $e');
    }
  }

  Future<void> resetDevice(String deviceId) async {
    try {
      if (token.isEmpty) {
        Get.snackbar(
          'خطا',
          'توکن خالی است',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      final headers = {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };

      final data = json.encode({
        "id": deviceId, // به عنوان مثال: "f8211120-93ac-11f0-839a-c7e577718932"
      });

      final dio = Dio();
      final response = await dio.request(
        'http://45.149.76.245:8080/api/plugins/telemetry/device/sharedReset',
        options: Options(method: 'POST', headers: headers),
        data: data,
      );

      if (response.statusCode == 200) {
        print("✅ Response: ${json.encode(response.data)}");
        Get.snackbar(
          'موفق',
          'دستگاه با موفقیت ریست شد',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        print("❌ Error: ${response.statusMessage}");
        Get.snackbar(
          'خطا',
          'عملیات ریست موفق نبود: ${response.statusMessage}',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print("❌ Exception: $e");
      Get.snackbar(
        'خطا',
        'خطا در ریست دستگاه: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> renameDevice({
    required String deviceId,
    required String label,
    required String oldDashboardId,
    required String newDashboardId,
  }) async {
    final token = this.token; // فرض: توکن از قبل تو کنترلر ذخیره شده
    if (token == null) {
      Get.snackbar(
        'خطا',
        'توکن معتبر پیدا نشد',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    final headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };

    // 🔹 payload داینامیک بسته به تغییر داشبورد
    final Map<String, dynamic> payload = {"deviceId": deviceId, "label": label};

    if (oldDashboardId != newDashboardId) {
      payload["oldDashboardId"] = oldDashboardId;
      payload["newDashboardId"] = newDashboardId;
    }

    print('در حال ارسال نام جدید: $label با payload: $payload');

    try {
      final dio = Dio();
      final response = await dio.post(
        'http://45.149.76.245:8080/api/editDevice', // آدرس سرور
        options: Options(headers: headers),
        data: json.encode(payload),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.snackbar(
          'موفقیت',
          'نام دستگاه با موفقیت ویرایش شد',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        print(json.encode(response.data));
      } else {
        Get.snackbar(
          'خطا',
          'ویرایش دستگاه با خطا مواجه شد: ${response.statusCode}',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        print(response.statusMessage);
      }
    } catch (e) {
      Get.snackbar(
        'خطا',
        'مشکل در برقراری ارتباط با سرور: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}
