// import 'package:flutter/foundation.dart';
import 'package:my_app32/app/services/token_refresh_service.dart';
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
  List<DashboardItemModel>? dashboards;
  RxBool isLoading = RxBool(false);
  String token = '';

  // Add device list for new API
  RxList<Map<String, dynamic>> deviceList = <Map<String, dynamic>>[].obs;

  // Refresh state
  RxBool isRefreshing = false.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeToken();
  }

  Future<void> _initializeToken() async {
    token = await UserStoreService.to.getToken() ?? '';
    getUserId();
    getDashboard();
    fetchDevicesFromNewApi();
  }

  Future<void> getUserId() async {
    await _repo.getCurrentUSer().then((GetCurrentUserResponseModel result) {
      responseHandler(
        statusCode: result.statusCode!,
        message: result.message ?? '',
        onSuccess: () {
          UserStoreService.to.save(
            key: "customerId",
            value: result.data?.customerId?.id ?? '',
          );
          debugPrint("Customer ID: ${result.data?.customerId?.id}");
        },
      );
    });
  }

  Future<void> getDashboard() async {
    isLoading(true);
    GetDashboardsRequestModel requestModel = GetDashboardsRequestModel(
      pageSize: 20,
      page: 0,
      mobile: 'true',
      sortOrder: sortOrder.DESC.name,
      sortProperty: GetDashboardsSortProperty.createdTime.name,
    );

    await _repo.getDashboards(requestModel: requestModel).then((
      DashboardResponseModel result,
    ) {
      isLoading(false);
      responseHandler(
        statusCode: result.statusCode!,
        message: result.message ?? '',
        onSuccess: () {
          dashboards = result.data?.data;
        },
      );
    });
  }

  Future<void> createDashboard(String title, String description) async {
    isLoading(true);
    CreateDashboardRequestModel requestModel = CreateDashboardRequestModel(
      title: title,
      description: description,
    );

    await _repo.createOrUpdateDashboard(requestModel: requestModel).then((
      CreateDashboardResponseModel result,
    ) {
      isLoading(false);
      responseHandler(
        statusCode: result.statusCode!,
        message: result.message ?? '',
        onSuccess: () {
          getDashboard();
          debugPrint(result.message ?? '');
        },
      );
    });
  }

  Future? onTapAddDevice() => Get.toNamed(AppRoutes.ADD_DEVICE);

  void onTapItem(DashboardItemModel? dashboard) =>
      Get.toNamed(AppRoutes.DASHBOARD_ITEM_DETAIL, arguments: dashboard);

  Future<void> fetchDevicesFromNewApi() async {
    final url = Uri.parse('http://45.149.76.245:8080/api/dashboard/getFirst');
    try {
      final response = await http.post(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        deviceList.value = List<Map<String, dynamic>>.from(data);
        print('Fetched devices: ${deviceList.length}');

        // Extract device IDs and update socket service
        final deviceIds = deviceList
            .where((device) => device['deviceId'] != null)
            .map((device) => device['deviceId'].toString())
            .toList();

        // Update the HomeDevicesController with new device IDs and colors
        // final homeDevicesController = Get.find<HomeDevicesController>();
        // homeDevicesController.updateDeviceIds(deviceIds);

        // // Update device colors for each device
        // for (final device in deviceList) {
        //   final deviceId = device['deviceId']?.toString();
        //   if (deviceId != null && device['ledColor'] != null) {
        //     homeDevicesController.updateDeviceColors(
        //       deviceId,
        //       device['ledColor'],
        //     );
        //   }
        // }

        // Force refresh device states to get accurate initial state
        // await homeDevicesController.forceRefreshDeviceStates();

        // Force UI update
        deviceList.refresh();

        print('Updated socket with device IDs: $deviceIds');
        print('Updated device colors for ${deviceList.length} devices');
      } else {
        print('Failed to fetch devices: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching devices: $e');
    }
  }

  // Method to refresh all data (devices and weather)
  Future<void> refreshAllData() async {
    try {
      isRefreshing.value = true;

      // Check and refresh token if needed
      final tokenRefreshService = Get.find<TokenRefreshService>();
      await tokenRefreshService.checkAndRefreshToken();

      // Refresh devices from dashboard API
      await fetchDevicesFromNewApi();

      // Refresh device states
      // final homeDevicesController = Get.find<HomeDevicesController>();
      // await homeDevicesController.refreshDeviceStates();

      // Refresh dashboard data
      await getDashboard();

      print('All data refreshed successfully');
      print('Device list updated: ${deviceList.length} devices');

      // Show success message
      Get.snackbar(
        'بروزرسانی',
        'اطلاعات با موفقیت بروزرسانی شد',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      print('Error refreshing data: $e');

      // Show error message
      Get.snackbar(
        'خطا',
        'خطا در بروزرسانی اطلاعات',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } finally {
      isRefreshing.value = false;
    }
  }


  Future<void> removeDevice(String deviceId) async {
    try {
      final response = await http.post(
        Uri.parse('http://45.149.76.245:8080/api/device/remove'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({'id': deviceId}),
      );

      if (response.statusCode == 200) {
        // Remove device from local list
        deviceList.removeWhere((device) => device['deviceId'] == deviceId);
        Get.snackbar('موفق', 'دستگاه حذف شد');
      } else {
        Get.snackbar(
          'Error',
          'Failed to remove device: ${response.statusCode}',
        );
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to remove device: $e');
    }
  }

  String getDeviceTypeName(String code) {
    switch (code) {
      case '02':
        return 'Smart Light';
      // Add more mappings as needed
      default:
        return 'Unknown';
    }
  }
}
