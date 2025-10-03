import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:get/get.dart';
import 'dart:math';

class ReliableSocket extends GetxService {
  String authToken;
  List<String> deviceIds;
  WebSocket? _ws;
  Timer? _heartbeatTimer;
  bool _running = false;

  ReliableSocket(this.authToken, this.deviceIds);

  final Map<int, String> _subscriptionToDeviceMap = {};
  Map<int, String> get subscriptionToDeviceMap => _subscriptionToDeviceMap;

  final RxMap<String, bool> deviceConnectionStatus = <String, bool>{}.obs;
  final RxMap<String, DateTime> lastDeviceActivity = <String, DateTime>{}.obs;
  final RxMap<int, Map<String, dynamic>> subscriptionData = <int, Map<String, dynamic>>{}.obs;

  int _generateRandomCmdId() {
    final rand = Random();
    return 100000 + rand.nextInt(900000);
  }

  Future<void> connect() async {
    final url = 'ws://45.149.76.245:8080/api/ws/plugins/telemetry?token=$authToken';

    while (!_running) {
      try {
        print('🟢 Connecting to WebSocket...');
        _ws = await WebSocket.connect(url);
        print('✅ WebSocket connected');

        _running = true;
        _sendSubscription();

        _heartbeatTimer = Timer.periodic(const Duration(seconds: 10), (_) {
          if (_ws != null) _ws!.add(jsonEncode({"type": "heartbeat"}));
        });

        await for (final message in _ws!) {
          _onMessage(message);
        }
      } catch (e) {
        print('❌ WebSocket error: $e');
        await Future.delayed(const Duration(seconds: 5));
      }
    }
  }

  void _sendSubscription() {
    final List<Map<String, dynamic>> attrSubCmds = [];

    for (final deviceId in deviceIds) {
      for (final scope in ['SERVER_SCOPE', 'SHARED_SCOPE', 'CLIENT_SCOPE']) {
        final cmdId = _generateRandomCmdId();
        _subscriptionToDeviceMap[cmdId] = deviceId;
        attrSubCmds.add({
          "entityType": "DEVICE",
          "entityId": deviceId,
          "scope": scope,
          "cmdId": cmdId,
        });
      }
    }

    _ws?.add(jsonEncode({
      "tsSubCmds": [],
      "historyCmds": [],
      "attrSubCmds": attrSubCmds,
    }));
  }

void _onMessage(dynamic message) {
  if (message is! String) return;

  try {
    final parsed = jsonDecode(message);
    if (parsed is Map && parsed['errorCode'] == 0) {
      final subscriptionId = parsed['subscriptionId'] as int;
      final deviceId = _subscriptionToDeviceMap[subscriptionId] ?? 'unknown';

      // آپدیت subscriptionData
      subscriptionData[subscriptionId] = {
        ...?subscriptionData[subscriptionId],
        ...parsed,
      };

      final data = parsed['data'] as Map<String, dynamic>?;

      if (data != null) {
        // ✅ آپدیت وضعیت آنلاین بر اساس active
        if (data.containsKey('active')) {
          final activeList = data['active'];
          if (activeList is List && activeList.isNotEmpty) {
            final lastEntry = activeList.last;
            final statusValue = lastEntry[1].toString();
            final isActive = statusValue.toLowerCase() == 'true';

            deviceConnectionStatus[deviceId] = isActive;
            deviceConnectionStatus.refresh();
          }
        }

        // ✅ آپدیت آخرین زمان فعالیت (یکبار)
        int? timestamp;

        if (data.containsKey('lastActivityTime')) {
          final lastActivityList = data['lastActivityTime'];
          if (lastActivityList is List && lastActivityList.isNotEmpty) {
            final lastEntry = lastActivityList.last;
            timestamp = lastEntry[0] as int?;
          }
        }

        if (timestamp == null && parsed.containsKey('latestValues')) {
          final latestValues = parsed['latestValues'] as Map<String, dynamic>?;
          if (latestValues != null && latestValues['lastActivityTime'] != null) {
            timestamp = latestValues['lastActivityTime'] as int?;
          }
        }

        if (timestamp != null) {
          lastDeviceActivity[deviceId] =
              DateTime.fromMillisecondsSinceEpoch(timestamp);
          lastDeviceActivity.refresh();
        }
      }
    }
  } catch (e, stack) {
    print('⚠️ Could not parse JSON: $message\nError: $e\nStack: $stack');
  }
}





  Future<void> disconnect() async {
    _heartbeatTimer?.cancel();
    _running = false;
    await _ws?.close();
  }
}
