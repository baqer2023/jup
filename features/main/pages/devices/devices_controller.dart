import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_app32/app/core/app_enums.dart';
import 'package:my_app32/app/core/app_utils_mixin.dart';
import 'package:my_app32/app/store/user_store_service.dart';
import 'package:my_app32/features/main/models/devices/create_device_request_model.dart';
import 'package:my_app32/features/main/models/devices/create_device_response_model.dart';
import 'package:my_app32/features/main/models/devices/default_profile_info_respons_model.dart';
import 'package:my_app32/features/main/models/devices/get_devices_request_model.dart';
import 'package:my_app32/features/main/models/devices/get_devices_response_model.dart';
import 'package:my_app32/features/main/models/devices/remove_device_request_model.dart';
import 'package:my_app32/features/main/repository/devices_repository.dart';

class DevicesController extends GetxController with AppUtilsMixin {
  DevicesController(this._repo);

  final DevicesRepository _repo;
  late List<Datum>? devices;
  late NewDeviceProfileId? defaultProfileId;
  String? authToken;

  final TextEditingController titleController = TextEditingController();

  @override
  void onInit() async {
    authToken = await UserStoreService.to.getToken();
    print('Auth token set in DevicesController: $authToken');
    getDevices();
    getDefaultProfileId();
    super.onInit();
  }

  void setAuthToken(String token) {
    authToken = token;
    print('Auth token set in DevicesController: $authToken');
  }

  Future<void> getDevices() async {
    isLoading(true);
    GetDevicesRequestModel requestModel = GetDevicesRequestModel(
      pageSize: 20,
      page: 0,
      sortOrder: sortOrder.DESC.name,
      sortProperty: GetDevicesSortProperty.createdTime.name,
    );

    print('Fetching devices...');
    await _repo.getDevices(requestModel: requestModel).then((
      GetDevicesResponseModel result,
    ) {
      isLoading(false);
      responseHandler(
        statusCode: result.statusCode!,
        message: result.message ?? '',
        onSuccess: () {
          devices = result.data?.data;
          print('Devices fetched successfully. Count: ${devices?.length}');
          print(
            'Devices list: ${devices?.map((d) => '${d.name} (${d.id?.id})').join(', ')}',
          );
        },
      );
    });
  }

  Future<void> createDevice(String deviceName) async {
    isLoading(true);
    CreateDeviceRequestModel requestModel = CreateDeviceRequestModel(
      name: deviceName,
      deviceProfileId: defaultProfileId,
    );

    await _repo.createDevice(requestModel: requestModel).then((
      CreateDeviceResponseModel result,
    ) {
      isLoading(false);
      responseHandler(
        statusCode: result.statusCode!,
        message: result.message ?? '',
        onSuccess: () {
          getDevices();
          // debugPrint("New Device Created ##### ${result.toString()}");
        },
      );
    });
  }

  Future<void> removeDevice(String deviceId) async {
    isLoading(true);
    RemoveDeviceRequestModel requestModel = RemoveDeviceRequestModel(
      id: deviceId,
    );

    await _repo.removeDevice(requestModel: requestModel).then((result) {
      isLoading(false);
      responseHandler(
        statusCode: result.statusCode!,
        message: result.message ?? '',
        onSuccess: () {
          getDevices(); // Refresh the devices list
          Get.snackbar('انجام شد', 'دستگاه با موفقیت حذف شد');
        },
      );
    });
  }

  Future<void> getDefaultProfileId() async {
    isLoading(true);

    await _repo.defaultProfileInfo().then((
      DefaultProfileInfoResponseModel result,
    ) {
      isLoading(false);
      responseHandler(
        statusCode: result.statusCode!,
        message: result.message ?? '',
        onSuccess: () {
          defaultProfileId = NewDeviceProfileId(
            entityType: result.data?.id?.entityType,
            id: result.data?.id?.id,
          );
          // debugPrint("Profile Id: $defaultProfileId");
        },
      );
    });
  }

  RxBool isLoading = RxBool(false);
}
