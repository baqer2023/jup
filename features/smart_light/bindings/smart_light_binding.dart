import 'package:get/get.dart';
import '../controllers/smart_light_controller.dart';

class SmartLightBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SmartLightController>(
      () => SmartLightController(),
      fenix: true,
    );
  }
} 