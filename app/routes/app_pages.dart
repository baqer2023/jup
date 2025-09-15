import 'package:get/get.dart';


import 'package:my_app32/app/bindings/home_bindings.dart';
import 'package:my_app32/app/bindings/login_binding.dart';
import 'package:my_app32/app/bindings/otp_binding.dart';
import 'package:my_app32/app/bindings/splash_binding.dart';
import 'package:my_app32/app/routes/app_routes.dart';
import 'package:my_app32/features/login/pages/main/login_page.dart';
import 'package:my_app32/features/login/pages/otp/otp_page.dart';
import 'package:my_app32/features/main/pages/main/main_page.dart';
import 'package:my_app32/features/splash/pages/splash_page.dart';
import 'package:my_app32/features/smart_light/pages/smart_light_page.dart';
import 'package:my_app32/features/smart_light/bindings/smart_light_binding.dart';

abstract class AppPages {
  static final pages = [
    GetPage(
      name: AppRoutes.SPLASH,
      page: () => const SplashPage(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: AppRoutes.LOGIN,
      page: () => const LoginPage(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: AppRoutes.OTP,
      page: () => const OtpPage(),
      binding: OtpBinding(),
    ),
    GetPage(
      name: AppRoutes.HOME,
      page: () => const MainPage(),
      binding: HomeBinding(),
    ),

    GetPage(
      name: SmartLightPage.routeName,
      page: () => const SmartLightPage(),
      binding: SmartLightBinding(),
    ),
  ];
}
