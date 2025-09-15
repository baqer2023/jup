import 'package:get/get.dart';
import 'package:my_app32/features/main/pages/alarms/alarms_controller.dart';
import 'package:my_app32/features/main/pages/home/home_controller.dart';
// import 'package:my_app32/features/main/pages/home/home_devices_controller.dart';
import 'package:my_app32/features/main/pages/main/main_controller.dart';
import 'package:my_app32/features/main/pages/more/more_controller.dart';
import 'package:my_app32/features/main/repository/home_repository.dart';
import 'package:my_app32/features/main/repository/more_repository.dart';

class HomeBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<HomeRepository>(HomeRepositoryImpl());
  
    Get.put<MainController>(MainController(Get.find<HomeRepository>()));
    Get.put<HomeController>(HomeController(Get.find<HomeRepository>()));

    Get.put<AlarmsController>(AlarmsController());
    Get.put<MoreRepository>(MoreRepositoryImpl());
    Get.put<MoreController>(MoreController());
  }
}
