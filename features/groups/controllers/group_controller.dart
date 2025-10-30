import 'package:flutter/foundation.dart';
import 'package:my_app32/app/models/weather_models.dart';
import 'package:my_app32/app/services/token_refresh_service.dart';
import 'package:my_app32/app/services/weather_service.dart';
import 'package:my_app32/features/groups/models/customer_device_model.dart';
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
  final TextEditingController descriptionControllerGroup =
      TextEditingController();

  RxList<LocationItem> userLocationsGroup = <LocationItem>[].obs;
  RxList<DeviceItem> deviceListGroup = <DeviceItem>[].obs;
  RxBool isLoadingGroup = false.obs;
  RxBool isRefreshingGroup = false.obs;
  String tokenGroup = '';
  RxString selectedLocationIdGroup = ''.obs;
  late Future<WeatherData> weatherFutureGroup;
  var groups = <Map<String, dynamic>>[].obs;
  var isLoading = false.obs;
  // لیست کاربران یک گروه
  var groupUsers = <Map<String, dynamic>>[].obs;
  RxBool isRefreshing = false.obs;

  @override
  void onInit() {
    super.onInit();
    initializeTokenGroup();

    // مقدار اولیه آب‌وهوا
    weatherFutureGroup = WeatherApiService(
      apiKey: 'e6f7286f932ef4636fdfb82a45266d17',
    ).getWeather(lat: 35.7219, lon: 51.3347);
  }

  Future<void> initializeTokenGroup() async {
    tokenGroup = await UserStoreService.to.getToken() ?? '';
    if (tokenGroup.isNotEmpty) {
      await fetchUserLocationsGroup();
      await fetchGroups(); // fetchGroups بعد از آماده شدن توکن
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
        headers: {
          'Authorization': 'Bearer $tokenGroup',
          'Content-Type': 'application/json',
        },
        body: data,
      );

      if (response.statusCode == 200) {
        final model = UserLocationsResponseModel.fromJson(
          json.decode(response.body),
        );
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

      final url = Uri.parse(
        'http://45.149.76.245:8080/api/dashboard/getDeviceList',
      );
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
        'Content-Type': 'application/json',
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
        headers: {
          'Authorization': 'Bearer $tokenGroup',
          'Content-Type': 'application/json',
        },
        body: json.encode({'customerId': deviceIdGroup}),
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
        'Authorization': 'Bearer $tokenGroup',
        'Content-Type': 'application/json',
      };
      final data = json.encode({"title": titleGroup.trim()});

      final response = await http.post(url, headers: headers, body: data);

      if (response.statusCode == 200) {
        Get.snackbar(
          'موفقیت',
          'مکان با موفقیت اضافه شد',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        await fetchUserLocationsGroup();
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
  // -----------------------------------------------------------

  Future<String?> saveGroup(String title, String description) async {
    if (title.trim().isEmpty) {
      Get.snackbar("خطا", "نام گروه را وارد کنید");
      return null;
    }

    try {
      final headers = {
        'Authorization': 'Bearer $tokenGroup',
        'Content-Type': 'application/json',
      };

      final data = json.encode({"title": title, "description": description});

      var dio = Dio();
      var response = await dio.request(
        'http://45.149.76.245:8080/api/customer/save',
        options: Options(method: 'POST', headers: headers),
        data: data,
      );

      if (response.statusCode == 200) {
        final raw = response.data;
        final savedId = raw["id"]?.toString() ?? raw["customerId"]?.toString();
        if (savedId != null) {
          Get.snackbar("موفقیت", "گروه با موفقیت ثبت شد");
          return savedId;
        } else {
          Get.snackbar("خطا", "آی‌دی از سرور دریافت نشد");
        }
      } else {
        Get.snackbar("خطا", response.statusMessage ?? "خطای ناشناخته");
      }
    } catch (e) {
      Get.snackbar("خطا", e.toString());
    }
    return null;
  }

  Future<String?> updateGroup({
    required String customerId,
    required String title,
    required String description,
  }) async {
    if (title.trim().isEmpty) {
      Get.snackbar("خطا", "نام گروه را وارد کنید");
      return null;
    }
    print(customerId);
    try {
      final headers = {
        'Authorization': 'Bearer $tokenGroup',
        'Content-Type': 'application/json',
      };

      final data = json.encode({
        "customerId": customerId, // اینجا هم id رو بفرستید چون ویرایش هست
        "title": title,
        "description": description,
      });

      var dio = Dio();
      var response = await dio.request(
        'http://45.149.76.245:8080/api/customer/save',
        options: Options(method: 'POST', headers: headers),
        data: data,
      );

      if (response.statusCode == 200) {
        final raw = response.data;
        final savedId = raw["id"]?.toString() ?? raw["customerId"]?.toString();
        if (savedId != null) {
          Get.snackbar("موفقیت", "گروه با موفقیت ثبت شد");
          return savedId;
        } else {
          Get.snackbar("خطا", "آی‌دی از سرور دریافت نشد");
        }
      } else {
        Get.snackbar("خطا", response.statusMessage ?? "خطای ناشناخته");
      }
    } catch (e) {
      Get.snackbar("خطا", e.toString());
    }
    return null;
  }

  Future<bool> assignDevicesPayload(
    List<DeviceItem> selectedDevices,
    String customerId,
  ) async {
    if (selectedDevices.isEmpty) {
      Get.snackbar('خطا', 'هیچ دستگاهی برای ارسال موجود نیست');
      return false;
    }

    try {
      // ساخت payload مشابه Postman
      final payload = selectedDevices.map((device) {
        return {
          "customerId": customerId,
          "deviceId": device.deviceId,
          "dashboardId": device.dashboardId,
        };
      }).toList();

      final headers = {
        'Authorization': 'Bearer $tokenGroup',
        'Content-Type': 'application/json',
      };

      print('assignToCustomer payload: $payload');

      var dio = Dio();
      final response = await dio.post(
        'http://45.149.76.245:8080/api/device/assignToCustomer',
        data: payload, // ❌ بدون json.encode
        options: Options(headers: headers),
      );

      print('Status code: ${response.statusCode}');
      print('Response data: ${response.data}');

      if (response.statusCode == 200) {
        Get.snackbar('موفق', 'دستگاه‌ها با موفقیت اختصاص داده شدند');
        return true;
      } else {
        Get.snackbar('خطا', response.statusMessage ?? 'خطای سرور');
        return false;
      }
    } catch (e, st) {
      print('Error in assignDevicesPayload: $e');
      print(st);
      Get.snackbar('خطا', e.toString());
      return false;
    }
  }

  /// دریافت اطلاعات دستگاه‌ها برای یک گروه خاص
  Future<List<CustomerDevice>> fetchCustomerDeviceInfos(
    String customerId,
  ) async {
    try {
      if (tokenGroup.isEmpty) return [];

      final headers = {
        'Authorization': 'Bearer $tokenGroup',
        'Content-Type': 'application/json',
      };

      final data = json.encode({
        "sortProperty": "createdTime",
        "pageSize": 10,
        "page": 0,
        "sortOrder": "ASC",
        "customerId": customerId,
      });

      var dio = Dio();
      final response = await dio.request(
        'http://45.149.76.245:8080/api/customer/deviceInfos/list',
        options: Options(method: 'POST', headers: headers),
        data: data,
      );

      if (response.statusCode == 200) {
        final raw = response.data['data'] as List;
        print("✅ DeviceInfos fetched: ${raw.length}");
        return raw.map((e) => CustomerDevice.fromJson(e)).toList();
      } else {
        print("❌ Failed to fetch deviceInfos: ${response.statusMessage}");
        return [];
      }
    } catch (e, st) {
      print("❌ Error fetching deviceInfos: $e");
      print(st);
      return [];
    }
  }

  Future<void> fetchGroups() async {
    try {
      isLoading.value = true;

      final headers = {
        'Authorization': 'Bearer $tokenGroup',
        'Content-Type': 'application/json',
      };
      final data = json.encode({
        "sortProperty": "createdTime",
        "pageSize": 100,
        "page": 0,
        "sortOrder": "ASC",
      });

      var dio = Dio();
      final response = await dio.request(
        'http://45.149.76.245:8080/api/customers/list',
        options: Options(method: 'POST', headers: headers),
        data: data,
      );

      if (response.statusCode == 200) {
        print(response.data['data']);
        final dataList = response.data['data'] as List;
        groups.value = dataList
            .map(
              (e) => {
                "customerId": e['customerId'],
                "title": e['title'],
                "allocatedDevices": e['allocatedDevices'],
                "allocatedUsers": e['allocatedUsers'],
                "description": e['description'],
              },
            )
            .toList();
      } else {
        Get.snackbar('خطا', 'دریافت گروه‌ها ناموفق بود');
      }
    } catch (e) {
      Get.snackbar('خطا', 'خطا در دریافت گروه‌ها: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // ------------------- Customers / Users -------------------

  /// گرفتن لیست مشتریان (کاربران) یک گروه
  Future<void> fetchGroupUsers(String customerId) async {
    try {
      final headers = {
        'Authorization': 'Bearer $tokenGroup',
        'Content-Type': 'application/json',
      };

      final data = json.encode({
        "sortProperty": "createdTime",
        "pageSize": 10,
        "page": 0,
        "sortOrder": "ASC",
        "customerId": customerId,
      });

      var dio = Dio();
      final response = await dio.request(
        'http://45.149.76.245:8080/api/customer/userInfos/list',
        options: Options(method: 'POST', headers: headers),
        data: data,
      );

      if (response.statusCode == 200) {
        final users = response.data['data'] as List;
        print(users);
        groupUsers.value = users
            .map(
              (e) => {
                "id": e['userId'],
                "firstName": e['firstName'],
                "lastName": e['lastName'],
                "phoneNumber": e['phoneNumber'],
              },
            )
            .toList();
        print("✅ Users fetched: ${groupUsers.length}");
      } else {
        Get.snackbar(
          'خطا',
          response.statusMessage ?? 'ناموفق در گرفتن لیست مشتریان',
        );
      }
    } catch (e, st) {
      print('❌ Error fetching group users: $e');
      print(st);
    }
  }

  /// ارسال کد تایید به شماره موبایل
  Future<bool> sendVerificationCode(String phoneNumber) async {
    try {
      // اگر شماره با 98 شروع شد → تبدیل به 0
      if (phoneNumber.startsWith("98")) {
        phoneNumber = "0${phoneNumber.substring(2)}";
      }

      final headers = {
        'Authorization': 'Bearer $tokenGroup',
        'Content-Type': 'application/json',
      };

      final data = json.encode({"phoneNumber": phoneNumber});

      print("📩 Sending request with: $data");

      var dio = Dio();
      final response = await dio.request(
        'http://45.149.76.245:8080/api/user/customer/sendVerificationCode',
        options: Options(method: 'POST', headers: headers),
        data: data,
      );

      print("📥 Response: ${response.statusCode} => ${response.data}");

      if (response.statusCode == 200) {
        Get.snackbar("موفقیت", "کد تایید ارسال شد");
        return true;
      } else {
        Get.snackbar("خطا", response.statusMessage ?? "خطای ارسال کد");
        return false;
      }
    } catch (e, st) {
      print("❌ Exception: $e");
      print(st);
      Get.snackbar("خطا", e.toString());
      return false;
    }
  }

  /// افزودن نهایی مشتری جدید
  Future<bool> addNewCustomer({
    required String customerId,
    required String firstName,
    required String lastName,
    required String phoneNumber,
    required String verificationCode,
  }) async {
    try {
      // شماره به فرمت با صفر
      if (phoneNumber.startsWith("98")) {
        phoneNumber = "0${phoneNumber.substring(2)}";
      }

      final headers = {
        'Authorization': 'Bearer $tokenGroup',
        'Content-Type': 'application/json',
      };

      final data = json.encode({
        "customerId": customerId,
        "firstName": firstName,
        "lastName": lastName,
        "phoneNumber": phoneNumber,
        "verifyCode": verificationCode, // 👈 تغییر اصلی
      });

      print("📤 Add customer payload: $data");

      var dio = Dio();
      final response = await dio.request(
        'http://45.149.76.245:8080/api/user/signup',
        options: Options(method: 'POST', headers: headers),
        data: data,
      );

      print("📥 Response: ${response.statusCode} => ${response.data}");

      if (response.statusCode == 200) {
        Get.snackbar("موفقیت", "مشتری جدید با موفقیت اضافه شد");
        return true;
      } else {
        Get.snackbar("خطا", response.statusMessage ?? "خطای افزودن مشتری");
        return false;
      }
    } catch (e, st) {
      print("❌ Exception: $e");
      print(st);
      Get.snackbar("خطا", e.toString());
      return false;
    }
  }

  /// حذف یک گروه (مشتری) با استفاده از customerId
  Future<bool> deleteGroup(String customerId) async {
    try {
      if (tokenGroup.isEmpty) {
        Get.snackbar('خطا', 'توکن یافت نشد');
        return false;
      }

      final headers = {
        'Authorization': 'Bearer $tokenGroup',
        'Content-Type': 'application/json',
      };

      final data = json.encode({"customerId": customerId});

      var dio = Dio();
      final response = await dio.request(
        'http://45.149.76.245:8080/api/customer/delete',
        options: Options(method: 'DELETE', headers: headers),
        data: data,
      );

      if (response.statusCode == 200) {
        print("✅ Group deleted: ${response.data}");
        Get.snackbar("موفقیت", "گروه با موفقیت حذف شد");
        await fetchGroups(); // بعد از حذف، لیست گروه‌ها دوباره دریافت بشه
        return true;
      } else {
        print("❌ Delete failed: ${response.statusMessage}");
        Get.snackbar("خطا", response.statusMessage ?? "خطای ناشناخته");
        return false;
      }
    } catch (e, st) {
      print("❌ Exception in deleteGroup: $e");
      print(st);
      Get.snackbar("خطا", e.toString());
      return false;
    }
  }

  Future<bool> unassignDeviceFromCustomer({
    required String customerId,
    required String deviceId,
  }) async {
    final dio = Dio();
    final headers = {
      'Authorization': 'Bearer $tokenGroup',
      'Content-Type': 'application/json',
    };

    final data = json.encode({"customerId": customerId, "deviceId": deviceId});

    print(tokenGroup);
    print(data);

    try {
      final response = await dio.request(
        'http://45.149.76.245:8080/api/device/unassignFromCustomer',
        options: Options(method: 'POST', headers: headers),
        data: data,
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        debugPrint('❌ Unassign failed: ${response.statusMessage}');
        return false;
      }
    } catch (e) {
      debugPrint('⚠️ Dio error: $e');
      return false;
    }
  }

  // تابع حذف مشتری از گروه
  Future<bool> removeCustomerFromGroup(
    String customerId,
    String groupId,
  ) async {
    final dio = Dio();
    final headers = {
      'Authorization': 'Bearer $tokenGroup',
      'Content-Type': 'application/json',
    };

    try {
      final response = await dio.request(
        'http://45.149.76.245:8080/api/user/$customerId',
        options: Options(method: 'DELETE', headers: headers),
      );

      print(customerId);
      print(groupId);

      if (response.statusCode == 200) {
        print('✅ حذف موفق: ${json.encode(response.data)}');
        // بعد از حذف، لیست کاربران گروه را به‌روزرسانی کن
        await fetchGroupUsers(groupId);
        return true;
      } else {
        print('❌ خطا در حذف: ${response.statusMessage}');
        return false;
      }
    } catch (e) {
      print('⚠️ Dio error: $e');
      return false;
    }
  }
}
