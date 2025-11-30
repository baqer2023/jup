import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:get/get.dart';
import 'dart:math';
import 'package:connectivity_plus/connectivity_plus.dart';

class ReliableSocket extends GetxService {
  final String authToken;
  final List<String> deviceIds;

  WebSocket? _ws;
  StreamSubscription? _wsSub;
  Timer? _heartbeatTimer;
  bool _running = false;
  bool _connecting = false;
  bool _disposed = false;

  ReliableSocket(this.authToken, this.deviceIds);

  final Map<int, String> _subscriptionToDeviceMap = {};
  Map<int, String> get subscriptionToDeviceMap => _subscriptionToDeviceMap;

  final RxMap<String, bool> deviceConnectionStatus = <String, bool>{}.obs;
  final RxMap<String, DateTime> lastDeviceActivity = <String, DateTime>{}.obs;
  final RxMap<int, Map<String, dynamic>> subscriptionData =
      <int, Map<String, dynamic>>{}.obs;

  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _connectivitySub;
  Timer? _reconnectDebounce;

  int _generateRandomCmdId() => 100000 + Random().nextInt(900000);

  @override
  void onInit() {
    super.onInit();

    // مانیتور شبکه با debounce
    _connectivitySub = _connectivity.onConnectivityChanged.listen((_) {
      _reconnectDebounce?.cancel();
      _reconnectDebounce = Timer(const Duration(seconds: 2), () async {
        if (!_disposed) {
          print('🌐 Network changed, reconnecting...');
          await reconnectClean();
        }
      });
    });

    connect();
  }

  @override
  void onClose() {
    _disposed = true;
    _reconnectDebounce?.cancel();
    _connectivitySub?.cancel();
    disconnect();
    super.onClose();
  }

  Future<void> connect() async {
    if (_connecting || _disposed) return;
    _connecting = true;

    final url =
        'ws://45.149.76.245:8080/api/ws/plugins/telemetry?token=$authToken';

    await disconnect(); // اطمینان از پاک شدن قبلی

    while (!_disposed) {
      try {
        print('🟢 Connecting to WebSocket...');
        _ws = await WebSocket.connect(url);
        print('✅ WebSocket connected');
        _running = true;
        _connecting = false;

        _sendSubscription();

        _heartbeatTimer?.cancel();
        _heartbeatTimer = Timer.periodic(const Duration(seconds: 10), (_) {
          if (_ws != null && _running) {
            try {
              _ws!.add(jsonEncode({"type": "heartbeat"}));
            } catch (e) {
              print('⚠️ Heartbeat send error: $e');
            }
          }
        });

        _wsSub?.cancel();
        _wsSub = _ws!.listen(
          (message) => _onMessage(message),
          onDone: () {
            print('⚠️ WebSocket closed');
            if (!_disposed) reconnectClean();
          },
          onError: (err) {
            print('❌ WebSocket error: $err');
            if (!_disposed) reconnectClean();
          },
          cancelOnError: true,
        );

        break;
      } catch (e) {
        print('❌ Connect error: $e');
        _running = false;
        _connecting = false;
        await Future.delayed(const Duration(seconds: 3));
      }
    }
  }

  Future<void> reconnectClean() async {
    if (_connecting || _disposed) return;
    print('♻️ Reconnecting cleanly...');
    await disconnect();
    await Future.delayed(const Duration(milliseconds: 300));
    if (!_disposed) await connect();
  }

  void _sendSubscription() {
    if (_ws == null) return;

    _subscriptionToDeviceMap.clear();
    subscriptionData.clear();

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

    final payload = {
      "tsSubCmds": [],
      "historyCmds": [],
      "attrSubCmds": attrSubCmds,
    };

    try {
      _ws!.add(jsonEncode(payload));
      print('📨 Subscribed to ${deviceIds.length} devices.');
    } catch (e) {
      print('⚠️ Subscription send error: $e');
    }
  }

  void _onMessage(dynamic message) {
    if (message is! String) return;
    try {
      final parsed = jsonDecode(message);
      print(parsed);
      if (parsed is! Map) return;

      final subId = parsed['subscriptionId'];
      if (subId == null) return;

      final subIdInt = subId is int ? subId : int.tryParse(subId.toString());
      if (subIdInt == null) return;

      final deviceId = _subscriptionToDeviceMap[subIdInt] ?? 'unknown';
      final data = parsed['data'] as Map<String, dynamic>?;

      if (data == null) return;

      final Map<String, dynamic> parsedMap = Map<String, dynamic>.from(parsed);
      subscriptionData[subIdInt] = parsedMap;

      if (data.containsKey('active')) {
        final activeList = data['active'];
        if (activeList is List && activeList.isNotEmpty) {
          final last = activeList.last;
          final status = last is List && last.length > 1
              ? last[1].toString()
              : last.toString();
          final isActive = status.toLowerCase() == 'true';
          deviceConnectionStatus[deviceId] = isActive;
          deviceConnectionStatus.refresh();
        }
      }

      if (data.containsKey('lastActivityTime')) {
        final lastActivity = data['lastActivityTime'];
        if (lastActivity is List && lastActivity.isNotEmpty) {
          final last = lastActivity.last;
          if (last is List && last.isNotEmpty) {
            final ts = last[0] is int
                ? last[0]
                : int.tryParse(last[0].toString());
            if (ts != null) {
              lastDeviceActivity[deviceId] =
                  DateTime.fromMillisecondsSinceEpoch(ts);
              lastDeviceActivity.refresh();
            }
          }
        }
      }
    } catch (e) {
      print('⚠️ Parse error: $e');
    }
  }

  Future<void> disconnect() async {
    print('🛑 Disconnecting...');
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;

    _running = false;
    _connecting = false;

    // قطع کامل listener WebSocket
    try {
      await _wsSub?.cancel();
    } catch (_) {}
    _wsSub = null;

    // قطع کامل WebSocket
    try {
      await _ws?.close();
    } catch (_) {}
    _ws = null;

    // پاک کردن subscription ها
    _subscriptionToDeviceMap.clear();
    subscriptionData.clear();
  }
}
