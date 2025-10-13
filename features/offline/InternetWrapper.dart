import 'dart:async';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_svg/flutter_svg.dart';

class InternetWrapper extends StatefulWidget {
  final Widget child;
  final GlobalKey<NavigatorState> navigatorKey;
  const InternetWrapper({super.key, required this.child, required this.navigatorKey});

  @override
  State<InternetWrapper> createState() => _InternetWrapperState();
}

class _InternetWrapperState extends State<InternetWrapper> {
  late StreamSubscription<List<ConnectivityResult>> _subscription;
  bool _isOnline = true;

  @override
  void initState() {
    super.initState();
    _checkInitial();

    _subscription = Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> results) {
      final connected = results.any((r) => r != ConnectivityResult.none);

      if (connected != _isOnline) {
        _isOnline = connected;

        // اینترنت قطع شد → نمایش Dialog
        if (!connected) {
          _showNoInternetDialog();
        }
      }
    });
  }

  Future<void> _checkInitial() async {
    final results = await Connectivity().checkConnectivity();
    final connected = results is List<ConnectivityResult>
        ? results.any((r) => r != ConnectivityResult.none)
        : results != ConnectivityResult.none;

    _isOnline = connected;

    if (!connected) {
      _showNoInternetDialog();
    }
  }

void _showNoInternetDialog() {
  final context = widget.navigatorKey.currentState?.overlay?.context;
  if (context == null) return;

  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (context) => Dialog(
      backgroundColor: Colors.white, // ✅ بک‌گراند سفید
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset(
                'assets/svg/no internet.svg',
                width: 150,
                height: 150,
              ),
              const SizedBox(height: 20),
              const Text(
                'مشکل در اتصال اینترنت',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87, // ✅ متن مشکی
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'به نظر می‌رسد که اتصال اینترنت شما قطع شده‌است. لطفا وضعیت شبکه خود را بررسی کنید.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black87, // ✅ متن مشکی
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue, // ✅ دکمه آبی
                  foregroundColor: Colors.white, // ✅ متن دکمه سفید
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: const Text('باشه'),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}


  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
