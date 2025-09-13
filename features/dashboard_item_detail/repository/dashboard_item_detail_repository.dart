import 'package:my_app32/app/core/app_enums.dart';
import 'package:my_app32/app/core/base/base_repository.dart';
import 'package:my_app32/app/models/response_model.dart';
import 'package:my_app32/features/main/models/devices/get_devices_request_model.dart';
import 'package:my_app32/features/main/models/devices/get_devices_response_model.dart';
import 'package:my_app32/features/main/models/home/get_widget_detail_response_model.dart';
import 'package:my_app32/features/main/models/home/send_command_to_device_response_model.dart';

abstract class DashboardItemDetailRepository extends BaseRepository {
  Future<SendCommandToDeviceResponseModel> sendCommand({
    required Map<String, String>? data,
    required String deviceId,
    required String scope,
  });

  Future<GetDashboardWidgetDetailResponseModel> addWidgetRequest({
    required GetDashboardWidgetDetailDataModel requestModel,
  });

  Future<GetDevicesResponseModel> getDevices({
    required GetDevicesRequestModel requestModel,
  });
}

class DashboardItemDetailRepositoryImpl extends DashboardItemDetailRepository {
  @override
  Future<SendCommandToDeviceResponseModel> sendCommand({
    required Map<String, String>? data,
    required String deviceId,
    required String scope,
  }) async {
    final ResponseModel response = await request(
      url: 'api/plugins/telemetry',
      method: RequestMethodEnum.POST.name,
      data: data,
      urlParameters: '/$deviceId/$scope',
    );

    SendCommandToDeviceResponseModel result =
        SendCommandToDeviceResponseModel();

    try {
      if (response.success) {
        result = sendCommandToDeviceResponseModelFromJson(response.body);
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
  Future<GetDashboardWidgetDetailResponseModel> addWidgetRequest({
    required GetDashboardWidgetDetailDataModel requestModel,
  }) async {
    final ResponseModel response = await request(
      url: 'api/dashboard',
      method: RequestMethodEnum.POST.name,
      data: requestModel.toJson(),
    );

    GetDashboardWidgetDetailResponseModel result =
        GetDashboardWidgetDetailResponseModel();

    try {
      if (response.success) {
        result = getDashboardWidgetDetailResponseModelFromJson({
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
}
