import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_app32/app/core/base/base_view.dart';
import 'package:my_app32/app/theme/app_colors.dart';
import 'package:my_app32/features/dashboard_item_detail/models/power_item_model.dart';
import 'package:my_app32/features/dashboard_item_detail/models/temperature_item_model.dart';
import 'package:my_app32/features/dashboard_item_detail/pages/main/dashboard_item_detail_controller.dart';
import 'package:my_app32/features/dashboard_item_detail/widgets/add_widget_bottom_sheet_widget.dart';
import 'package:my_app32/features/dashboard_item_detail/widgets/light_bulb_widget.dart';
import 'package:my_app32/features/dashboard_item_detail/widgets/temperature_widget.dart';
import 'package:my_app32/features/widgets/app_bar_widget.dart';

class DashboardItemDetailPage extends BaseView<DashboardItemDetailController> {
  const DashboardItemDetailPage({super.key});

  @override
  Widget body() {
    return Stack(
      fit: StackFit.expand,
      children: [
        Column(
          children: [
            AppBarWidget(title: controller.dashboardItemModel.title!),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: GridView.builder(
                    shrinkWrap: true,
                    itemCount: controller.widgetModels.length,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                          mainAxisExtent: 240,
                        ),
                    itemBuilder: (context, index) {
                      if (controller.widgetModels[index] is PowerItemModel) {
                        return LightBulbWidget(
                          controller: controller,
                          index: index,
                          title:
                              (controller.widgetModels[index] as PowerItemModel)
                                  .title,
                          isOn:
                              (controller.widgetModels[index] as PowerItemModel)
                                  .switchState,
                        );
                      } else {
                        return TemperatureWidget(
                          title:
                              (controller.widgetModels[index]
                                      as TemperatureItemModel)
                                  .title,
                        );
                      }
                    },
                  ),
                  /*
                  ListView.builder(
                    itemCount: controller.settingsModels.length,
                    shrinkWrap: true,
                    itemBuilder: (BuildContext context, int index) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          LightBulbWidget(controller: controller, index: index, title: controller.titles[index]),
                          // Text(
                          //   controller.titles[index],
                          // ),
                          // Switch(
                          //   value: controller.switchState[index],
                          //   activeColor: Colors.green,
                          //   onChanged: (bool value) {
                          //     controller.sendCommandToDevice(
                          //         value: value, index: index);
                          //   },
                          // )
                        ],
                      );
                    },
                  ),
                */
                ),
              ),
            ),
          ],
        ),
        if (controller.isLoading.value)
          Container(
            width: Get.width,
            height: Get.height,
            color: Colors.black26,
            child: const Center(child: CircularProgressIndicator()),
          ),
      ],
    );
  }

  @override
  Widget? floatingActionButton() {
    return FloatingActionButton(
      backgroundColor: AppColors.primaryColor,
      onPressed: () async {
        await controller.getDevices();
        Get.bottomSheet(AddWidgetBottomSheetWidget());
      },
      child: const Icon(Icons.add),
    );
  }
}
