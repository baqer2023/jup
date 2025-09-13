import 'package:my_app32/app/core/app_enums.dart';
import 'package:my_app32/app/core/base/base_repository.dart';
import 'package:my_app32/app/models/response_model.dart';
import 'package:my_app32/features/login/models/signup_request_model.dart';

abstract class LoginRepository extends BaseRepository {
  Future<ResponseModel> login({required SignupRequestModel requestModel});
}

class LoginRepositoryImpl extends LoginRepository {
  @override
  Future<ResponseModel> login({
    required SignupRequestModel requestModel,
  }) async {
    final ResponseModel response = await request(
      url: 'api/signup/sendVerificationCode',
      method: RequestMethodEnum.POST.name,
      data: requestModel.toJson(),
      requiredToken: false,
    );
    try {
      if (response.success) {
        return response;
      } else {
        return response;
      }
    } catch (e) {
      return response;
    }
  }
}
