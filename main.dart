// main.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:my_app32/app/bindings/main_binding.dart';
import 'package:my_app32/app/core/languages/app_localization.dart';
import 'package:my_app32/app/routes/app_pages.dart';
import 'package:my_app32/app/routes/app_routes.dart';
import 'package:my_app32/app/services/token_refresh_service.dart';
import 'package:my_app32/app/theme/app_theme.dart';
import 'package:my_app32/app/store/user_store_service.dart';
import 'package:my_app32/app/services/storage_service.dart';
import 'package:my_app32/core/lang/lang.dart';
import 'package:my_app32/features/offline/InternetWrapper.dart';
import 'package:intl/date_symbol_data_local.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Lang.load("fa"); // زبان پیش فرض فارسی (چپ‌چین)
  await initializeDateFormatting('en', null);
  await Hive.initFlutter();
  await Hive.openBox('cache');
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

    return Obx(() {
      print("🔹 Building app with locale: ${Lang.current.value}");
      print("🔹 TextDirection: ${Lang.textDirection.value}");
      
      return GetMaterialApp(
        navigatorKey: navigatorKey,
        title: 'app_name'.tr,
        theme: AppTheme.themeData(),
        initialBinding: MainBinding(),
        translations: AppLocalization(),
        locale: Locale(Lang.current.value), // 🔹 زبان دینامیک
        fallbackLocale: const Locale('fa'),
        getPages: AppPages.pages,
        initialRoute: AppRoutes.SPLASH,
        debugShowCheckedModeBanner: false,
        builder: (context, child) {
          return Directionality(
            textDirection: Lang.textDirection.value, // 🔹 جهت دینامیک
            child: InternetWrapper(
              navigatorKey: navigatorKey,
              child: child ?? const SizedBox.shrink(),
            ),
          );
        },
      );
    });
  }
}