import 'package:dio/dio.dart';
import 'package:my_app32/app/api/connectivity_service.dart';
import 'package:my_app32/app/api/interceptors/logging_interceptors.dart';
import 'package:my_app32/app/core/app_constants.dart';
import 'package:my_app32/app/core/app_utils_mixin.dart';
import 'package:my_app32/app/models/response_model.dart';
import 'package:my_app32/app/store/user_store_service.dart';
import 'package:my_app32/app/services/token_refresh_service.dart';
import 'package:get/get.dart' hide Response;
import 'package:get/get_core/src/get_main.dart';

class BaseRepository with AppUtilsMixin {
  static Dio dio = Dio(
    BaseOptions(
      receiveTimeout: const Duration(seconds: 60),
      sendTimeout: const Duration(seconds: 60),
      connectTimeout: const Duration(seconds: 60),
      receiveDataWhenStatusError: true,
      followRedirects: false,
      validateStatus: (status) {
        if (status != null) {
          return status <= 500;
        }
        return true;
      },
    ),
  )..interceptors.addAll([LoggingInterceptor()]);

  Future<ResponseModel> request({
    required String? method,
    String url = '',
    Map<String, dynamic>? headers,
    Object? data,
    String urlParameters = '',
    Map<String, dynamic>? queryParameters,
    bool requiredToken = true,
    String baseUrl = AppConstants.BASE_URL,
  }) async {
    try {
      if (ConnectivityServiceSingleton.instance.hasConnection) {
        if (requiredToken) {
          String? token = await UserStoreService.to.getToken();
          if (headers == null) {
            headers = {'Authorization': 'Bearer $token'};
          } else {
            headers.addAll({'Authorization': 'Bearer $token'});
          }
        }
        final Response response = await dio.request(
          baseUrl + url + urlParameters,
          data: data,
          queryParameters: queryParameters,
          options: Options(method: method, headers: headers),
        );
        if (response.statusCode == 200) {
          ResponseModel responseModel = ResponseModel(
            body: response.data,
            statusCode: 200,
            success: true,
            message: response.statusMessage,
          );
          return responseModel;
        } else if (response.statusCode == 401 || response.statusCode == 403) {
          // Try to refresh token first
          try {
            final tokenRefreshService = Get.find<TokenRefreshService>();
            final refreshSuccess = await tokenRefreshService.refreshToken();

            if (refreshSuccess) {
              // Token refreshed successfully, retry the original request
              String? newToken = await UserStoreService.to.getToken();
              if (headers != null) {
                headers['Authorization'] = 'Bearer $newToken';
              }

              final retryResponse = await dio.request(
                baseUrl + url + urlParameters,
                data: data,
                queryParameters: queryParameters,
                options: Options(method: method, headers: headers),
              );

              if (retryResponse.statusCode == 200) {
                return ResponseModel(
                  body: retryResponse.data,
                  statusCode: 200,
                  success: true,
                  message: retryResponse.statusMessage,
                );
              }
            }
          } catch (e) {
            print('Token refresh failed: $e');
          }

          // If token refresh failed or retry failed, logout
          logoutDialog();
          return ResponseModel(
            body: 'Exit',
            statusCode: 401,
            success: false,
            message: 'Log Out',
          );
        } else {
          ResponseModel responseModel = ResponseModel(
            body: response.data,
            statusCode: response.statusCode,
            success: false,
            message: response.statusMessage,
          );
          return responseModel;
        }
      } else {
        noInternetConnectionDialog(
          mainTask: () {
            request(
              url: url,
              method: method,
              data: data,
              queryParameters: queryParameters,
              urlParameters: urlParameters,
              requiredToken: requiredToken,
            );
          },
        );
        return ResponseModel(
          body: 'No internet connection',
          statusCode: 500,
          success: false,
          message: 'No internet connection',
        );
      }
    } on DioException catch (e, s) {
      return ResponseModel(
        body: e,
        statusCode: e.response?.statusCode ?? 500,
        success: false,
        message: s.toString(),
      );
    } catch (e, s) {
      return ResponseModel(
        body: e,
        statusCode: 600,
        success: false,
        message: s.toString(),
      );
    }
  }
}
