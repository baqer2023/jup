import 'package:flutter/foundation.dart';
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
import 'package:my_app32/features/main/repository/home_repository.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:dio/dio.dart';

class HomeControllerGroup extends GetxController with AppUtilsMixin {
  HomeControllerGroup(this._repoGroup);

  final HomeRepository _repoGroup;
  final TextEditingController titleControllerGroup = TextEditingController();
  final TextEditingController descriptionControllerGroup = TextEditingController();

  RxList<LocationItem> userLocationsGroup = <LocationItem>[].obs;
  RxList<DeviceItem> deviceListGroup = <DeviceItem>[].obs;
  RxBool isLoadingGroup = false.obs;
  RxBool isRefreshingGroup = false.obs;
  String tokenGroup = '';
  RxString selectedLocationIdGroup = 'all'.obs;
  late Future<WeatherData> weatherFutureGroup;

  @override
  void onInit() {
    super.onInit();
    _initializeTokenGroup();

    // مقدار اولیه آب‌وهوا
    weatherFutureGroup = WeatherApiService(
      apiKey: 'e6f7286f932ef4636fdfb82a45266d17',
    ).getWeather(lat: 35.7219, lon: 51.3347);
  }

  Future<void> _initializeTokenGroup() async {
    tokenGroup = await UserStoreService.to.getToken() ?? '';
    if (tokenGroup.isNotEmpty) {
      await fetchUserLocationsGroup();
    }
  }

  Future<void> refreshWeatherGroup() async {
    weatherFutureGroup = WeatherApiService(
      apiKey: 'e6f7286f932ef4636fdfb82a45266d17',
    ).getWeather(lat: 35.7219, lon: 51.3347);
    update();
  }

  // ------------------- User Locations -------------------
  Future<void> fetchUserLocationsGroup() async {
    try {
      if (tokenGroup.isEmpty) return;

      final url = Uri.parse('http://45.149.76.245:8080/api/dashboard/list');
      final data = json.encode({
        "sortProperty": "createdTime",
        "pageSize": 10,
        "page": 0,
        "sortOrder": "ASC",
      });

      final response = await http.post(
        url,
        headers: {'Authorization': 'Bearer $tokenGroup', 'Content-Type': 'application/json'},
        body: data,
      );

      if (response.statusCode == 200) {
        final model = UserLocationsResponseModel.fromJson(json.decode(response.body));
        userLocationsGroup.value = model.data;
      } else {
        print('Failed to fetch locations: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching user locations: $e');
    }
  }

  // ------------------- Devices by Location -------------------
  Future<void> fetchDevicesByLocationGroup(String dashboardIdGroup) async {
    try {
      print('Fetching devices for dashboardId: $dashboardIdGroup');
      if (tokenGroup.isEmpty) return;

      final url = Uri.parse('http://45.149.76.245:8080/api/dashboard/getDeviceList');
      final body = json.encode({"dashboardId": dashboardIdGroup});

      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $tokenGroup',
          'Content-Type': 'application/json',
        },
        body: body,
      );

      if (response.statusCode == 200) {
        final raw = json.decode(response.body);
        print("Raw response: $raw");

        if (raw is List) {
          final safeData = raw
              .whereType<Map<String, dynamic>>()
              .map((d) => DeviceItem.fromJson(d))
              .toList();

          deviceListGroup.value = safeData;
          deviceListGroup.refresh();

          print('✅ Devices parsed: ${deviceListGroup.length}');
        } else {
          print("❌ Unexpected format: ${raw.runtimeType}");
          deviceListGroup.clear();
        }
      } else {
        print('❌ Failed to fetch devices: ${response.statusCode}');
        deviceListGroup.clear();
      }
    } catch (e, st) {
      print('❌ Error fetching devices: $e');
      print(st);
      deviceListGroup.clear();
    }
  }



  
// داخل HomeControllerGroup
Future<void> fetchAllDevicesGroup() async {
  try {
    if (tokenGroup.isEmpty) return;

    final headers = {
      'Authorization': 'Bearer $tokenGroup',
      'Content-Type': 'application/json'
    };
    final data = json.encode({"page": 0, "pageSize": 100});

    var dio = Dio();
    var response = await dio.request(
      'http://45.149.76.245:8080/api/device/getAllDevices',
      options: Options(method: 'POST', headers: headers),
      data: data,
    );

    if (response.statusCode == 200) {
      final raw = response.data['data'];
      if (raw is List) {
        final safeData = raw
            .whereType<Map<String, dynamic>>()
            .map((d) => DeviceItem.fromJson(d))
            .toList();
        deviceListGroup.value = safeData;
        deviceListGroup.refresh();
        print('✅ All devices fetched: ${deviceListGroup.length}');
      }
    } else {
      print('❌ Failed to fetch all devices: ${response.statusMessage}');
      deviceListGroup.clear();
    }
  } catch (e, st) {
    print('❌ Error fetching all devices: $e');
    print(st);
    deviceListGroup.clear();
  }
}

  // ------------------- Refresh All -------------------
  Future<void> refreshAllDataGroup() async {
    try {
      isRefreshingGroup.value = true;
      final tokenServiceGroup = Get.find<TokenRefreshService>();
      await tokenServiceGroup.checkAndRefreshToken();
      await fetchUserLocationsGroup();
      deviceListGroup.clear();
      await refreshWeatherGroup();
    } catch (e) {
      print('Error refreshing data: $e');
    } finally {
      isRefreshingGroup.value = false;
    }
  }

  // ------------------- Device Helpers -------------------
  String getDeviceTypeNameGroup(String codeGroup) {
    switch (codeGroup) {
      case '02':
        return 'Smart Light';
      default:
        return 'Unknown';
    }
  }

  Future<void> removeDeviceGroup(String deviceIdGroup) async {
    try {
      final url = Uri.parse('http://45.149.76.245:8080/api/device/remove');
      final response = await http.post(
        url,
        headers: {'Authorization': 'Bearer $tokenGroup', 'Content-Type': 'application/json'},
        body: json.encode({'id': deviceIdGroup}),
      );

      if (response.statusCode == 200) {
        deviceListGroup.removeWhere((d) => d.deviceId == deviceIdGroup);
        Get.snackbar('موفق', 'دستگاه حذف شد');
      } else {
        Get.snackbar('خطا', 'حذف دستگاه موفق نبود: ${response.statusCode}');
      }
    } catch (e) {
      Get.snackbar('خطا', 'خطا در حذف دستگاه: $e');
    }
  }

  Future<void> addLocationGroup(String titleGroup) async {
    if (titleGroup.trim().isEmpty) {
      Get.snackbar('خطا', 'لطفاً نام مکان را وارد کنید',
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    try {
      final url = Uri.parse('http://45.149.76.245:8080/api/dashboard/addOrUpdate');
      final headers = {
        'Authorization': 'Bearer $tokenGroup',
        'Content-Type': 'application/json'
      };
      final data = json.encode({"title": titleGroup.trim()});

      final response = await http.post(url, headers: headers, body: data);

      if (response.statusCode == 200) {
        Get.snackbar('موفقیت', 'مکان با موفقیت اضافه شد',
            backgroundColor: Colors.green, colorText: Colors.white);
        await fetchUserLocationsGroup();
      } else {
        Get.snackbar('خطا', 'ثبت مکان موفقیت‌آمیز نبود: ${response.statusCode}',
            backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar('خطا', 'خطا در افزودن مکان: $e',
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }
}
