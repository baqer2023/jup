import 'package:my_app32/app/core/app_enums.dart';
import 'package:my_app32/app/core/base/base_repository.dart';
import 'package:my_app32/app/models/response_model.dart';
import 'package:my_app32/app/store/user_store_service.dart';
import 'package:my_app32/features/login/models/otp_request_model.dart';
import 'package:my_app32/features/login/models/otp_response_model.dart';

abstract class OtpRepository extends BaseRepository {
  Future<OtpResponseModel> sendOtp({required OtpRequestModel requestModel});
}

class OtpRepositoryImpl extends OtpRepository {
  @override
  Future<OtpResponseModel> sendOtp({
    required OtpRequestModel requestModel,
  }) async {
    final ResponseModel response = await request(
      url: 'api/signup/verifyOTP',
      method: RequestMethodEnum.POST.name,
      data: requestModel.toJson(),
      requiredToken: false,
    );

    OtpResponseModel result = OtpResponseModel();

    try {
      if (response.success) {
        // parse
        result = otpResponseModelFromJson({'data': response.body});
        result.statusCode = response.statusCode;

        // ذخیره توکن‌ها
        if (response.body["token"] != null &&
            response.body["refreshToken"] != null) {
          await UserStoreService.to.saveToken(response.body["token"]);
          await UserStoreService.to.saveRefreshToken(response.body["refreshToken"]);
        }

        return result;
      } else {
        result.message = response.body[0];
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

