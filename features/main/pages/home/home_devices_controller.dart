import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:my_app32/app/core/app_utils_mixin.dart';
import 'package:my_app32/app/core/app_enums.dart';
import 'package:my_app32/app/store/user_store_service.dart';
import 'package:my_app32/features/main/models/devices/get_devices_response_model.dart';
import 'package:my_app32/features/main/models/devices/get_devices_request_model.dart';
import 'package:my_app32/features/main/repository/devices_repository.dart';
import 'package:my_app32/features/smart_light/controllers/smart_light_controller.dart';
import 'package:my_app32/app/services/device_socket_service.dart';
import 'dart:async'; // Added for Timer

class HomeDevicesController extends GetxController with AppUtilsMixin {
  HomeDevicesController(this._repo);

  final DevicesRepository _repo;
  String? authToken;

  final RxMap<String, Map<String, String>> deviceSwitchStates =
      <String, Map<String, String>>{}.obs;

  final RxMap<String, Map<String, dynamic>> deviceColorStates =
      <String, Map<String, dynamic>>{}.obs;

  final RxList<String> deviceIds = <String>[].obs;

  late DeviceSocketService _socketService;

  final RxSet<String> devicesWithServerData = <String>{}.obs;

  Timer? _loadingTimeoutTimer;

  Future<void> fetchDeviceColor(String deviceId) async {
    try {
      final token = await UserStoreService.to.getToken();
      final url = Uri.parse(
        'https://jupiniot.ir/api/plugins/telemetry/getDeviceLedColor',
      );
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({"deviceId": deviceId}),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is Map && data.containsKey('ledColor')) {
          deviceColorStates[deviceId] = data['ledColor'];
        }
      }
    } catch (e) {
      print('Error fetching device color: $e');
    }
  }

  @override
  void onInit() async {
    authToken = await UserStoreService.to.getToken();
    print('Auth token set in HomeDevicesController: $authToken');

    _socketService = Get.put(DeviceSocketService());
    _setupSocketService();

    super.onInit();
  }

  void _setupSocketService() {
    _socketService
        .onDeviceStatusUpdate = (String deviceId, Map<String, String> status) {
      print('🔄 Socket update received for device $deviceId: $status');

      final existingStates = deviceSwitchStates[deviceId] ?? {};
      print('🔄 Previous states for device $deviceId: $existingStates');

      deviceSwitchStates[deviceId] = status;
      deviceSwitchStates.refresh();

      devicesWithServerData.add(deviceId);

      print(
        '✅ Updated device states for $deviceId: ${deviceSwitchStates[deviceId]}',
      );
      print('✅ Device $deviceId marked as having server data');

      update();
    };

    ever(_socketService.deviceConnectionStatus, (
      Map<String, bool> deviceStatus,
    ) {
      print('Device connection status updated: $deviceStatus');
      update(); // Trigger UI update
    });
  }

  bool hasRealDeviceData(String deviceId) {
    final states = deviceSwitchStates[deviceId] ?? {};

    final hasAnyData = states.isNotEmpty;

    final hasExpectedKeys =
        states.containsKey('Touch_W1') ||
        states.containsKey('Touch_W2') ||
        states.containsKey('Touch_D1') ||
        states.containsKey('Touch_D2');

    final hasNonEmptyValues =
        (states['Touch_W1']?.isNotEmpty == true) ||
        (states['Touch_W2']?.isNotEmpty == true) ||
        (states['Touch_D1']?.isNotEmpty == true ||
            (states['Touch_D2']?.isNotEmpty == true));

    final hasServerData = devicesWithServerData.contains(deviceId);

    final hasRealData =
        hasAnyData && hasExpectedKeys && hasNonEmptyValues && hasServerData;

    print(
      '🔍 hasRealDeviceData for $deviceId: hasAnyData=$hasAnyData, hasExpectedKeys=$hasExpectedKeys, hasNonEmptyValues=$hasNonEmptyValues, hasServerData=$hasServerData, hasRealData=$hasRealData',
    );
    print('🔍 States for $deviceId: $states');

    return hasRealData;
  }

  bool isAnyDeviceLoading() {
    print('🔍 Checking if any device is loading...');
    for (final deviceId in deviceIds) {
      final hasRealData = hasRealDeviceData(deviceId);
      print('🔍 Device $deviceId - hasRealData: $hasRealData');
      if (!hasRealData) {
        print('🔍 Found loading device: $deviceId');
        return true;
      }
    }
    print('🔍 No devices are loading');
    return false;
  }

  void updateDeviceIds(List<String> newDeviceIds) {
    deviceIds.clear();
    deviceIds.addAll(newDeviceIds);
    print('Updated device IDs: $deviceIds');

    devicesWithServerData.clear();
    print('🧹 Cleared server data tracking for new devices');

    _loadingTimeoutTimer?.cancel();
    _loadingTimeoutTimer = Timer(const Duration(seconds: 10), () {
      print('⏰ Loading timeout reached - forcing all devices to have data');
      for (final deviceId in deviceIds) {
        if (!devicesWithServerData.contains(deviceId)) {
          devicesWithServerData.add(deviceId);
          print('⏰ Force marked device $deviceId as having data');
        }
      }
      update();
    });

    _fetchStatesAndConnect();
  }

  void _initializeDeviceStates() {
    for (final deviceId in deviceIds) {
      if (!deviceSwitchStates.containsKey(deviceId)) {
        deviceSwitchStates[deviceId] = {
          'Touch_W1': 'Touch_W1_Off',
          'Touch_W2': 'Touch_W2_Off',
          'Touch_D1': 'Touch_D1_Off',
          'Touch_D2': 'Touch_D2_Off',
        };
        print('🔧 Initialized default states for device $deviceId');
      }
    }
  }

  void updateDeviceColors(String deviceId, Map<String, dynamic> ledColor) {
    deviceColorStates[deviceId] = ledColor;
    print('Updated colors for device $deviceId: $ledColor');
  }

  Future<void> _fetchStatesAndConnect() async {
    await _connectToSocket();

    for (final deviceId in deviceIds) {
      await fetchDeviceSwitchStates(deviceId);
      await fetchDeviceColor(deviceId);
    }

    Timer(const Duration(seconds: 5), () {
      for (final deviceId in deviceIds) {
        if (!hasRealDeviceData(deviceId)) {
          print('⏰ Timeout: Fetching device $deviceId state via HTTP API');
          fetchDeviceSwitchStates(deviceId);
        }
      }
    });
  }

  Future<void> forceRefreshDeviceStates() async {
    print('🔄 Force refreshing device states...');
    for (final deviceId in deviceIds) {
      await fetchDeviceSwitchStates(deviceId);
    }
    print('✅ Force refresh completed');
  }

  Future<void> _connectToSocket() async {
    if (authToken == null) {
      print('No auth token available for socket connection');
      return;
    }

    if (deviceIds.isNotEmpty) {
      print('Connecting to socket with ${deviceIds.length} devices');
      await _socketService.connect(authToken!, deviceIds: deviceIds.toList());
    }
  }

  Future<void> fetchDeviceSwitchStates(String deviceId) async {
    try {
      if (_socketService.isConnected.value) {
        final socketState = _socketService.getDeviceState(deviceId);
        if (socketState.isNotEmpty) {
          print('📡 Using socket state for device $deviceId: $socketState');
          deviceSwitchStates[deviceId] = socketState;
          return;
        }
      }

      final url =
          'http://45.149.76.245:8080/api/plugins/telemetry/DEVICE/$deviceId/values/attributes';
      print('🌐 Fetching device states from API for device $deviceId');
      final response = await http.get(
        Uri.parse(url),
        headers: {'Authorization': 'Bearer $authToken'},
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        print('📊 API response for device $deviceId: $data');
        final Map<String, String> switchStates = {};
        for (final item in data) {
          if (item['key'] == 'Touch_W1' ||
              item['key'] == 'Touch_W2' ||
              item['key'] == 'Touch_D1' ||
              item['key'] == 'Touch_D2') {
            switchStates[item['key']] = item['value'] ?? '';
            print('🔧 Found switch state: ${item['key']} = ${item['value']}');
          }
        }
        deviceSwitchStates[deviceId] = switchStates;
        print('✅ Updated device states for $deviceId: $switchStates');

        devicesWithServerData.add(deviceId);
        print('✅ Device $deviceId marked as having server data (HTTP)');
      } else {
        print(
          '❌ Failed to fetch switch states for device $deviceId: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('❌ Error fetching switch states for device $deviceId: $e');
    }
  }

  String getSwitchState(String deviceId, String key) {
    final states = deviceSwitchStates[deviceId] ?? {};

    if (states.containsKey(key)) {
      return states[key]!;
    }

    switch (key) {
      case 'Touch_W1':
        return states['Touch_W1'] ?? '';
      case 'Touch_W2':
        return states['Touch_W2'] ?? '';
      case 'Touch_D1':
        return states['Touch_D1'] ?? '';
      case 'Touch_D2':
        return states['Touch_D2'] ?? '';
      default:
        return states[key] ?? '';
    }
  }

  bool isSwitchOn(String deviceId, String switchKey) {
    final state = getSwitchState(deviceId, switchKey);

    final switchKeyLower = switchKey.toLowerCase();
    final stateLower = state.toLowerCase();

    final isOn =
        stateLower.contains('${switchKeyLower}_on') || stateLower == 'on';

    print(
      '🔍 Checking switch $switchKey for device $deviceId: state="$state", isOn=$isOn',
    );
    return isOn;
  }

  void updateSwitchState(String deviceId, String key, String value) {
    if (deviceSwitchStates.containsKey(deviceId)) {
      final existingStates = Map<String, String>.from(
        deviceSwitchStates[deviceId]!,
      );
      existingStates[key] = value;
      deviceSwitchStates[deviceId] = existingStates;
      deviceSwitchStates.refresh();
      print(
        '🔄 Updated switch $key for device $deviceId to $value. All states: $existingStates',
      );
    } else {
      deviceSwitchStates[deviceId] = {key: value};
      deviceSwitchStates.refresh();
      print('🔄 Created new state for device $deviceId: {$key: $value}');
    }
  }

  Future<void> refreshDeviceStates() async {
    for (final deviceId in deviceIds) {
      await fetchDeviceSwitchStates(deviceId);
    }
  }

  Future<void> disconnectSocket() async {
    await _socketService.disconnect();
  }

  Future<void> reconnectSocket() async {
    await _connectToSocket();
  }

  bool isDeviceOnline(String deviceId) {
    return _socketService.isDeviceOnline(deviceId);
  }

  bool getDeviceConnectionStatus(String deviceId) {
    return _socketService.getDeviceConnectionStatus(deviceId);
  }

  RxBool isLoading = RxBool(false);

  @override
  void onClose() {
    _loadingTimeoutTimer?.cancel();
    super.onClose();
  }
}
