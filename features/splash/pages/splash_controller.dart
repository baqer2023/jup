import 'package:get/get.dart';
import 'package:my_app32/app/routes/app_routes.dart';
import 'package:my_app32/app/store/user_store_service.dart';
import 'package:my_app32/app/services/token_refresh_service.dart';

class SplashController extends GetxController {
  RxBool isLoading = RxBool(false);

  @override
  void onInit() {
    super.onInit();
    _checkTokenAndNavigate();
  }

  Future<void> _checkTokenAndNavigate() async {
    try {
      // Wait for 3 seconds to show splash
      await Future.delayed(const Duration(seconds: 3));

      final token = await UserStoreService.to.getToken();

      if (token == null) {
        // No token available, go to login
        Get.offNamed(AppRoutes.LOGIN);
        return;
      }

      // Check if token is valid and refresh if needed
      final tokenRefreshService = Get.find<TokenRefreshService>();
      final isTokenValid = await tokenRefreshService.checkAndRefreshToken();

      if (isTokenValid) {
        // Token is valid or was refreshed successfully, go to home
        Get.offNamed(AppRoutes.HOME);
      } else {
        // Token refresh failed, clear tokens and go to login
        UserStoreService.to.deleteToken();
        UserStoreService.to.deleteRefreshToken();
        Get.offNamed(AppRoutes.LOGIN);
      }
    } catch (e) {
      print('Error during token check: $e');
      // On error, go to login
      Get.offNamed(AppRoutes.LOGIN);
    }
  }
}
