import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:my_app32/app/services/realable_socket.dart';
// import 'reliable_socket.dart';

class ReliableSocketController extends GetxController {
  String authToken;
  List<String> deviceIds;

  late ReliableSocket _socket;

  final RxBool isConnected = false.obs;
  final RxMap<String, bool> deviceConnectionStatus = <String, bool>{}.obs;
  final RxMap<String, DateTime> lastDeviceActivity = <String, DateTime>{}.obs;
  final RxMap<String, RxMap<String, dynamic>> latestDeviceDataById =
      <String, RxMap<String, dynamic>>{}.obs;

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
      if (msg.isNotEmpty) {
        _updateLatestDeviceData(msg.cast<int, Map<String, dynamic>>());
      }
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

  Future<void> disconnect() async {
    await _socket.disconnect();
    isConnected.value = false;
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
        // بررسی نوع val (لیست)
        if (val is List && val.isNotEmpty) {
          final existing = latestDeviceDataById[deviceId]![key] as List<dynamic>? ?? [];
          existing.addAll(val);
          existing.sort((a, b) => (b[0] as int).compareTo(a[0] as int));
          latestDeviceDataById[deviceId]![key] = existing;
        } else {
          latestDeviceDataById[deviceId]![key] = val;
        }
      });

      latestDeviceDataById[deviceId] = latestDeviceDataById[deviceId]!;
    });
  }

  RxMap<String, dynamic>? getDeviceData(String deviceId) {
    return latestDeviceDataById[deviceId];
  }

  bool isDeviceConnected(String deviceId) {
    return deviceConnectionStatus[deviceId] ?? false;
  }

  DateTime? getLastActivity(String deviceId) {
    return lastDeviceActivity[deviceId];
  }

  Future<void> toggleSwitch(bool isOn, int switchNumber, String deviceId) async {
    final keyW = 'Touch_W$switchNumber';
    final keyD = 'Touch_D$switchNumber';
    final valueW = isOn ? '${keyW}_On' : '${keyW}_Off';
    final valueD = isOn ? '${keyD}_On' : '${keyD}_Off';

    final payload = {
      'deviceId': deviceId,
      'request': {keyW: valueW, keyD: valueD},
    };

    try {
      final response = await http.post(
        Uri.parse(
          'http://45.149.76.245:8080/api/plugins/telemetry/changeDeviceState',
        ),
        headers: {
          'Authorization': 'Bearer $authToken',
          'Content-Type': 'application/json; charset=utf-8',
        },
        body: json.encode(payload),
      );

      if (response.statusCode == 200) {
        updateSwitchState(deviceId, keyW, valueW);
        updateSwitchState(deviceId, keyD, valueD);
        await Future.delayed(const Duration(milliseconds: 500));
      }
    } catch (_) {}
  }

  void updateSwitchState(String deviceId, String key, String value) {
    if (!latestDeviceDataById.containsKey(deviceId)) {
      latestDeviceDataById[deviceId] = <String, dynamic>{}.obs;
    }
    latestDeviceDataById[deviceId]![key] = [
      [DateTime.now().millisecondsSinceEpoch, value]
    ];
    latestDeviceDataById[deviceId] = latestDeviceDataById[deviceId]!;
  }
}
