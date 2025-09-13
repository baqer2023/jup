import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_app32/app/core/app_enums.dart';
import 'package:my_app32/app/core/app_extension.dart';
import 'package:my_app32/app/core/app_utils_mixin.dart';
import 'package:my_app32/features/dashboard_item_detail/models/add_widget_request_model.dart';
import 'package:my_app32/features/dashboard_item_detail/models/add_widget_temperature_request_model.dart';
import 'package:my_app32/features/dashboard_item_detail/models/power_item_model.dart';
import 'package:my_app32/features/dashboard_item_detail/models/settings_model.dart';
import 'package:my_app32/features/dashboard_item_detail/models/temperature_item_model.dart';
import 'package:my_app32/features/dashboard_item_detail/repository/dashboard_item_detail_repository.dart';
import 'package:my_app32/features/main/models/devices/get_devices_request_model.dart';
import 'package:my_app32/features/main/models/devices/get_devices_response_model.dart';
import 'package:my_app32/features/main/models/home/get_dashboards_response_model.dart';
import 'package:my_app32/features/main/models/home/get_widget_detail_response_model.dart';
import 'package:my_app32/features/main/models/home/send_command_to_device_response_model.dart';
import 'package:my_app32/features/main/repository/dashboard_widget_detail_repository.dart';
import 'package:uuid/uuid.dart';

class DashboardItemDetailController extends GetxController with AppUtilsMixin {
  DashboardItemDetailController(
    this._dashboardItemDetailRepo,
    this._getDashboardWidgetRepo,
  );

  final DashboardItemDetailRepository _dashboardItemDetailRepo;
  final GetDashboardWidgetDetailRepository _getDashboardWidgetRepo;
  late final DashboardItemModel dashboardItemModel;
  late final PurpleSettings? purpleSettings;
  RxList<dynamic> widgetModels = RxList([]);
  List<Datum>? devices;
  String? jsonData;
  RxBool isLoading = RxBool(false);
  Map<String, dynamic>? widgetsTest;
  GetDashboardWidgetDetailResponseModel? currentResponse;
  RxString dropdownValue = ''.obs;
  RxString selectedValue = RxString("Power");
  final TextEditingController titleController = TextEditingController();
  final TextEditingController dataKeyController = TextEditingController();
  final TextEditingController initialTEC = TextEditingController();
  final TextEditingController powerOnController = TextEditingController();
  final TextEditingController powerOffController = TextEditingController();

  @override
  void onInit() async {
    var data = Get.arguments;
    if (data != null) {
      dashboardItemModel = data;
    }
    getDashboardWidget();
    super.onInit();
  }

  Future<void> getDashboardWidget() async {
    await _getDashboardWidgetRepo
        .getDashboardWidgetDetail(
          dashboardId: dashboardItemModel.id?.id ?? '',
          queryParameters: '?inlineImages=false',
        )
        .then((GetDashboardWidgetDetailResponseModel result) {
          responseHandler(
            statusCode: result.statusCode!,
            message: result.message ?? '',
            onSuccess: () {
              detectWidget(result);
            },
          );
        });
  }

  void detectWidget(GetDashboardWidgetDetailResponseModel result) {
    widgetModels.clear();
    currentResponse = result;
    widgetsTest = result.data?.configuration?.widgets;
    if (widgetsTest != null) {
      widgetsTest!.forEach((key, value) {
        if (value['typeFullFqn'] == 'system.power_button') {
          widgetModels.add(
            PowerItemModel(
              title: value['config']['title'],
              deviceId: value['config']['targetDevice']['deviceId'],
              settings: SettingsModel.fromJson(value['config']['settings']),
              switchState: false,
            ),
          );
          return;
        } else if (value['typeFullFqn'] ==
            "system.indoor_simple_temperature_chart_card") {
          widgetModels.add(
            TemperatureItemModel(title: value['config']['title']),
          );
          return;
        }
      });
    } else {
      currentResponse?.data?.configuration = WidgetConfiguration(
        widgets: {},
        entityAliases: {},
      );
    }
  }

  Future<void> sendCommandToDevice({
    required bool value,
    required int index,
  }) async {
    PowerItemModel item = widgetModels[index] as PowerItemModel;
    (widgetModels[index] as PowerItemModel).switchState = value;
    isLoading(true);
    String? scope = value
        ? item.settings.onUpdateState?.setAttribute?.scope
        : item.settings.offUpdateState?.setAttribute?.scope;
    Map<String, String> data = value
        ? {
            item.settings.onUpdateState?.setAttribute?.key.toString() ?? '':
                item.settings.onUpdateState?.valueToData?.constantValue ?? '',
          }
        : {
            item.settings.offUpdateState?.setAttribute?.key.toString() ?? '':
                item.settings.offUpdateState?.valueToData?.constantValue ?? '',
          };
    await _dashboardItemDetailRepo
        .sendCommand(data: data, deviceId: item.deviceId, scope: scope!)
        .then((SendCommandToDeviceResponseModel result) {
          isLoading(false);
          responseHandler(
            statusCode: result.statusCode!,
            message: result.message ?? '',
            onSuccess: () {},
          );
        });
  }

  Future<void> getDevices() async {
    GetDevicesRequestModel requestModel = GetDevicesRequestModel(
      pageSize: 20,
      page: 0,
      sortOrder: sortOrder.DESC.name,
      sortProperty: GetDevicesSortProperty.createdTime.name,
    );

    await _dashboardItemDetailRepo.getDevices(requestModel: requestModel).then((
      GetDevicesResponseModel result,
    ) {
      responseHandler(
        statusCode: result.statusCode!,
        message: result.message ?? '',
        onSuccess: () {
          devices = result.data?.data;
          jsonData = result.data?.toString();
        },
      );
    });
  }

  void onTapAdd() {
    if (selectedValue.value == 'Power') {
      if (titleController.text.isNotNullOrEmpty &&
          powerOnController.text.isNotNullOrEmpty &&
          powerOffController.text.isNotNullOrEmpty &&
          initialTEC.text.isNotNullOrEmpty &&
          dropdownValue.value.isNotNullOrEmpty) {
        String? dropdownDeviceId = devices
            ?.firstWhere((Datum value) {
              return value.name == dropdownValue.value;
            })
            .id
            ?.id;

        var newWidget = AddWidgetRequestModel(
          typeFullFqn: 'system.power_button',
          id: const Uuid().v4(),
          title: titleController.text,
          powerOn: powerOnController.text,
          powerOff: powerOffController.text,
          initialValue: initialTEC.text,
          deviceId: dropdownDeviceId!,
        );
        // i want a copy of GetDashboardWidgetDetailDataModel withe new widget added
        var widgetModel = currentResponse!.data!.configuration!.copyWith(
          widgets: {
            ...currentResponse!.data!.configuration!.widgets!,
            newWidget.id: newWidget.toJson(),
          },
        );

        var requestModel = currentResponse!.data!.copyWith(
          configuration: widgetModel,
        );

        _dashboardItemDetailRepo
            .addWidgetRequest(requestModel: requestModel)
            .then((GetDashboardWidgetDetailResponseModel result) {
              responseHandler(
                statusCode: result.statusCode ?? 0,
                message: result.message ?? '',
                onSuccess: () {
                  Get.back();
                  detectWidget(result);
                  titleController.clear();
                  dataKeyController.clear();
                  initialTEC.clear();
                  powerOnController.clear();
                  powerOffController.clear();
                  dropdownValue('');
                },
              );
            });
      } else {
        Get.snackbar('Error', 'Please Enter All Item');
      }
    } else {
      if (titleController.text.isNotNullOrEmpty &&
          dropdownValue.value.isNotNullOrEmpty) {
        String? dropdownDeviceId = devices
            ?.firstWhere((Datum value) {
              return value.name == dropdownValue.value;
            })
            .id
            ?.id;

        var newWidget = AddWidgetTemperatureRequestModel(
          typeFullFqn: "system.indoor_simple_temperature_chart_card",
          id: const Uuid().v4(),
          title: titleController.text,
          deviceId: dropdownDeviceId!,
        );
        // i want a copy of GetDashboardWidgetDetailDataModel withe new widget added
        var widgetModel = currentResponse!.data!.configuration!.copyWith(
          widgets: {
            ...currentResponse!.data!.configuration!.widgets!,
            newWidget.id: newWidget.toJson(),
          },
        );

        var requestModel = currentResponse!.data!.copyWith(
          configuration: widgetModel,
        );

        _dashboardItemDetailRepo
            .addWidgetRequest(requestModel: requestModel)
            .then((GetDashboardWidgetDetailResponseModel result) {
              responseHandler(
                statusCode: result.statusCode ?? 0,
                message: result.message ?? '',
                onSuccess: () {
                  Get.back();
                  detectWidget(result);
                  titleController.clear();
                  dataKeyController.clear();
                  dropdownValue('');
                },
              );
            });
      } else {
        Get.snackbar('Error', 'Please Enter All Item');
      }
    }
  }
}
