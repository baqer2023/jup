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

  RxBool isLoading = false.obs;
  RxBool isRefreshing = false.obs;
  String token = '';
RxList<DeviceItem> deviceList = <DeviceItem>[].obs;
RxList<DeviceItem> dashboardDevices = <DeviceItem>[].obs;
RxString selectedLocationId = ''.obs;
late Future<WeatherData> weatherFuture;


  @override
  void onInit() {
    super.onInit();
    _initializeToken();
    fetchHomeDevices();


    // مقدار اولیه آب‌وهوا
    weatherFuture = WeatherApiService(
      apiKey: 'e6f7286f932ef4636fdfb82a45266d17',
    ).getWeather(lat: 35.7219, lon: 51.3347);
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

      final headers = {
        'Authorization': 'Bearer $token',
      };

      final dio = Dio();
      final response = await dio.post(
        'http://45.149.76.245:8080/api/dashboard/getHome',
        options: Options(headers: headers),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        
        final devicesJson = data as List? ?? [];

        dashboardDevices.value =
            devicesJson.map((e) => DeviceItem.fromJson(e)).toList();

      } else {
        Get.snackbar("خطا", "دریافت دستگاه‌های داشبورد موفق نبود: ${response.statusCode}");
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
        headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
        body: data,
      );

      if (response.statusCode == 200) {
        final model = UserLocationsResponseModel.fromJson(json.decode(response.body));
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

    final url = Uri.parse('http://45.149.76.245:8080/api/dashboard/getDeviceList');
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

Future<void> removeDevice(String deviceId) async {
  try {
    final url = Uri.parse('http://45.149.76.245:8080/api/device/remove');
    final response = await http.post(
      url,
      headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
      body: json.encode({'id': deviceId}),
    );

    if (response.statusCode == 200) {
      deviceList.removeWhere((d) => d.deviceId == deviceId);
      Get.snackbar('موفق', 'دستگاه حذف شد');
    } else {
      Get.snackbar('خطا', 'حذف دستگاه موفق نبود: ${response.statusCode}');
    }
  } catch (e) {
    Get.snackbar('خطا', 'خطا در حذف دستگاه: $e');
  }
}




Future<void> addLocation(String title) async {
  if (title.trim().isEmpty) {
    Get.snackbar('خطا', 'لطفاً نام مکان را وارد کنید',
        backgroundColor: Colors.red, colorText: Colors.white);
    return;
  }

  try {
    final url = Uri.parse('http://45.149.76.245:8080/api/dashboard/addOrUpdate');
    final headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json'
    };
    final data = json.encode({"title": title.trim()});

    final response = await http.post(url, headers: headers, body: data);

    if (response.statusCode == 200) {
      Get.snackbar('موفقیت', 'مکان با موفقیت اضافه شد',
          backgroundColor: Colors.green, colorText: Colors.white);
      await fetchUserLocations(); // بازخوانی لیست مکان‌ها
    } else {
      Get.snackbar('خطا', 'ثبت مکان موفقیت‌آمیز نبود: ${response.statusCode}',
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  } catch (e) {
    Get.snackbar('خطا', 'خطا در افزودن مکان: $e',
        backgroundColor: Colors.red, colorText: Colors.white);
  }
}

  // ------------------- Remove From Dashboard (Temporary) -------------------
  Future<void> removeFromDashboard(String deviceId) async {
    try {
      final dio = Dio();
      final headers = {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };
      final data = json.encode({"id": deviceId});

      final response = await dio.post(
        'http://45.149.76.245:8080/api/device/removeFromDashboard',
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



}
