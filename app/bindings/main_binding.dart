import 'package:get/get.dart';
import 'package:my_app32/app/services/storage_service.dart';
import 'package:my_app32/app/services/token_refresh_service.dart';
import 'package:my_app32/app/store/localize_store_service.dart';
import 'package:my_app32/app/store/user_store_service.dart';
// import 'package:my_app32/features/main/pages/home/home_repository.dart';
import 'package:my_app32/features/main/pages/home/home_controller.dart';
import 'package:my_app32/features/main/repository/home_repository.dart';

class MainBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<LocalStorage>(StorageService(), permanent: true);
    Get.put<LocalizeStoreService>(
      LocalizeStoreService(Get.find<LocalStorage>()),
      permanent: true,
    );
    Get.put<UserStoreService>(
      UserStoreService(Get.find<LocalStorage>()),
      permanent: true,
    );
    Get.put<TokenRefreshService>(TokenRefreshService(), permanent: true);

    // ریپازیتوری و کنترلر
    Get.lazyPut<HomeRepository>(() => HomeRepositoryImpl());
Get.put<HomeController>(
  HomeController(Get.find<HomeRepository>()),
  permanent: true, // خیلی مهم برای اینکه بعد از بازگشت حذف نشه
);

  }
}
