import 'package:get/get.dart';
import 'package:my_app32/features/dashboard_item_detail/pages/main/dashboard_item_detail_controller.dart';
import 'package:my_app32/features/dashboard_item_detail/repository/dashboard_item_detail_repository.dart';
import 'package:my_app32/features/main/repository/dashboard_widget_detail_repository.dart';

class DashboardItemDetailBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DashboardItemDetailRepository>(
      () => DashboardItemDetailRepositoryImpl(),
    );
    Get.lazyPut<GetDashboardWidgetDetailRepository>(
      () => GetDashboardWidgetDetailRepositoryImpl(),
    );
    Get.lazyPut<DashboardItemDetailController>(
      () => DashboardItemDetailController(
        Get.find<DashboardItemDetailRepository>(),
        Get.find<GetDashboardWidgetDetailRepository>(),
      ),
    );
  }
}
