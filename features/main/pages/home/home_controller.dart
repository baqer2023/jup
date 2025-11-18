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
import 'package:flutter/widgets.dart'; // 👈 حتما باید باشه
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

// بقیه importهای خودت

class HomeController extends GetxController with AppUtilsMixin, WidgetsBindingObserver {
  HomeController(this._repo);

  late Box box;


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
  WidgetsBinding.instance.addObserver(this);

  initController();   // ✔ فقط این باید اجرا شود
}


  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      print("🔁 App resumed — refreshing data...");
      refreshAllData(); // یا initData() بسته به نیاز
    }
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
  // دیگر اینجا refresh یا initData لازم نیست
}

  Future<void> _initializeToken() async {
    token = await UserStoreService.to.getToken() ?? '';
    if (token.isNotEmpty) {
      await fetchUserLocations();
    }
  }


Future<void> initController() async {
  try {
    print("🔹 HomeController initializing...");


        if (token.isNotEmpty) {
      await fetchUserLocations();
      await fetchHomeDevices();
    }

    // 🔹 1) باز کردن باکس کش
    box = await Hive.openBox('cache');
    print("📦 Hive box opened");

    // 🔹 2) گرفتن توکن
    token = await UserStoreService.to.getToken() ?? '';
    print("🔑 Token loaded: $token");

    // 🔹 3) لود اولیه از کش (برای نمایش سریع و آفلاین)
    _loadCachedDataOnStartup();

    // 🔹 4) سپس گرفتن دیتا از اینترنت (غیرمسدود کننده)
    Future.microtask(() async {
      await refreshAllData();
    });

  } catch (e) {
    print("❌ Error in initController: $e");
  }
}





void _loadCachedDataOnStartup() {
  print("📍 Loading cached data...");

  // مکان‌ها
  final cachedLocations = box.get('user_locations');
  if (cachedLocations != null) {
    userLocations.value = (cachedLocations as List)
        .map((e) => LocationItem.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  // دستگاه‌های Home
  final cachedHome = box.get('home_devices');
  if (cachedHome != null) {
    dashboardDevices.value = (cachedHome as List)
        .map((e) => DeviceItem.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  // دستگاه‌های لوکیشن انتخاب‌شده
  final locId = selectedLocationId.value;
  if (locId.isNotEmpty) {
    final cachedDevices = box.get('devices_$locId');
    if (cachedDevices != null) {
      deviceList.value = (cachedDevices as List)
          .map((e) => DeviceItem.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }
  }

  print("✅ Cached data loaded.");
}



  // برای رفرش دستی
  Future<void> refreshWeather() async {
    weatherFuture = WeatherApiService(
      apiKey: 'e6f7286f932ef4636fdfb82a45266d17',
    ).getWeather(lat: 35.7219, lon: 51.3347);
    update(); // باعث میشه ویجت‌هایی که به controller گوش میدن دوباره ساخته بشن
  }

  // Future<void> fetchHomeDevices() async {
  //   try {
  //     final token = await UserStoreService.to.getToken();
  //     if (token == null) return;

  //     final headers = {'Authorization': 'Bearer $token'};

  //     final dio = Dio();
  //     final response = await dio.post(
  //       'http://45.149.76.245:8080/api/dashboard/getHome',
  //       options: Options(headers: headers),
  //     );

  //     if (response.statusCode == 200) {
  //       final data = response.data;

  //       final devicesJson = data as List? ?? [];

  //       dashboardDevices.value = devicesJson
  //           .map((e) => DeviceItem.fromJson(e))
  //           .toList();
  //     } else {
  //       Get.snackbar(
  //         "خطا",
  //         "دریافت دستگاه‌های داشبورد موفق نبود: ${response.statusCode}",
  //       );
  //     }
  //   } catch (e) {
  //     Get.snackbar("خطا", "اشکال در ارتباط با سرور: $e");
  //   }
  // }

  Future<void> fetchHomeDevices() async {
  try {
    final token = await UserStoreService.to.getToken();
    if (token == null) return;

    /// 1) کش را اول بخوان
    final cached = box.get('home_devices');
    if (cached != null) {
      dashboardDevices.value = (cached as List)
          .map((e) => DeviceItem.fromJson(Map<String, dynamic>.from(e)))
          .toList();
      print("📦 Loaded home devices from cache");
    }

    /// 2) اینترنت
    final dio = Dio();
    final response = await dio.post(
      'http://45.149.76.245:8080/api/dashboard/getHome',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );

    if (response.statusCode == 200) {
      final devicesJson = response.data as List? ?? [];

      dashboardDevices.value =
          devicesJson.map((e) => DeviceItem.fromJson(e)).toList();

      /// 3) ذخیره مجدد روی کش
      box.put(
        'home_devices',
        dashboardDevices.map((e) => e.toJson()).toList(),
      );
      print("💾 Saved home devices to cache");
    }
  } catch (e) {
    print("❌ fetchHomeDevices error: $e");
  }
}


  // ------------------- User Locations -------------------
  // Future<void> fetchUserLocations() async {
  //   try {
  //     if (token.isEmpty) return;

  //     final url = Uri.parse('http://45.149.76.245:8080/api/dashboard/list');
  //     final data = json.encode({
  //       "sortProperty": "createdTime",
  //       "pageSize": 10,
  //       "page": 0,
  //       "sortOrder": "ASC",
  //     });

  //     final response = await http.post(
  //       url,
  //       headers: {
  //         'Authorization': 'Bearer $token',
  //         'Content-Type': 'application/json',
  //       },
  //       body: data,
  //     );

  //     if (response.statusCode == 200) {
  //       final model = UserLocationsResponseModel.fromJson(
  //         json.decode(response.body),
  //       );
  //       userLocations.value = model.data;
  //     } else {
  //       print('Failed to fetch locations: ${response.statusCode}');
  //     }
  //   } catch (e) {
  //     print('Error fetching user locations: $e');
  //   }
  // }

  Future<void> fetchUserLocations() async {
  try {
    /// 1) همیشه اول سعی کن از کش بخونی
    final cached = box.get('user_locations');
    if (cached != null) {
      userLocations.value = (cached as List)
          .map((e) => LocationItem.fromJson(Map<String, dynamic>.from(e)))
          .toList();
      print("📦 Loaded user locations from cache");
    }

    if (token.isEmpty) return;

    /// 2) تلاش برای دریافت از سرور
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

      /// 3) ذخیره در کش
      final listToCache = model.data.map((e) => e.toJson()).toList();
      box.put('user_locations', listToCache);
      print("💾 Locations saved in cache");
    }
  } catch (e) {
    print("❌ fetchUserLocations error: $e");
  }
}


  // ------------------- Devices by Location -------------------
  // Future<void> fetchDevicesByLocation(String dashboardId) async {
  //   try {
  //     print('Fetching devices for dashboardId: $dashboardId');
  //     if (token.isEmpty) return;

  //     final url = Uri.parse(
  //       'http://45.149.76.245:8080/api/dashboard/getDeviceList',
  //     );
  //     final body = json.encode({"dashboardId": dashboardId});

  //     final response = await http.post(
  //       url,
  //       headers: {
  //         'Authorization': 'Bearer $token',
  //         'Content-Type': 'application/json',
  //       },
  //       body: body,
  //     );

  //     if (response.statusCode == 200) {
  //       final raw = json.decode(response.body);
  //       print("Raw response: $raw");

  //       if (raw is List) {
  //         // فقط Map<String, dynamic> ها رو نگه می‌داره
  //         final safeData = raw
  //             .whereType<Map<String, dynamic>>()
  //             .map((d) => DeviceItem.fromJson(d))
  //             .toList();

  //         deviceList.value = safeData;
  //         deviceList.refresh();

  //         print('✅ Devices parsed: ${deviceList.length}');
  //       } else {
  //         print("❌ Unexpected format: ${raw.runtimeType}");
  //         deviceList.clear();
  //       }
  //     } else {
  //       print('❌ Failed to fetch devices: ${response.statusCode}');
  //       deviceList.clear();
  //     }
  //   } catch (e, st) {
  //     print('❌ Error fetching devices: $e');
  //     print(st);
  //     deviceList.clear();
  //   }
  // }

  Future<void> fetchDevicesByLocation(String dashboardId) async {
  try {
    /// 1) ابتدا کش را بخوان
    final cached = box.get('devices_$dashboardId');
    if (cached != null) {
      deviceList.value = (cached as List)
          .map((e) => DeviceItem.fromJson(Map<String, dynamic>.from(e)))
          .toList();

      print("📦 Loaded devices from cache for $dashboardId");
    }

    if (token.isEmpty) return;

    /// 2) درخواست سرور
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

      if (raw is List) {
        final safeData = raw
            .whereType<Map<String, dynamic>>()
            .map((d) => DeviceItem.fromJson(d))
            .toList();

        deviceList.value = safeData;

        /// 3) ذخیره در کش برای این لوکیشن
        box.put(
          'devices_$dashboardId',
          safeData.map((e) => e.toJson()).toList(),
        );

        print("💾 Saved devices in cache for $dashboardId");
      }
    }
  } catch (e) {
    print("❌ fetchDevicesByLocation error: $e");
  }
}


  // ------------------- Refresh All -------------------
  // Future<void> refreshAllData() async {
  //   try {
  //     isRefreshing.value = true;
  //     final tokenService = Get.find<TokenRefreshService>();
  //     await tokenService.checkAndRefreshToken();
  //     await fetchUserLocations();
  //     deviceList.clear();
  //     await refreshWeather();
  //     await fetchHomeDevices();
  //   } catch (e) {
  //     print('Error refreshing data: $e');
  //   } finally {
  //     isRefreshing.value = false;
  //   }
  // }


//   Future<void> refreshAllData() async {
//   try {
//     isRefreshing.value = true;

//     // ۱. چک و رفرش توکن
//     final tokenService = Get.find<TokenRefreshService>();
//     await tokenService.checkAndRefreshToken();

//     // ۲. برو مکان‌ها رو دوباره بگیر
//     await fetchUserLocations();

//     // ۳. اگر کاربر الان مکانی انتخاب کرده، دستگاه‌هایش را هم بیا 👇
//     if (selectedLocationId.value.isNotEmpty) {
//       await fetchDevicesByLocation(selectedLocationId.value);
//     }

//     // ۴. داده‌های آب‌وهوا و داشبورد کلی
//     await refreshWeather();
//     await fetchHomeDevices();
//   } catch (e) {
//     print('❌ Error refreshing data: $e');
//   } finally {
//     isRefreshing.value = false;
//   }
// }

Future<void> refreshAllData() async {
  try {
    isRefreshing.value = true;

    final tokenService = Get.find<TokenRefreshService>();
    await tokenService.checkAndRefreshToken();

    await fetchUserLocations();

    if (selectedLocationId.value.isNotEmpty) {
      await fetchDevicesByLocation(selectedLocationId.value);
    }

    await refreshWeather();
    await fetchHomeDevices();

  } catch (e) {
    print("❌ Error in refreshAllData: $e");
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

Future<void> addLocation(String title, {int? iconIndex}) async {
  if (title.trim().isEmpty) {
    Get.snackbar('خطا', 'لطفاً نام مکان را وارد کنید',
      backgroundColor: Colors.red, colorText: Colors.white);
    return;
  }

  try {
    final url = Uri.parse('http://45.149.76.245:8080/api/dashboard/addOrUpdate');
    final headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
    final data = json.encode({
      "title": title.trim(),
      if (iconIndex != null) "iconIndex": iconIndex,
    });

    final response = await http.post(url, headers: headers, body: data);

    if (response.statusCode == 200) {
      Get.snackbar('موفقیت', 'مکان با موفقیت اضافه شد',
          backgroundColor: Colors.green, colorText: Colors.white);
      await fetchUserLocations();
    } else {
      Get.snackbar('خطا', 'ثبت مکان موفقیت‌آمیز نبود: ${response.statusCode}',
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  } catch (e) {
    Get.snackbar('خطا', 'خطا در افزودن مکان: $e',
        backgroundColor: Colors.red, colorText: Colors.white);
  }
}


Future<void> updateLocation({
  required String title,
  String? dashboardId,
  int? iconIndex,
}) async {
  if (title.trim().isEmpty) {
    Get.snackbar('خطا', 'لطفاً نام مکان را وارد کنید',
        backgroundColor: Colors.red, colorText: Colors.white);
    return;
  }

  try {
    final url = Uri.parse('http://45.149.76.245:8080/api/dashboard/addOrUpdate');
    final headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
    final body = {
      "title": title.trim(),
      if (dashboardId != null && dashboardId.isNotEmpty) "id": dashboardId,
      if (iconIndex != null) "iconIndex": iconIndex,
    };

    final response = await http.post(url, headers: headers, body: json.encode(body));

    if (response.statusCode == 200) {
      Get.snackbar(
        'موفقیت',
        dashboardId != null ? 'مکان با موفقیت ویرایش شد' : 'مکان با موفقیت اضافه شد',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      await fetchUserLocations();
    } else {
      Get.snackbar('خطا', 'عملیات ناموفق بود: ${response.statusCode}',
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  } catch (e) {
    Get.snackbar('خطا', 'خطا در برقراری ارتباط با سرور: $e',
        backgroundColor: Colors.red, colorText: Colors.white);
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
/// برمی‌گرداند null اگر حذف موفق بود، و متن خطا اگر حذف نشد
Future<String?> deleteDashboardItem({
  required String id,
  required String title,
  required int displayOrder,
  required int iconIndex,
}) async {
  final headers = {
    'Authorization': 'Bearer $token',
    'Content-Type': 'application/json',
  };

  var data = json.encode({
    "title": title,
    "displayOrder": displayOrder,
    "iconIndex": iconIndex,
  });

  try {
    final dio = Dio();
    var response = await dio.request(
      '$serverUrl/api/dashboard/remove/$id',
      options: Options(
        method: 'DELETE',
        headers: headers,
      ),
      data: data,
    );

    if (response.statusCode == 200) {
      print('✅ حذف موفق: ${response.data}');
      return null; // موفقیت
    } else {
      print('❌ خطای سرور: ${response.data}');
      // اگر سرور JSON با فیلد message داده، برگردان
      if (response.data is Map && response.data['message'] != null) {
        return response.data['message'];
      }
      return 'خطای نامشخص سرور';
    }
  } on DioException catch (e) {
    if (e.response != null) {
      print('🚨 خطای سرور (status code ${e.response?.statusCode}): ${e.response?.data}');
      if (e.response?.data is Map && e.response?.data['message'] != null) {
        return e.response?.data['message'];
      }
      return 'خطای نامشخص سرور';
    } else {
      print('🚨 خطای شبکه یا timeout: ${e.message}');
      return 'خطای شبکه یا timeout';
    }
  } catch (e) {
    print('🚨 خطای دیگر: $e');
    return 'خطای داخلی برنامه';
  }
}

}
