import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../constant/constant.dart';
import 'package:my_app32/app/core/base/base_repository.dart';
import 'package:my_app32/app/models/response_model.dart';

class SmartLightRepository extends BaseRepository {
  Future<ResponseModel> changeDeviceState({
    required String deviceId,
    required String touchStatus,
  }) async {
    return await request(
      url: 'api/plugins/telemetry/changeDeviceState',
      method: 'POST',
      data: {
        'deviceId': deviceId,
        'request': {'touch_1_status': touchStatus},
      },
      requiredToken: true,
    );
  }
}

class SmartLightController extends GetxController {
  final PanelController pc = PanelController();

  final RxBool isTappedOnColor = false.obs;
  final RxBool isLightOff = false.obs;
  final RxList<bool> isSelected = [true, false].obs;
  final RxDouble lightIntensity = 65.0.obs;
  final RxInt selectedIndex = 0.obs;
  final Rx<Color> lightColor = const Color(0xFF2196F3).obs;
  final RxString lightImage = 'assets/images/purple.png'.obs;
  final isOn = false.obs;
  final intensity = 50.0.obs;
  final selectedColor = const Color(0xFFFFFFFF).obs;

  String? deviceId;
  String? authToken;
  Map<String, dynamic>? dashboardConfig;
  final SmartLightRepository _repo = SmartLightRepository();

  RxDouble temperature = 0.0.obs;
  RxString color = ''.obs;

  @override
  void onInit() {
    super.onInit();
  }

  void setDeviceId(String id) {
    deviceId = id;
  }

  void setAuthToken(String token) {
    authToken = token;
  }

  void setDashboardConfig(Map<String, dynamic> config) {
    dashboardConfig = config;
    fetchDeviceStatusFromDashboardConfig();
  }

  Future<void> changeDeviceState(String touchStatus) async {
    if (deviceId == null) {
      Get.snackbar(
        'Error',
        'Device ID not set',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    try {
      print(
        'Changing device state for device: $deviceId with status: $touchStatus',
      );
      final response = await _repo.changeDeviceState(
        deviceId: deviceId!,
        touchStatus: touchStatus,
      );
      if (response.success) {
        print('Device state changed successfully');
        isOn.value = touchStatus == 't_2_on';
      } else {
        Get.snackbar(
          'Error',
          'Failed to change device state: ${response.body}',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      print('Error changing device state: $e');
      Get.snackbar(
        'Error',
        'Failed to change device state: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void togglePower(bool value) {
    isOn.value = value;
    changeDeviceState(value ? 't_2_on' : 't_2_off');
  }

  void changeIntensity(double value) {
    intensity.value = value;
  }

  void updateColor(Color color) {
    selectedColor.value = color;
  }

  void onColorTap() {
    isTappedOnColor.value = true;
    pc.open();
  }

  void onScheduleTap() {
    isTappedOnColor.value = false;
    pc.open();
  }

  void lightSwitch(bool value) {
    isLightOff.value = value;
  }

  void onPanelClosed() {
    if (isTappedOnColor.value) {
      isTappedOnColor.value = false;
    }
  }

  void changeColor({required int currentIndex}) {
    selectedIndex.value = currentIndex;
    lightColor.value = Constants.colors[currentIndex].color;
    updateColor(Constants.colors[currentIndex].color);
    changeImage();
  }

  void changeImage() {
    lightImage.value = Constants.colors[selectedIndex.value].image;
  }

  void onToggleTapped(int index) {
    for (int i = 0; i < isSelected.length; i++) {
      isSelected[i] = i == index;
    }
  }

  void changeLightIntensity(double value) {
    lightIntensity.value = value;
    changeIntensity(value);
  }

  String _getColorName(int index) {
    switch (index) {
      case 0:
        return 'purple';
      case 1:
        return 'green';
      case 2:
        return 'yellow';
      case 3:
        return 'blue';
      default:
        return 'purple';
    }
  }

  Future<void> fetchDeviceStatusFromDashboardConfig() async {
    final deviceId =
        dashboardConfig?['config']?['datasources']?[0]?['deviceId'];
    if (deviceId == null) {
      print('Device ID not found in dashboard config');
      return;
    }
    final url =
        'http://45.149.76.245:8080/api/plugins/telemetry/DEVICE/$deviceId/values/timeseries?keys=temperature,color';
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {'Authorization': 'Bearer $authToken'},
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Telemetry response: $data');
        if (data['temperature'] != null && data['temperature'].isNotEmpty) {
          temperature.value =
              double.tryParse(data['temperature'][0]['value']) ?? 0.0;
        }
        if (data['color'] != null && data['color'].isNotEmpty) {
          color.value = data['color'][0]['value'];
        }
      } else {
        print('Failed to fetch device status: \\${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching device status: $e');
    }
  }
}
