import 'package:my_app32/app/core/app_enums.dart';
import 'package:my_app32/app/core/base/base_repository.dart';
import 'package:my_app32/app/models/response_model.dart';
import 'package:my_app32/features/add_device/models/credential_request_model.dart';
import 'package:my_app32/features/add_device/models/credential_response_model.dart';
import 'package:my_app32/features/add_device/models/custom_cmd_request_model.dart';

abstract class AddDeviceRepository extends BaseRepository {
  Future<CredentialResponseModel> submitCredential({
    required CredentialRequestModel requestModel,
    required String baseUrl,
  });

  Future<CredentialResponseModel> sendCustomCommand({
    required CustomCmdRequestModel requestModel,
    required String baseUrl,
  });

  Future<CredentialResponseModel> registerDevice({
    //required String name,
    //required String ip,
    required String serialNumber,
    required String label,
  });
}

class AddDeviceRepositoryImpl extends AddDeviceRepository {
  @override
  Future<CredentialResponseModel> submitCredential({
    required CredentialRequestModel requestModel,
    required String baseUrl,
  }) async {
    final ResponseModel response = await request(
      baseUrl: baseUrl,
      url: 'set-credentials',
      method: RequestMethodEnum.POST.name,
      data: requestModel.toJson(),
      requiredToken: false,
    );

    CredentialResponseModel result = CredentialResponseModel();
    try {
      if (response.success) {
        result = credentialResponseModelFromJson(response.body);
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
  Future<CredentialResponseModel> sendCustomCommand({
    required CustomCmdRequestModel requestModel,
    required String baseUrl,
  }) async {
    final ResponseModel response = await request(
      baseUrl: baseUrl,
      url: 'set-command',
      method: RequestMethodEnum.POST.name,
      data: requestModel.toJson(),
      requiredToken: false,
    );

    CredentialResponseModel result = CredentialResponseModel();
    try {
      if (response.success) {
        result = credentialResponseModelFromJson(response.body);
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
  Future<CredentialResponseModel> registerDevice({
    required String serialNumber,
    required String label,
  }) async {
    final ResponseModel response = await request(
      baseUrl: 'http://45.149.76.245:8080/api/',
      // replace with actual backend base URL
      url: 'deviceWithSn',
      // backend endpoint
      method: RequestMethodEnum.POST.name,
      data: {'serialNumber': serialNumber, 'label': label},
      requiredToken: true, // set to true if your backend requires auth
    );

    return CredentialResponseModel.fromJson(response.data);
  }
}

//     CredentialResponseModel result = CredentialResponseModel();
//     try {
//       if (response.success) {
//         result = credentialResponseModelFromJson(response.body);
//         result.statusCode = response.statusCode;
//         return result;
//       } else {
//         result.message = response.message;
//         result.statusCode = response.statusCode;
//         return result;
//       }
//     } catch (e) {
//       result.message = e.toString();
//       result.statusCode = 600;
//       return result;
//     }
//   }
//
