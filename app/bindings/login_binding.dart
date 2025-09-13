import 'package:get/get.dart';
import 'package:my_app32/features/login/pages/main/login_controller.dart';
import 'package:my_app32/features/login/repository/login_repository.dart';

class LoginBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LoginRepository>(() => LoginRepositoryImpl());
    Get.lazyPut<LoginController>(
      () => LoginController(Get.find<LoginRepository>()),
    );
  }
}
