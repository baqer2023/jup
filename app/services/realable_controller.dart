import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:my_app32/app/services/realable_socket.dart';
import 'package:collection/collection.dart';

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
    print('🔄 Netwssssssssssssssssssssssssssssssssssssork changed: $deviceIds');

    // ایجاد instance از ReliableSocket
    _socket = ReliableSocket(authToken, deviceIds);

    // گوش دادن به تغییر وضعیت آنلاین/آفلاین دستگاه‌ها
    ever(_socket.deviceConnectionStatus, (status) {
      deviceConnectionStatus.assignAll(status);
    });

    // گوش دادن به تغییر آخرین زمان فعالیت دستگاه‌ها
    ever(_socket.lastDeviceActivity, (activity) {
      lastDeviceActivity.assignAll(activity);
    });

    // گوش دادن به تغییرات subscriptionData و آپدیت latestDeviceDataById
    ever(_socket.subscriptionData, (msg) {
      if (msg.isNotEmpty) {
        _updateLatestDeviceData(msg.cast<int, Map<String, dynamic>>());
      }
    });

    // شروع اتصال به WebSocket
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
      final deviceId =
          subscriptionMap[subscriptionId] ?? subscriptionId.toString();
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

  /// فقط آنلاین یا آفلاین بودن دستگاه
  bool isDeviceConnected(String deviceId) {
    return deviceConnectionStatus[deviceId] ?? false;
  }

  /// گرفتن زمان آخرین فعالیت دستگاه (حتی اگه آفلاین باشه)
  DateTime? getLastActivity(String deviceId) {
    return lastDeviceActivity[deviceId];
  }

  /// تغییر وضعیت سوئیچ
  Future<void> toggleSwitch(
    bool isOn,
    int switchNumber,
    String deviceId,
  ) async {
    // 🧩 کلید جدید طبق ساختار TW1, TW2, ...
    final key = 'TW$switchNumber';
    final value = isOn ? '${key}_On' : '${key}_Off';

    // 📦 ساخت بدنه (payload) طبق فرمت جدید
    final payload = {
      'deviceId': deviceId,
      'request': {key: value},
    };
    print(payload);
    final dio = Dio();
    final headers = {
      'Authorization': 'Bearer $authToken',
      'Content-Type': 'application/json; charset=utf-8',
    };

    try {
      final response = await dio.post(
        'http://45.149.76.245:8080/api/plugins/telemetry/changeDeviceState',
        options: Options(headers: headers),
        data: json.encode(payload),
      );

      if (response.statusCode == 200) {
        print('✅ Switch $switchNumber toggled successfully.');
        print('Response: ${response.data}');

        final deviceData = latestDeviceDataById[deviceId];
        if (deviceData != null) {
          deviceData[key] = [
            [DateTime.now().millisecondsSinceEpoch, isOn ? 'On' : 'Off'],
          ];
          deviceData.refresh();
        }

        await Future.delayed(const Duration(milliseconds: 500));
      } else {
        print('⚠️ Error: ${response.statusMessage}');
      }
    } catch (e) {
      print('⚠️ Dio error toggling switch: $e');
    }
  }

  /// آپدیت وضعیت سوئیچ
  void updateSwitchState(String deviceId, String key, String value) {
    if (!latestDeviceDataById.containsKey(deviceId)) {
      latestDeviceDataById[deviceId] = <String, dynamic>{}.obs;
    }

    latestDeviceDataById[deviceId]![key] = [
      [DateTime.now().millisecondsSinceEpoch, value],
    ];
    latestDeviceDataById[deviceId]!.refresh();
  }

  void updateDeviceList(List<String> newDeviceIds) {
    // ایجاد instance از ListEquality برای مقایسه دو لیست
    final listEq = const ListEquality<String>();

    // بررسی اینکه آیا واقعاً لیست تغییر کرده یا نه
    if (listEq.equals(deviceIds, newDeviceIds)) return;

    print('🔄 Updating device list: $newDeviceIds');
    deviceIds = newDeviceIds;

    // قطع اتصال قبلی
    _socket.disconnect();

    // ایجاد یک Socket جدید با لیست جدید دستگاه‌ها
    _socket = ReliableSocket(authToken, deviceIds);

    // راه‌اندازی مجدد listenerها
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

    // اتصال مجدد
    connect();
  }
}
