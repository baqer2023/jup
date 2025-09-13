import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import '../controllers/smart_light_controller.dart';
import '../widgets/body.dart';
import '../widgets/color_picker_sheet.dart';
import '../widgets/expandable_bottom_sheet.dart';

class SmartLightPage extends StatelessWidget {
  static const String routeName = '/smart-light';

  const SmartLightPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SmartLightController>();
    
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        title: Text(controller.dashboardConfig?['config']?['datasources']?[0]?['dataKeys']?[0]?['label'] ?? 'Smart Light'),
      ),
      body: SlidingUpPanel(
        controller: controller.pc,
        minHeight: 0,
        maxHeight: MediaQuery.of(context).size.height * 0.7,
        panel: controller.isTappedOnColor.value
            ? ColorPickerSheet(controller: controller)
            : ExpandableBottomSheet(controller: controller),
        body: Body(controller: controller),
        onPanelClosed: controller.onPanelClosed,
      ),
    );
  }
} 