import 'package:get/get.dart';
import 'package:my_app32/features/main/pages/home/home_devices_controller.dart';
import 'package:my_app32/features/main/repository/devices_repository.dart';

class HomeDevicesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeDevicesController>(
      () => HomeDevicesController(Get.find<DevicesRepository>()),
      fenix: true,
    );
  }
}
