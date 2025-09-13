import 'package:get/get.dart';
import 'package:my_app32/features/add_device/pages/add_device_controller.dart';
import 'package:my_app32/features/add_device/repository/add_device_repository.dart';

class AddDeviceBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AddDeviceRepository>(() => AddDeviceRepositoryImpl());
    Get.lazyPut<AddDeviceController>(
      () => AddDeviceController(Get.find<AddDeviceRepository>()),
    );
  }
}
