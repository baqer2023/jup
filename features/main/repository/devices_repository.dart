import 'package:my_app32/app/core/app_enums.dart';
import 'package:my_app32/app/core/base/base_repository.dart';
import 'package:my_app32/app/models/response_model.dart';
import 'package:my_app32/features/main/models/devices/create_device_request_model.dart';
import 'package:my_app32/features/main/models/devices/create_device_response_model.dart';
import 'package:my_app32/features/main/models/devices/default_profile_info_respons_model.dart';
import 'package:my_app32/features/main/models/devices/get_devices_request_model.dart';
import 'package:my_app32/features/main/models/devices/get_devices_response_model.dart';
import 'package:my_app32/features/main/models/devices/remove_device_request_model.dart';

abstract class DevicesRepository extends BaseRepository {
  Future<GetDevicesResponseModel> getDevices({
    required GetDevicesRequestModel requestModel,
  });
  Future<CreateDeviceResponseModel> createDevice({
    required CreateDeviceRequestModel requestModel,
  });
  Future<DefaultProfileInfoResponseModel> defaultProfileInfo();
  Future<ResponseModel> removeDevice({
    required RemoveDeviceRequestModel requestModel,
  });
}

class DevicesRepositoryImpl extends DevicesRepository {
  @override
  Future<GetDevicesResponseModel> getDevices({
    required GetDevicesRequestModel requestModel,
  }) async {
    final ResponseModel response = await request(
      url: 'api/tenant/devices',
      method: RequestMethodEnum.GET.name,
      queryParameters: requestModel.toJson(),
    );

    GetDevicesResponseModel result = GetDevicesResponseModel();
    try {
      if (response.success) {
        result = getDevicesResponseModelFromJson({'data': response.body});
        result.statusCode = response.statusCode;
        return result;
      } else {
        result.message = response.message;
        result.statusCode = response.statusCode;
        return result;
      }
    } catch (e) {
      result.message = e.toString();
      result.statusCode = 600;
      return result;
    }
  }

  @override
  Future<CreateDeviceResponseModel> createDevice({
    required CreateDeviceRequestModel requestModel,
  }) async {
    final ResponseModel response = await request(
      url: 'api/device',
      method: RequestMethodEnum.POST.name,
      data: requestModel.toJson(),
    );

    CreateDeviceResponseModel result = CreateDeviceResponseModel();
    try {
      if (response.success) {
        result = createDeviceResponseModelFromJson({'data': response.body});
        result.statusCode = response.statusCode;
        return result;
      } else {
        result.message = response.message;
        result.statusCode = response.statusCode;
        return result;
      }
    } catch (e) {
      result.message = e.toString();
      result.statusCode = 600;
      return result;
    }
  }

  @override
  Future<DefaultProfileInfoResponseModel> defaultProfileInfo() async {
    final ResponseModel response = await request(
      url: 'api/deviceProfile/default',
      method: RequestMethodEnum.GET.name,
    );

    DefaultProfileInfoResponseModel result = DefaultProfileInfoResponseModel();
    try {
      if (response.success) {
        result = defaultProfileInfoResponseModelFromJson({
          'data': response.body,
        });
        result.statusCode = response.statusCode;
        return result;
      } else {
        result.message = response.message;
        result.statusCode = response.statusCode;
        return result;
      }
    } catch (e) {
      result.message = e.toString();
      result.statusCode = 600;
      return result;
    }
  }

  @override
  Future<ResponseModel> removeDevice({
    required RemoveDeviceRequestModel requestModel,
  }) async {
    final ResponseModel response = await request(
      url: 'api/device/remove',
      method: RequestMethodEnum.POST.name,
      data: requestModel.toJson(),
    );

    return response;
  }
}
