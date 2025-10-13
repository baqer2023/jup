import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:get/get.dart';
import 'dart:math';
import 'package:connectivity_plus/connectivity_plus.dart';

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

  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _connectivitySub;

  int _generateRandomCmdId() {
    final rand = Random();
    return 100000 + rand.nextInt(900000);
  }

  @override
  void onInit() {
    super.onInit();

    // گوش دادن به تغییر شبکه
    _connectivitySub = _connectivity.onConnectivityChanged.listen((
      List<ConnectivityResult> resultList,
    ) {
      print('🔄 Network changed: $resultList');
      
      if (!_running) connect();
    });
  }

  @override
  void onClose() {
    _connectivitySub?.cancel();
    disconnect();
    super.onClose();
  }

  Future<void> connect() async {
    final url =
        'ws://45.149.76.245:8080/api/ws/plugins/telemetry?token=$authToken';

    while (true) {
      try {
        print('🟢 Connecting to WebSocket...');
        _ws = await WebSocket.connect(url);
        print('✅ WebSocket connected');
        

        _running = true;
        _sendSubscription();

        _heartbeatTimer?.cancel();
        _heartbeatTimer = Timer.periodic(const Duration(seconds: 10), (_) {
          if (_ws != null && _running) {
            _ws!.add(jsonEncode({"type": "heartbeat"}));
          }
        });

        _ws!.listen(
          (message) => _onMessage(message),
          onDone: () {
            print('⚠️ WebSocket closed');
            _running = false;
          },
          onError: (err) {
            print('❌ WebSocket error: $err');
            _running = false;
          },
          cancelOnError: true,
        );

        // منتظر بمون تا WebSocket قطع بشه
        while (_running) {
          await Future.delayed(const Duration(seconds: 1));
        }
      } catch (e) {
        print('❌ Connect error: $e');
      }

      // تلاش مجدد بعد ۵ ثانیه
      await Future.delayed(const Duration(seconds: 5));
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

    _ws?.add(
      jsonEncode({
        "tsSubCmds": [],
        "historyCmds": [],
        "attrSubCmds": attrSubCmds,
      }),
    );
  }

  void _onMessage(dynamic message) {
    if (message is! String) return;

    try {
      final parsed = jsonDecode(message);
      print(parsed);
      if (parsed is Map && parsed['errorCode'] == 0) {
        final subscriptionId = parsed['subscriptionId'] as int;
        final deviceId = _subscriptionToDeviceMap[subscriptionId] ?? 'unknown';

        subscriptionData[subscriptionId] = {
          ...?subscriptionData[subscriptionId],
          ...parsed,
        };

        final data = parsed['data'] as Map<String, dynamic>?;

        if (data != null) {
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

          int? timestamp;
          if (data.containsKey('lastActivityTime')) {
            final lastActivityList = data['lastActivityTime'];
            if (lastActivityList is List && lastActivityList.isNotEmpty) {
              final lastEntry = lastActivityList.last;
              timestamp = lastEntry[0] as int?;
            }
          }

          if (timestamp == null && parsed.containsKey('latestValues')) {
            final latestValues =
                parsed['latestValues'] as Map<String, dynamic>?;
            if (latestValues != null &&
                latestValues['lastActivityTime'] != null) {
              timestamp = latestValues['lastActivityTime'] as int?;
            }
          }

          if (timestamp != null) {
            lastDeviceActivity[deviceId] = DateTime.fromMillisecondsSinceEpoch(
              timestamp,
            );
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
    _ws = null;
  }
}
