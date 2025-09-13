import 'package:flutter/material.dart';
import 'package:my_app32/app/core/base/base_view.dart';
import 'package:my_app32/features/main/pages/alarms/alarms_controller.dart';
import 'package:my_app32/features/widgets/app_bar_widget.dart';

class AlarmsPage extends BaseView<AlarmsController> {
  const AlarmsPage({super.key});

  @override
  Widget body() {
    return Column(
      children: [
        controller.isLoading.value ? SizedBox() : SizedBox(),
        AppBarWidget(title: 'Alarms', showBackButton: false),
      ],
    );
  }
}
