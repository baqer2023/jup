import 'dart:ui';

import 'package:get/get_rx/src/rx_types/rx_types.dart';

class DeviceKeyState {
  final bool isOn;
  final Color color;

  DeviceKeyState({required this.isOn, required this.color});
}

class DeviceState {
  final List<DeviceKeyState> keys;

  DeviceState({required this.keys});
}

RxMap<String, DeviceState> deviceStates = <String, DeviceState>{}.obs;
