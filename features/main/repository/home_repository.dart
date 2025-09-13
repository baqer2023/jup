import 'package:my_app32/app/core/app_enums.dart';
import 'package:my_app32/app/core/base/base_repository.dart';
import 'package:my_app32/app/models/response_model.dart';
import 'package:my_app32/features/main/models/home/create_dashboard_request_model.dart';
import 'package:my_app32/features/main/models/home/create_dashboard_response_model.dart';
import 'package:my_app32/features/main/models/home/get_current_user_response_model.dart';
import 'package:my_app32/features/main/models/home/get_dashboards_request_model.dart';
import 'package:my_app32/features/main/models/home/get_dashboards_response_model.dart';

abstract class HomeRepository extends BaseRepository {
  Future<GetCurrentUserResponseModel> getCurrentUSer();

  Future<DashboardResponseModel> getDashboards({
    required GetDashboardsRequestModel requestModel,
  });

  Future<CreateDashboardResponseModel> createOrUpdateDashboard({
    required CreateDashboardRequestModel requestModel,
  });
}

class HomeRepositoryImpl extends HomeRepository {
  @override
  Future<GetCurrentUserResponseModel> getCurrentUSer() async {
    final ResponseModel response = await request(
      url: 'api/auth/user',
      method: RequestMethodEnum.GET.name,
    );

    GetCurrentUserResponseModel result = GetCurrentUserResponseModel();
    try {
      if (response.success) {
        result = getCurrentUserResponseModelFromJson({'data': response.body});
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
  Future<DashboardResponseModel> getDashboards({
    required GetDashboardsRequestModel requestModel,
  }) async {
    final ResponseModel response = await request(
      url: 'api/tenant/dashboards',
      method: RequestMethodEnum.GET.name,
      queryParameters: requestModel.toJson(),
    );

    DashboardResponseModel result = DashboardResponseModel();
    try {
      if (response.success) {
        result = dashboardResponseModelFromJson({'data': response.body});
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
  Future<CreateDashboardResponseModel> createOrUpdateDashboard({
    required CreateDashboardRequestModel requestModel,
  }) async {
    final ResponseModel response = await request(
      url: 'api/dashboard',
      method: RequestMethodEnum.POST.name,
      data: requestModel.toJson(),
    );

    CreateDashboardResponseModel result = CreateDashboardResponseModel();
    try {
      if (response.success) {
        result = createDashboardResponseModelFromJson({'data': response.body});
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
