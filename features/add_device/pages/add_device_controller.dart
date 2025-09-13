import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:multicast_dns/multicast_dns.dart';
import 'package:my_app32/app/core/app_utils_mixin.dart';
import 'package:my_app32/features/add_device/models/credential_request_model.dart';
import 'package:my_app32/features/add_device/models/credential_response_model.dart';
import 'package:my_app32/features/add_device/models/custom_cmd_request_model.dart';
import 'package:my_app32/features/add_device/repository/add_device_repository.dart';

class AddDeviceController extends GetxController with AppUtilsMixin {
  AddDeviceController(this._repo);

  final AddDeviceRepository _repo;

  // Text Controllers
  final ssidTEC = TextEditingController();
  final passwordTEC = TextEditingController();
  final nameTEC = TextEditingController();

  // Observables
  final RxnString deviceIp = RxnString(); // Nullable string for device IP
  final RxBool isLoading = false.obs;
  //final RxString statusMessage = 'در جستجوی دستگاه...'.obs;

  @override
  void onClose() {
    ssidTEC.dispose();
    passwordTEC.dispose();
    nameTEC.dispose();
    super.onClose();
  }

  /// Discover ESP32 device using mDNS
  Future<void> discoverDevice() async {
    //statusMessage.value = 'در حال جستجو...';
    deviceIp.value = null;
    final MDnsClient client = MDnsClient();

    try {
      await client.start();

      await for (final PtrResourceRecord ptr
          in client.lookup<PtrResourceRecord>(
            ResourceRecordQuery.serverPointer('_http._tcp.local'),
          )) {
        await for (final SrvResourceRecord srv
            in client.lookup<SrvResourceRecord>(
              ResourceRecordQuery.service(ptr.domainName),
            )) {
          await for (final IPAddressResourceRecord ip
              in client.lookup<IPAddressResourceRecord>(
                ResourceRecordQuery.addressIPv4(srv.target),
              )) {
            if (srv.target.contains('esp32')) {
              debugPrint('✅ ESP32 Found: ${ip.address.address}');
              deviceIp.value = ip.address.address;
              //statusMessage.value = 'دستگاه یافت شد: ${ip.address.address}';
              return;
            }
          }
        }
      }

      //statusMessage.value = 'دستگاه یافت نشد';
      showErrorSnackbar('دستگاه یافت نشد');
    } catch (e) {
      debugPrint('❌ Discovery Error: $e');
      //statusMessage.value = 'خطا در جستجو';
      showErrorSnackbar('خطا در جستجوی دستگاه');
    } finally {
      client.stop();
    }
  }

  /// Send WiFi credentials to device
  Future<void> submitData() async {
    final ip = deviceIp.value;
    final baseUrl = ip != null ? 'http://$ip/' : null;
    // if (ip == null) {
    //   showErrorSnackbar('لطفا ابتدا دستگاه را جستجو کنید');
    //   return;
    // }
    if (baseUrl == null) {
      // Skip request or handle gracefully
      return;
    }

    isLoading.value = true;
    final requestModel = CredentialRequestModel(
      ssid: ssidTEC.text.trim(),
      password: passwordTEC.text,
    );

    try {
      final response = await _repo.submitCredential(
        requestModel: requestModel,
        baseUrl: 'http://$ip/',
      );

      responseHandler(
        statusCode: response.statusCode ?? 0,
        message: response.message ?? '',
        onSuccess: () => showSuccessSnackbar('مشخصات ارسال شد'),
      );
    } catch (e) {
      showErrorSnackbar('❌ ارسال اطلاعات با خطا مواجه شد');
      debugPrint('submitData Error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Send custom command to device
  Future<void> sendCustomCommand(String attribute, String value) async {
    final ip = deviceIp.value;
    if (ip == null) {
      showErrorSnackbar('لطفا ابتدا دستگاه را جستجو کنید');
      return;
    }

    isLoading.value = true;
    final requestModel = CustomCmdRequestModel(
      atributte: attribute,
      value: value,
    );

    try {
      final response = await _repo.sendCustomCommand(
        requestModel: requestModel,
        baseUrl: 'http://$ip/',
      );

      responseHandler(
        statusCode: response.statusCode ?? 0,
        message: response.message ?? '',
        onSuccess: () => showSuccessSnackbar('فرمان ارسال شد'),
      );
    } catch (e) {
      showErrorSnackbar('❌ ارسال فرمان با خطا مواجه شد');
      debugPrint('sendCustomCommand Error: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
