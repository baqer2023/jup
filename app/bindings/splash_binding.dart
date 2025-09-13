import 'package:get/get.dart';
import 'package:my_app32/features/splash/pages/splash_controller.dart';

class SplashBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SplashController>(() => SplashController());
  }
}
