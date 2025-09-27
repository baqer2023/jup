import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DeviceConfigPage extends StatefulWidget {
  final String sn;
  final String deviceId;

  const DeviceConfigPage({
    super.key,
    required this.sn,
    required this.deviceId,
  });

  @override
  State<DeviceConfigPage> createState() => _DeviceConfigPageState();
}

class _DeviceConfigPageState extends State<DeviceConfigPage> {
  int _step = 0; // 0: Instruction, 1: ConnectionCheck, 2: WiFiForm
  bool _loading = false;
  String? _message;

  final _ssidController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  // -------- Step 1: Instruction Page --------
  Widget _buildInstruction() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "۱- اینترنت سیم‌کارت (Mobile Data) را خاموش کنید.",
          style: TextStyle(fontSize: 18),
        ),
        const SizedBox(height: 12),
        const Text(
          "۲- به وای‌فای دستگاه که در حالت Access Point است وصل شوید.",
          style: TextStyle(fontSize: 18),
        ),
        const Spacer(),
        Center(
          child: ElevatedButton(
            onPressed: () {
              setState(() {
                _step = 1;
              });
              _checkConnection();
            },
            child: const Text("وصل شدم"),
          ),
        ),
      ],
    );
  }

  // -------- Step 2: Connection Check --------
  Future<void> _checkConnection() async {
    setState(() {
      _loading = true;
      _message = null;
    });

    try {
      final response = await http
          .get(Uri.parse("http://192.168.10.1/get-serial"))
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        if (response.body.trim() == widget.deviceId) {
          setState(() {
            _step = 2; // رفتن به فرم Wi-Fi
          });
        } else {
          setState(() {
            _message = "سریال دستگاه مطابقت ندارد!";
          });
        }
      } else {
        setState(() {
          _message = "پاسخ نامعتبر از دستگاه!";
        });
      }
    } catch (e) {
      setState(() {
        _message = "ارتباط برقرار نشد: $e";
      });
    }

    setState(() {
      _loading = false;
    });
  }

  // -------- Step 3: Wi-Fi Form --------
  Widget _buildWiFiForm() {
    return Column(
      children: [
        TextField(
          controller: _ssidController,
          decoration: const InputDecoration(labelText: "SSID وای‌فای"),
        ),
        TextField(
          controller: _passwordController,
          decoration: const InputDecoration(labelText: "Password وای‌فای"),
          obscureText: true,
        ),
        const SizedBox(height: 24),
        _loading
            ? const CircularProgressIndicator()
            : ElevatedButton(
                onPressed: _sendCredentials,
                child: const Text("ثبت"),
              ),
        const SizedBox(height: 16),
        if (_message != null)
          Text(
            _message!,
            style: const TextStyle(fontSize: 16),
          ),
      ],
    );
  }

  Future<void> _sendCredentials() async {
    setState(() {
      _loading = true;
      _message = null;
    });

    final body = {
      "ssid": _ssidController.text,
      "password": _passwordController.text,
      "serial": widget.deviceId,
    };

    try {
      final response = await http.post(
        Uri.parse("http://192.168.10.1/set-credentials"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        setState(() {
          _message = "✅ دستگاه با موفقیت پیکربندی شد.";
        });
      } else {
        setState(() {
          _message = "❌ خطا در پیکربندی: ${response.statusCode}";
        });
      }
    } catch (e) {
      setState(() {
        _message = "❌ خطا در ارتباط: $e";
      });
    }

    setState(() {
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("پیکربندی دستگاه"),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: _step == 0
            ? _buildInstruction()
            : _step == 1
                ? Center(
                    child: _loading
                        ? const CircularProgressIndicator()
                        : _message != null
                            ? Text(_message!)
                            : const Text(
                                "در حال بررسی اتصال به دستگاه...",
                                style: TextStyle(fontSize: 16),
                              ),
                  )
                : _buildWiFiForm(),
      ),
    );
  }
}
