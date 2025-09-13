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
  final RxMap<int, Map<String, dynamic>> subscriptionData =
      <int, Map<String, dynamic>>{}.obs;

  int _generateRandomCmdId() {
    final rand = Random();
    return 100000 + rand.nextInt(900000);
  }

  Future<void> connect() async {
    final url =
        'ws://45.149.76.245:8080/api/ws/plugins/telemetry?token=$authToken';

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
      // SERVER_SCOPE
      final serverCmdId = _generateRandomCmdId();
      _subscriptionToDeviceMap[serverCmdId] = deviceId;
      attrSubCmds.add({
        "entityType": "DEVICE",
        "entityId": deviceId,
        "scope": "SERVER_SCOPE",
        "cmdId": serverCmdId,
      });

      // SHARED_SCOPE
      final sharedCmdId = _generateRandomCmdId();
      _subscriptionToDeviceMap[sharedCmdId] = deviceId;
      attrSubCmds.add({
        "entityType": "DEVICE",
        "entityId": deviceId,
        "scope": "SHARED_SCOPE",
        "cmdId": sharedCmdId,
      });

      // CLIENT_SCOPE
      final clientCmdId = _generateRandomCmdId();
      _subscriptionToDeviceMap[clientCmdId] = deviceId;
      attrSubCmds.add({
        "entityType": "DEVICE",
        "entityId": deviceId,
        "scope": "CLIENT_SCOPE",
        "cmdId": clientCmdId,
      });
    }

    _ws?.add(jsonEncode({
      "tsSubCmds": [],
      "historyCmds": [],
      "attrSubCmds": attrSubCmds,
    }));
  }

  void _onMessage(dynamic message) {
    try {
      final parsed = jsonDecode(message);
      if (parsed is Map && parsed['errorCode'] == 0) {
        final subscriptionId = parsed['subscriptionId'] as int;
        final Map<String, dynamic> safeParsed = Map<String, dynamic>.from(parsed);

        subscriptionData[subscriptionId] = {
          ...?subscriptionData[subscriptionId],
          ...safeParsed
        };

        // بررسی active/inactive
        final data = safeParsed['data'] as Map<String, dynamic>?;
        if (data != null && data.containsKey('active')) {
          final deviceId = _subscriptionToDeviceMap[subscriptionId];
          if (deviceId != null) {
            final activeList = data['active'] as List<dynamic>;
            if (activeList.isNotEmpty) {
              final timestamp = activeList.first[0] as int;
              final isActive = activeList.first[1].toString() == 'true';
              deviceConnectionStatus[deviceId] = isActive;
              lastDeviceActivity[deviceId] =
                  DateTime.fromMillisecondsSinceEpoch(timestamp);
            }
          }
        }
      }
    } catch (e) {
      print('⚠️ Could not parse JSON: $message');
    }
  }

  Future<void> disconnect() async {
    _heartbeatTimer?.cancel();
    _running = false;
    await _ws?.close();
  }
}
