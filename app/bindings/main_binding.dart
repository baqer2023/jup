import 'package:get/get.dart';
import 'package:my_app32/app/services/storage_service.dart';
import 'package:my_app32/app/services/token_refresh_service.dart';
import 'package:my_app32/app/store/localize_store_service.dart';
import 'package:my_app32/app/store/user_store_service.dart';

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
  }
}
