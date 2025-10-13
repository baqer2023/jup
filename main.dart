import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:my_app32/app/bindings/main_binding.dart';
import 'package:my_app32/app/core/languages/app_localization.dart';
import 'package:my_app32/app/routes/app_pages.dart';
import 'package:my_app32/app/routes/app_routes.dart';
import 'package:my_app32/app/services/token_refresh_service.dart';
import 'package:my_app32/app/theme/app_theme.dart';
import 'package:my_app32/app/store/user_store_service.dart';
import 'package:my_app32/app/services/storage_service.dart';
import 'package:my_app32/features/offline/InternetWrapper.dart';


final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await GetStorage.init();

  Get.put<UserStoreService>(UserStoreService(StorageService()), permanent: true);
  Get.put<TokenRefreshService>(TokenRefreshService(), permanent: true);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    return GetMaterialApp(
      navigatorKey: navigatorKey, // ✅ استفاده از navigatorKey
      title: 'app_name'.tr,
      theme: AppTheme.themeData(),
      initialBinding: MainBinding(),
      translations: AppLocalization(),
      locale: AppLocalization.locale,
      fallbackLocale: AppLocalization.fallbackLocale,
      getPages: AppPages.pages,
      initialRoute: AppRoutes.SPLASH,
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        return InternetWrapper(
          navigatorKey: navigatorKey, // پاس دادن navigatorKey
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
