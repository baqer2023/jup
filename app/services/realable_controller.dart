import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:my_app32/app/services/realable_socket.dart';
import 'package:collection/collection.dart';

class ReliableSocketController extends GetxController {
  String authToken;
  List<String> deviceIds;
  late ReliableSocket _socket;

  late Box box;

  final RxBool isConnected = false.obs;
  final RxMap<String, bool> deviceConnectionStatus = <String, bool>{}.obs;
  final RxMap<String, DateTime> lastDeviceActivity = <String, DateTime>{}.obs;
  final RxMap<String, RxMap<String, dynamic>> latestDeviceDataById =
      <String, RxMap<String, dynamic>>{}.obs;

  ReliableSocketController(this.authToken, this.deviceIds);

  @override
  void onInit() async {
    super.onInit();

    // باز کردن Hive box
    box = await Hive.openBox('reliable_socket_cache');

    // بارگذاری داده‌های کش شده
    _loadCachedData();

    // ایجاد instance از ReliableSocket
    _socket = ReliableSocket(authToken, deviceIds);

    // گوش دادن به تغییر وضعیت آنلاین/آفلاین دستگاه‌ها
    ever(_socket.deviceConnectionStatus, (status) {
      deviceConnectionStatus.assignAll(status);
      _saveDeviceConnectionStatus();
    });

    // گوش دادن به تغییر آخرین زمان فعالیت دستگاه‌ها
    ever(_socket.lastDeviceActivity, (activity) {
      lastDeviceActivity.assignAll(activity);
      _saveLastDeviceActivity();
    });

    // گوش دادن به تغییرات subscriptionData و آپدیت latestDeviceDataById
    ever(_socket.subscriptionData, (msg) {
      if (msg.isNotEmpty) {
        _updateLatestDeviceData(msg.cast<int, Map<String, dynamic>>());
        _saveLatestDeviceData();
      }
    });

    // شروع اتصال به WebSocket
    connect();
  }

  void _loadCachedData() {
    final cachedConnection = box.get('deviceConnectionStatus');
    if (cachedConnection != null) {
      deviceConnectionStatus.assignAll(Map<String, bool>.from(cachedConnection));
    }

    final cachedActivity = box.get('lastDeviceActivity');
    if (cachedActivity != null) {
      final activityMap = (cachedActivity as Map)
          .map((k, v) => MapEntry(k.toString(), DateTime.parse(v)));
      lastDeviceActivity.assignAll(activityMap);
    }

    final cachedData = box.get('latestDeviceDataById');
    if (cachedData != null) {
      final Map<String, dynamic> dataMap = Map<String, dynamic>.from(cachedData);
      dataMap.forEach((deviceId, value) {
        latestDeviceDataById[deviceId] =
            RxMap<String, dynamic>.of(Map<String, dynamic>.from(value));
      });
    }

    print("📦 Cached ReliableSocket data loaded.");
  }

  void _saveDeviceConnectionStatus() {
    box.put('deviceConnectionStatus', deviceConnectionStatus);
  }

  void _saveLastDeviceActivity() {
    final mapToSave = lastDeviceActivity.map((k, v) => MapEntry(k, v.toIso8601String()));
    box.put('lastDeviceActivity', mapToSave);
  }

  void _saveLatestDeviceData() {
    final mapToSave = latestDeviceDataById.map((k, v) => MapEntry(k, v));
    box.put('latestDeviceDataById', mapToSave);
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

  bool isDeviceConnected(String deviceId) {
    return deviceConnectionStatus[deviceId] ?? false;
  }

  DateTime? getLastActivity(String deviceId) {
    return lastDeviceActivity[deviceId];
  }

  Future<void> toggleSwitch(
    bool isOn,
    int switchNumber,
    String deviceId,
  ) async {
    final key = 'TW$switchNumber';
    final value = isOn ? '${key}_On' : '${key}_Off';

    final payload = {'deviceId': deviceId, 'request': {key: value}};

    final dio = Dio();
    final headers = {'Authorization': 'Bearer $authToken', 'Content-Type': 'application/json; charset=utf-8'};

    try {
      final response = await dio.post(
        'http://45.149.76.245:8080/api/plugins/telemetry/changeDeviceState',
        options: Options(headers: headers),
        data: json.encode(payload),
      );

      if (response.statusCode == 200) {
        final deviceData = latestDeviceDataById[deviceId];
        if (deviceData != null) {
          deviceData[key] = [[DateTime.now().millisecondsSinceEpoch, isOn ? 'On' : 'Off']];
          deviceData.refresh();
          _saveLatestDeviceData();
        }
      } else {
        print('⚠️ Error: ${response.statusMessage}');
      }
    } catch (e) {
      print('⚠️ Dio error toggling switch: $e');
    }
  }


 Future<void> toggleSwitchS(
  bool isOn,
  String deviceId,
) async {
  final key = 'TWPower';
  
  // تبدیل bool به int
  final intValue = isOn ? 1 : 0;

  final payload = {
    'deviceId': deviceId,
    'request': {key: intValue},
  };

  print("device.deviceaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaId");
  print("device.deviceaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaId");
  print("device.deviceaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaId");
  print(payload);
  print("device.deviceaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaId");
  print("device.deviceaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaId");
  print("device.deviceaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaId");

    final dio = Dio();
    final headers = {'Authorization': 'Bearer $authToken', 'Content-Type': 'application/json; charset=utf-8'};

    try {
      final response = await dio.post(
        'http://45.149.76.245:8080/api/plugins/telemetry/changeDeviceState',
        options: Options(headers: headers),
        data: json.encode(payload),
      );

      if (response.statusCode == 200) {
        final deviceData = latestDeviceDataById[deviceId];
        if (deviceData != null) {
          // deviceData[key] = [[DateTime.now().millisecondsSinceEpoch, isOn ? 'On' : 'Off']];
          deviceData.refresh();
          _saveLatestDeviceData();
        }
      } else {
        print('⚠️ Error: ${response.statusMessage}');
      }
    } catch (e) {
      print('⚠️ Dio error toggling switch: $e');
    }
  }

Future<void> updateDeviceSettings({
  required String deviceId,
  required String deviceType,
  // required String maxPower,
  required int selectedMode,
  required double currentTemp,
  required double fanSpeed,
  double? displayTemp,
  double? hysteresis,
  double? pumpDelay,
  double? targetReaction,
}) async {
  final payload = {
    'deviceId': deviceId,
    'request': {
      'TWType': deviceType,
      // 'maxPower': maxPower,
      'TWMode': selectedMode,
      'TWSP': currentTemp,
      'TWFan': fanSpeed,
      if (displayTemp != null) 'TWTempCP': displayTemp,
      if (hysteresis != null) 'TWHyst': hysteresis,
      if (pumpDelay != null) 'TWPumpTimr': pumpDelay,
      if (targetReaction != null) 'TWDuct': targetReaction,
    },
  };

  print("🔹 Sending device settings payload:");
  print(payload);

  final dio = Dio();
  final headers = {
    'Authorization': 'Bearer $authToken',
    'Content-Type': 'application/json; charset=utf-8'
  };

  try {
    final response = await dio.post(
      'http://45.149.76.245:8080/api/plugins/telemetry/changeDeviceState',
      options: Options(headers: headers),
      data: json.encode(payload),
    );

  if (response.statusCode == 200) {
        final deviceData = latestDeviceDataById[deviceId];
        if (deviceData != null) {
          // deviceData[key] = [[DateTime.now().millisecondsSinceEpoch, isOn ? 'On' : 'Off']];
          deviceData.refresh();
          _saveLatestDeviceData();
        }
      } else {
      print('⚠️ Error updating device settings: ${response.statusMessage}');
    }
  } catch (e) {
    print('⚠️ Dio error updating device settings: $e');
  }
}





  void updateSwitchState(String deviceId, String key, String value) {
    if (!latestDeviceDataById.containsKey(deviceId)) {
      latestDeviceDataById[deviceId] = <String, dynamic>{}.obs;
    }

    latestDeviceDataById[deviceId]![key] = [[DateTime.now().millisecondsSinceEpoch, value]];
    latestDeviceDataById[deviceId]!.refresh();
    _saveLatestDeviceData();
  }

  void updateDeviceList(List<String> newDeviceIds) {
    final listEq = const ListEquality<String>();
    if (listEq.equals(deviceIds, newDeviceIds)) return;

    deviceIds = newDeviceIds;

    _socket.disconnect();
    _socket = ReliableSocket(authToken, deviceIds);

    ever(_socket.deviceConnectionStatus, (status) {
      deviceConnectionStatus.assignAll(status);
      _saveDeviceConnectionStatus();
    });

    ever(_socket.lastDeviceActivity, (activity) {
      lastDeviceActivity.assignAll(activity);
      _saveLastDeviceActivity();
    });

    ever(_socket.subscriptionData, (msg) {
      if (msg.isNotEmpty) {
        _updateLatestDeviceData(msg.cast<int, Map<String, dynamic>>());
        _saveLatestDeviceData();
      }
    });

    connect();
  }
}
