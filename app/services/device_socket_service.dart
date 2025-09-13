import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class DeviceSocketService extends GetxService {
  WebSocketChannel? _wsChannel;
  Timer? _reconnectTimer;
  Timer? _heartbeatTimer;

  final RxBool isConnected = false.obs;
  final RxString connectionStatus = 'Disconnected'.obs;

  String? _authToken;
  List<String> _subscribedDevices = [];

  final Map<int, String> _subscriptionToDeviceMap = {};

  Function(String deviceId, Map<String, String> status)? onDeviceStatusUpdate;

  final RxMap<String, Map<String, String>> deviceStates =
      <String, Map<String, String>>{}.obs;

  final RxMap<String, bool> deviceConnectionStatus = <String, bool>{}.obs;
  final RxMap<String, DateTime> lastDeviceActivity = <String, DateTime>{}.obs;

  int _consecutiveErrors = 0;
  static const int _maxConsecutiveErrors = 5;

  @override
  void onInit() {
    super.onInit();
    _setupHeartbeat();
  }

  @override
  void onClose() {
    disconnect();
    _reconnectTimer?.cancel();
    _heartbeatTimer?.cancel();
    super.onClose();
  }

  void _setupHeartbeat() {
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (isConnected.value) {
        _sendHeartbeat();
      }
    });
  }

  void _sendHeartbeat() {
    if (_wsChannel != null && isConnected.value) {
      try {
        final heartbeatMsg = {
          "type": "heartbeat",
          "timestamp": DateTime.now().millisecondsSinceEpoch
        };
        _wsChannel!.sink.add(jsonEncode(heartbeatMsg));
      } catch (e) {
        print('Error sending heartbeat: $e');
      }
    }
  }

  Future<void> connect(String authToken,
      {List<String> deviceIds = const []}) async {
    if (isConnected.value) {
      await disconnect();
    }

    _authToken = authToken;
    _subscribedDevices = List.from(deviceIds);

    _consecutiveErrors = 0;

    for (final deviceId in deviceIds) {
      _updateDeviceConnectionStatus(deviceId, false); // Start as offline
    }

    try {
      connectionStatus.value = 'Connecting...';

      final url =
          'ws://45.149.76.245:8080/api/ws/plugins/telemetry?token=$authToken';
      _wsChannel = WebSocketChannel.connect(Uri.parse(url));

      _wsChannel!.stream.listen(
        _handleMessage,
        onDone: _handleDisconnection,
        onError: _handleError,
      );

      isConnected.value = true;
      connectionStatus.value = 'Connected';

      await _subscribeToDevices(deviceIds);

      await _refreshDeviceStates();

      print('WebSocket connected successfully');

      for (final deviceId in deviceIds) {
        await fetchDeviceStatus(deviceId);
      }
    } catch (e) {
      print('Error connecting to WebSocket: $e');
      connectionStatus.value = 'Connection failed';
      _scheduleReconnect();
    }
  }

  Future<void> _subscribeToDevices(List<String> deviceIds) async {
    if (_wsChannel == null || !isConnected.value) return;

    try {
      for (final deviceId in deviceIds) {
        final cmdId = _generateCmdId();
        final subscribeMsg = {
          "tsSubCmds": [],
          "historyCmds": [],
          "attrSubCmds": [
            {
              "entityType": "DEVICE",
              "entityId": deviceId,
              "scope": "CLIENT_SCOPE", // Use CLIENT_SCOPE as in your Postman
              "cmdId": cmdId
            }
          ]
        };

        _subscriptionToDeviceMap[cmdId] = deviceId;

        _wsChannel!.sink.add(jsonEncode(subscribeMsg));
        print('Subscribed to device: $deviceId with cmdId: $cmdId');
      }
    } catch (e) {
      print('Error subscribing to devices: $e');
    }
  }

  int _generateCmdId() {
    return DateTime.now().millisecondsSinceEpoch % 1000000;
  }

  void _handleMessage(dynamic message) {
    try {
      final data = jsonDecode(message);
      print('Received WebSocket message: $data');

      if (data is Map) {
        if (data.containsKey('errorCode') &&
            data['errorCode'] != null &&
            data['errorCode'] != 0) {
          final errorCode = data['errorCode'];
          final errorMsg = data['errorMsg'] ?? 'Unknown error';
          print('❌ WebSocket error received: Code $errorCode - $errorMsg');

          for (final deviceId in _subscribedDevices) {
            _updateDeviceConnectionStatus(deviceId, false);
          }

          _consecutiveErrors++;
          print(
              '❌ Consecutive errors: $_consecutiveErrors/$_maxConsecutiveErrors');

          if (_consecutiveErrors >= _maxConsecutiveErrors) {
            print('❌ Too many consecutive errors, disconnecting...');
            isConnected.value = false;
            connectionStatus.value = 'Too many errors';
            disconnect();
            return;
          }

          isConnected.value = false;
          connectionStatus.value = 'Error: $errorMsg';

          return;
        }

        _consecutiveErrors = 0;

        if (data.containsKey('subscriptionId') && data.containsKey('data')) {
          final subscriptionId = data['subscriptionId'];
          final telemetryData = data['data'];
          if (telemetryData is Map) {
            final deviceId = _subscriptionToDeviceMap[subscriptionId];
            if (deviceId != null) {
              print(
                  '📡 Processing telemetry for device $deviceId (subscription: $subscriptionId)');
              _handleTelemetryData(telemetryData, deviceId);
            } else {
              print(
                  '⚠️ Unknown subscription ID: $subscriptionId, available mappings: $_subscriptionToDeviceMap');
              _handleTelemetryData(telemetryData);
            }
          }
        } else if (data.containsKey('data')) {
          final telemetryData = data['data'];
          if (telemetryData is Map) {
            print('📡 Processing telemetry without subscription ID');
            _handleTelemetryData(telemetryData);
          }
        } else if (data.containsKey('attributes')) {
          _handleAttributeData(data['attributes']);
        } else if (data.containsKey('type') && data['type'] == 'pong') {
          print('Received heartbeat response');
        }
      }
    } catch (e) {
      print('Error parsing WebSocket message: $e');
      isConnected.value = false;
      connectionStatus.value = 'Parse Error: $e';
    }
  }

  void _handleTelemetryData(dynamic data, [String? providedDeviceId]) {
    if (data is Map) {
      print('Telemetry data: $data');

      String? deviceId = providedDeviceId;

      if (deviceId == null && data.containsKey('deviceId')) {
        deviceId = data['deviceId'].toString();
        print('📱 Found device ID in data: $deviceId');
      }

      if (deviceId == null && _subscribedDevices.isNotEmpty) {
        deviceId = _subscribedDevices.first;
        print('📱 Using fallback device ID: $deviceId');
      }

      if (deviceId == null) {
        print('❌ No device ID found for telemetry data: $data');
        return;
      }

      print('Processing telemetry for device: $deviceId');

      if (deviceId != null) {
        final existingStates =
            Map<String, String>.from(deviceStates[deviceId] ?? {});

        data.forEach((key, value) {
          print('Processing key: $key with value: $value');
          if (value is List && value.isNotEmpty) {
            final latestEntry = value.last;
            if (latestEntry is List && latestEntry.length >= 2) {
              final statusValue = latestEntry[1].toString();
              print('Extracted status value for $key: $statusValue');

              switch (key) {
                case 'Touch_W1':
                  existingStates['Touch_W1'] = statusValue;
                  break;
                case 'Touch_W2':
                  existingStates['Touch_W2'] = statusValue;
                  break;
                case 'Touch_D1':
                  existingStates['Touch_D1'] = statusValue;
                  break;
                case 'Touch_D2':
                  existingStates['Touch_D2'] = statusValue;
                  break;
                case 'ledColor':
                  if (statusValue.startsWith('{')) {
                    try {
                      final colorData = jsonDecode(statusValue);
                      existingStates['ledColor'] = statusValue;
                    } catch (e) {
                      print('Error parsing LED color data: $e');
                    }
                  }
                  break;
              }
            }
          }
        });

        if (existingStates.isNotEmpty) {
          deviceStates[deviceId] = existingStates;

          _updateDeviceConnectionStatus(deviceId, true);

          onDeviceStatusUpdate?.call(deviceId, existingStates);

          print(
              'Device $deviceId status updated via telemetry: $existingStates');
        } else {
          print('No valid status data found for device $deviceId');
          _updateDeviceConnectionStatus(deviceId, false);
        }
      }
    }
  }

  void _handleAttributeData(dynamic data) {
    if (data is Map) {
      final deviceId = data['deviceId'];
      if (deviceId != null) {
        final statusMap = <String, String>{};

        if (data.containsKey('touch_1_status')) {
          statusMap['touch_1_status'] = data['touch_1_status'].toString();
        }
        if (data.containsKey('touch_2_status')) {
          statusMap['touch_2_status'] = data['touch_2_status'].toString();
        }

        if (statusMap.isNotEmpty) {
          deviceStates[deviceId] = statusMap;

          onDeviceStatusUpdate?.call(deviceId, statusMap);

          print('Device $deviceId status updated: $statusMap');
        }
      }
    }
  }

  void _handleDisconnection() {
    print('WebSocket disconnected');
    isConnected.value = false;
    connectionStatus.value = 'Disconnected';
    _scheduleReconnect();
  }

  void _handleError(error) {
    print('WebSocket error: $error');
    isConnected.value = false;
    connectionStatus.value = 'Error: $error';
    _scheduleReconnect();
  }

  void _scheduleReconnect() {
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(const Duration(seconds: 5), () {
      if (!isConnected.value && _authToken != null) {
        print('Attempting to reconnect...');
        connect(_authToken!, deviceIds: _subscribedDevices);
      }
    });
  }

  Future<void> disconnect() async {
    _reconnectTimer?.cancel();

    if (_wsChannel != null) {
      try {
        await _wsChannel!.sink.close(status.goingAway);
      } catch (e) {
        print('Error closing WebSocket: $e');
      }
      _wsChannel = null;
    }

    for (final deviceId in _subscribedDevices) {
      _updateDeviceConnectionStatus(deviceId, false);
    }

    isConnected.value = false;
    connectionStatus.value = 'Disconnected';
    print('WebSocket disconnected');
  }

  Future<Map<String, String>?> fetchDeviceStatus(String deviceId) async {
    try {
      final url =
          'http://45.149.76.245:8080/api/plugins/telemetry/DEVICE/$deviceId/values/attributes';
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $_authToken',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final Map<String, String> statusMap = {};

        for (final item in data) {
          if (item['key'] == 'Touch_W1' ||
              item['key'] == 'Touch_W2' ||
              item['key'] == 'Touch_D1' ||
              item['key'] == 'Touch_D2') {
            statusMap[item['key']] = item['value'] ?? '';
          }
        }

        deviceStates[deviceId] = statusMap;

        _updateDeviceConnectionStatus(deviceId, true);

        onDeviceStatusUpdate?.call(deviceId, statusMap);

        return statusMap;
      }
    } catch (e) {
      print('Error fetching device status for $deviceId: $e');
    }
    return null;
  }

  Map<String, String> getDeviceState(String deviceId) {
    return deviceStates[deviceId] ?? {};
  }

  bool isSwitchOn(String deviceId, String switchKey) {
    final state = deviceStates[deviceId]?[switchKey];
    return state?.toLowerCase() == 'on';
  }

  bool isDeviceOnline(String deviceId) {
    return deviceConnectionStatus[deviceId] ?? false;
  }

  bool getDeviceConnectionStatus(String deviceId) {
    return deviceConnectionStatus[deviceId] ?? false;
  }

  void _updateDeviceConnectionStatus(String deviceId, bool isOnline) {
    deviceConnectionStatus[deviceId] = isOnline;
    if (isOnline) {
      lastDeviceActivity[deviceId] = DateTime.now();
    }
    print(
        '📡 Device $deviceId connection status: ${isOnline ? "Online" : "Offline"}');
  }

  Future<void> _refreshDeviceStates() async {
    for (final deviceId in _subscribedDevices) {
      try {
        final status = await fetchDeviceStatus(deviceId);
        if (status != null) {
          print('Refreshed device $deviceId status: $status');
        }
      } catch (e) {
        print('Error refreshing device $deviceId status: $e');
      }
    }
  }
}
