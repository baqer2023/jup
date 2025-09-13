import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:my_app32/app/core/app_icons.dart';
import 'package:my_app32/app/core/base/base_view.dart';
import 'package:my_app32/app/theme/app_colors.dart';
import 'package:my_app32/features/splash/pages/splash_controller.dart';

class SplashPage extends BaseView<SplashController> {
  const SplashPage({super.key});

  @override
  Widget body() {
    return Column(
      children: [
        controller.isLoading.value ? const SizedBox() : const SizedBox(),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              gradient: AppColors.backgroundLinearGradient,
            ),
            child: Center(
              child: TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 800),
                tween: Tween(begin: 0.1, end: 1.6),
                builder: (context, value, child) {
                  double newVal = value;
                  var ts = Transform.scale(scale: newVal, child: child);
                  return ts;
                },
                curve: Curves.bounceOut,
                child: SizedBox(
                  height: 60,
                  // child: SvgPicture.asset(AppIcons.icDevices),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
