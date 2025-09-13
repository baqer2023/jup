import 'package:get/get.dart';
import 'package:my_app32/app/core/app_constants.dart';
import 'package:my_app32/app/core/app_utils_mixin.dart';
import 'package:my_app32/app/store/user_store_service.dart';

class MoreController extends GetxController with AppUtilsMixin {
  // MoreController(this._repo);

  // final MoreRepository _repo;
  late final String userName;

  @override
  void onInit() {
    userName = UserStoreService.to.get(key: AppConstants.USER_NAME) ?? '';
    super.onInit();
  }

  RxBool isLoading = RxBool(true);

  void onTapLogOut() => logoutFromApp();
}
