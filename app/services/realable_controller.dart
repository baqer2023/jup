import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:my_app32/app/services/realable_socket.dart';

class ReliableSocketController extends GetxController {
  String authToken;
  List<String> deviceIds;
  late ReliableSocket _socket;

  final RxBool isConnected = false.obs;
  final RxMap<String, bool> deviceConnectionStatus = <String, bool>{}.obs;
  final RxMap<String, DateTime> lastDeviceActivity = <String, DateTime>{}.obs;
  final RxMap<String, RxMap<String, dynamic>> latestDeviceDataById = <String, RxMap<String, dynamic>>{}.obs;

  ReliableSocketController(this.authToken, this.deviceIds);

  @override
  void onInit() {
    super.onInit();
    _socket = ReliableSocket(authToken, deviceIds);

    ever(_socket.deviceConnectionStatus, (status) {
      deviceConnectionStatus.assignAll(status);
    });

    ever(_socket.lastDeviceActivity, (activity) {
      lastDeviceActivity.assignAll(activity);
    });

    ever(_socket.subscriptionData, (msg) {
      if (msg.isNotEmpty) _updateLatestDeviceData(msg.cast<int, Map<String, dynamic>>());
    });

    connect();
  }

  Future<void> connect() async {
    try {
      await _socket.connect();
      isConnected.value = true;
    } catch (_) {
      isConnected.value = false;
    }
  }

  void _updateLatestDeviceData(Map<int, Map<String, dynamic>> payload) {
    final subscriptionMap = _socket.subscriptionToDeviceMap;

    payload.forEach((subscriptionId, value) {
      final deviceId = subscriptionMap[subscriptionId] ?? subscriptionId.toString();
      final Map<String, dynamic> valueData = value['data'] != null
          ? Map<String, dynamic>.from(value['data'])
          : Map<String, dynamic>.from(value);

      if (!latestDeviceDataById.containsKey(deviceId)) {
        latestDeviceDataById[deviceId] = <String, dynamic>{}.obs;
      }

      valueData.forEach((key, val) {
        if (val is List && val.isNotEmpty) {
          latestDeviceDataById[deviceId]![key] = [val.last];
        } else {
          latestDeviceDataById[deviceId]![key] = val;
        }
      });

      latestDeviceDataById[deviceId]!.refresh();
    });
  }

  /// وضعیت آنلاین دستگاه:
  /// اگر در `deviceConnectionStatus` آنلاین بود true برمی‌گرداند
  /// اگر اخیراً فعالیت داشته (آخرین ۳۰ ثانیه) آنلاین هم در نظر می‌گیرد
  bool isDeviceConnected(String deviceId) {
    final connected = deviceConnectionStatus[deviceId];
    if (connected != null && connected) return true;

    final lastSeen = lastDeviceActivity[deviceId];
    if (lastSeen != null && DateTime.now().difference(lastSeen) < const Duration(seconds: 30)) {
      return true;
    }

    return false;
  }

  DateTime? getLastActivity(String deviceId) => lastDeviceActivity[deviceId];

  /// تغییر وضعیت سوئیچ
  Future<void> toggleSwitch(bool isOn, int switchNumber, String deviceId) async {
    final keyW = 'Touch_W$switchNumber';
    final keyD = 'Touch_D$switchNumber';
    final valueW = isOn ? '${keyW}_On' : '${keyW}_Off';
    final valueD = isOn ? '${keyD}_On' : '${keyD}_Off';

    final payload = {'deviceId': deviceId, 'request': {keyW: valueW}};

    try {
      final response = await http.post(
        Uri.parse('http://45.149.76.245:8080/api/plugins/telemetry/changeDeviceState'),
        headers: {
          'Authorization': 'Bearer $authToken',
          'Content-Type': 'application/json; charset=utf-8'
        },
        body: json.encode(payload),
      );

      if (response.statusCode == 200) {
        final deviceData = latestDeviceDataById[deviceId];
        if (deviceData != null) {
          deviceData[keyW] = [[DateTime.now().millisecondsSinceEpoch, isOn ? 'On' : 'Off']];
          deviceData[keyD] = [[DateTime.now().millisecondsSinceEpoch, isOn ? 'On' : 'Off']];
          deviceData.refresh();
        }

        await Future.delayed(const Duration(milliseconds: 500));
      }
    } catch (e) {
      print('⚠️ Error toggling switch: $e');
    }
  }

  /// آپدیت وضعیت سوئیچ
  void updateSwitchState(String deviceId, String key, String value) {
    if (!latestDeviceDataById.containsKey(deviceId)) {
      latestDeviceDataById[deviceId] = <String, dynamic>{}.obs;
    }

    latestDeviceDataById[deviceId]![key] = [
      [DateTime.now().millisecondsSinceEpoch, value]
    ];
    latestDeviceDataById[deviceId]!.refresh();
  }
}
