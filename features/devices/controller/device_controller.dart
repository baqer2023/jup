import 'package:get/get.dart';
import 'package:my_app32/app/store/user_store_service.dart';
import 'package:my_app32/features/devices/models/device_mode.dart';
import 'package:my_app32/features/devices/repository/device_repositoy.dart';

class DeviceController extends GetxController {
  final deviceRepo = DeviceRepository();

  var devices = <DeviceModel>[].obs;
  var isLoading = false.obs;
  var token = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeToken();
  }

  Future<void> _initializeToken() async {
    token.value = await UserStoreService.to.getToken() ?? '';
    fetchDevices();
  }

  Future<void> fetchDevices() async {
    if (token.value.isEmpty) return;

    isLoading.value = true;

    final response = await deviceRepo.getFirstDashboardData(token: token.value);

    isLoading.value = false;

    if (response == null) {
      devices.clear();
      return;
    }

    try {
      List<dynamic> rawList = [];

      if (response is List) {
        rawList = response;
      } else if (response is Map) {
        rawList = [response]; // wrap Map در لیست
      } else {
        // هر نوع دیگه‌ای → خالی
        devices.clear();
        return;
      }

      devices.value = DeviceModel.listFromJson(rawList);
      print("✅ Parsed devices: ${devices.length}");
    } catch (e) {
      devices.clear();
      print("❌ Parsing error: $e");
    }
  }
}
