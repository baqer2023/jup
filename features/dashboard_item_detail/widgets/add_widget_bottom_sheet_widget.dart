import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_app32/app/theme/app_colors.dart';
import 'package:my_app32/features/dashboard_item_detail/pages/main/dashboard_item_detail_controller.dart';
import 'package:my_app32/features/main/models/devices/get_devices_response_model.dart';
import 'package:my_app32/features/widgets/fill_button_widget.dart';
import 'package:my_app32/features/widgets/text_form_field_widget.dart';

class AddWidgetBottomSheetWidget extends StatelessWidget {
  AddWidgetBottomSheetWidget({super.key});

  final controller = Get.find<DashboardItemDetailController>();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.backgroundColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormFieldWidget(
                controller: controller.titleController,
                label: Text('Title', style: Get.textTheme.bodyMedium),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Title cannot be empty';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Text("Select Device: ", style: TextStyle(fontSize: 16)),
                  const SizedBox(width: 10),
                  Obx(
                    () => DropdownButton<String>(
                      value: controller.dropdownValue.value.isEmpty
                          ? null
                          : controller.dropdownValue.value,
                      hint: Text("Device", style: Get.textTheme.bodyMedium),
                      items: controller.devices?.map<DropdownMenuItem<String>>((
                        Datum value,
                      ) {
                        return DropdownMenuItem<String>(
                          value: value.name,
                          child: Text(
                            value.name ?? '',
                            style: Get.textTheme.bodyMedium,
                          ),
                        );
                      }).toList(),
                      dropdownColor: Colors.white,
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          controller.dropdownValue.value = newValue;
                          debugPrint(controller.dropdownValue.value);
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Row(
                    children: [
                      Obx(
                        () => Radio<String>(
                          value: 'Power',
                          groupValue: controller.selectedValue.string,
                          onChanged: (value) {
                            controller.selectedValue.value = value!;
                            debugPrint(controller.selectedValue.value);
                          },
                        ),
                      ),
                      const Text('Power'),
                    ],
                  ),
                  Row(
                    children: [
                      Obx(
                        () => Radio<String>(
                          value: 'Temperature',
                          groupValue: controller.selectedValue.string,
                          onChanged: (value) {
                            controller.selectedValue.value = value!;
                            debugPrint(controller.selectedValue.value);
                          },
                        ),
                      ),
                      const Text('Temperature'),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Obx(
                () => controller.selectedValue.value == "Power"
                    ? Column(
                        children: [
                          Row(
                            children: [
                              const Text(
                                "Initial State: ",
                                style: TextStyle(fontSize: 16),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: TextField(
                                  controller: controller.initialTEC,
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    hintText: 'Enter \'Initial\' Value',
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              const Text(
                                "Power 'On': ",
                                style: TextStyle(fontSize: 16),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: TextField(
                                  controller: controller.powerOnController,
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    hintText: 'Enter \'On\' Value',
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              const Text(
                                "Power 'Off': ",
                                style: TextStyle(fontSize: 16),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: TextField(
                                  controller: controller.powerOffController,
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    hintText: 'Enter \'Off\' value',
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      )
                    : const SizedBox(height: 0),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: 180,
                    child: FillButtonWidget(
                      onTap: () => Get.back(),
                      buttonTitle: 'Cancel',
                      isLoading: false,
                    ),
                  ),
                  SizedBox(
                    width: 180,
                    child: FillButtonWidget(
                      isLoading: false,
                      onTap: () => controller.onTapAdd(),
                      buttonTitle: 'Add',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
