import 'package:get/get.dart';
import 'package:my_app32/features/login/pages/otp/otp_controller.dart';
import 'package:my_app32/features/login/repository/login_repository.dart';
import 'package:my_app32/features/login/repository/otp_repository.dart';

class OtpBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<OtpRepository>(() => OtpRepositoryImpl());
    Get.lazyPut<OtpController>(
      () =>
          OtpController(Get.find<OtpRepository>(), Get.find<LoginRepository>()),
    );
  }
}
