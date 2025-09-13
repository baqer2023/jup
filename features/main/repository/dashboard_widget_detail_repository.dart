import 'package:my_app32/app/core/app_enums.dart';
import 'package:my_app32/app/core/base/base_repository.dart';
import 'package:my_app32/app/models/response_model.dart';
import 'package:my_app32/features/main/models/home/get_widget_detail_response_model.dart';

abstract class GetDashboardWidgetDetailRepository extends BaseRepository {
  Future<GetDashboardWidgetDetailResponseModel> getDashboardWidgetDetail({
    required String dashboardId,
    required String queryParameters,
  });
}

class GetDashboardWidgetDetailRepositoryImpl
    extends GetDashboardWidgetDetailRepository {
  @override
  Future<GetDashboardWidgetDetailResponseModel> getDashboardWidgetDetail({
    required String dashboardId,
    required String queryParameters,
  }) async {
    final ResponseModel response = await request(
      url: 'api/dashboard/$dashboardId',
      method: RequestMethodEnum.GET.name,
      urlParameters: queryParameters,
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
}
