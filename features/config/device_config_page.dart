import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:my_app32/features/main/pages/home/home_page.dart';
import 'dart:convert';

import 'package:my_app32/features/widgets/custom_appbar.dart';
import 'package:my_app32/features/widgets/sidebar.dart';
import 'package:my_app32/core/lang/lang.dart';

class DeviceConfigPage extends StatefulWidget {
  final String sn;

  const DeviceConfigPage({super.key, required this.sn});

  @override
  State<DeviceConfigPage> createState() => _DeviceConfigPageState();
}

class _DeviceConfigPageState extends State<DeviceConfigPage> {
  int _step = 0;
  bool _loading = false;
  String? _message;
  bool _showOverlay = false;
  String? _currentOverlaySVG;

  final _ssidController = TextEditingController();
  final _passwordController = TextEditingController();

  final String _svgInstruction = 'assets/svg/Steper1.svg';
  final String _svgWiFiForm = 'assets/svg/Steper2.svg';
  final String _svgSuccess = 'assets/svg/Steper3.svg';
  final String _svgStep1 = 'assets/svg/config1.svg';
  final String _svgStep2 = 'assets/svg/config2.svg';
  final String _svgStep3 = 'assets/svg/config3.svg';

  bool _serialMatched = false;

  Widget _blueButton({required String text, required VoidCallback onPressed}) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Text(text, style: const TextStyle(fontSize: 16)),
    );
  }

  @override
  void initState() {
    super.initState();
    _checkDeviceSerial();
  }

  Future<void> _checkDeviceSerial() async {
    setState(() {
      _loading = true;
      _message = null;
    });

    try {
      final response = await http
          .get(Uri.parse("http://192.168.4.1/get-serial"))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final deviceSerial = response.body.trim();
        print("Serial دستگاه: $deviceSerial");
        print("Serial ورودی: ${widget.sn}");

        final swPart = widget.sn.substring(widget.sn.length - deviceSerial.length);

        if (deviceSerial == swPart) {
          setState(() {
            _serialMatched = true;
            _step = 1;
            _message = "✅ ${Lang.t('serial_matched')}"; // 🔹 چندزبانه
          });
        } else {
          setState(() {
            _serialMatched = false;
            _message = "❌ ${Lang.t('serial_not_matched')}"; // 🔹 چندزبانه
          });
        }
      } else {
        setState(() {
          _serialMatched = false;
          _message = "❌ ${Lang.t('invalid_device_response')}"; // 🔹 چندزبانه
        });
      }
    } catch (e) {
      print("خطا در دریافت سریال: $e");
      setState(() {
        _serialMatched = false;
        _message = "❌ ${Lang.t('connection_failed')}"; // 🔹 چندزبانه
      });
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(isRefreshing: false.obs),
      endDrawer: const Sidebar(),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: _step == 0
            ? _buildInstruction()
            : _step == 1
                ? _buildConnectionCheck()
                : _buildWiFiForm(),
      ),
    );
  }

  Widget _buildInstruction() {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SvgPicture.asset(_svgInstruction, height: 100, alignment: Alignment.centerRight),
          const SizedBox(height: 16),
          Text(
            Lang.t('guide'), // 🔹 چندزبانه
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            textAlign: TextAlign.right,
          ),
          const SizedBox(height: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(Lang.t('config_step_1'), style: const TextStyle(fontSize: 18)), // 🔹 چندزبانه
              const SizedBox(height: 12),
              Text(Lang.t('config_step_2'), style: const TextStyle(fontSize: 18)), // 🔹 چندزبانه
              const SizedBox(height: 12),
              Text(Lang.t('config_step_3'), style: const TextStyle(fontSize: 18)), // 🔹 چندزبانه
              const SizedBox(height: 12),
              Text(Lang.t('config_step_4'), style: const TextStyle(fontSize: 18)), // 🔹 چندزبانه
            ],
          ),
          const Spacer(),
          Center(
            child: Column(
              children: [
                _blueButton(
                  text: Lang.t('retry_serial_check'), // 🔹 چندزبانه
                  onPressed: _checkDeviceSerial,
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: _serialMatched ? () => setState(() => _step = 1) : null,
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.resolveWith<Color>((states) {
                      if (states.contains(MaterialState.disabled)) {
                        return Colors.grey.shade300;
                      }
                      return Colors.blue;
                    }),
                    foregroundColor: MaterialStateProperty.resolveWith<Color>((states) {
                      if (states.contains(MaterialState.disabled)) {
                        return Colors.black;
                      }
                      return Colors.white;
                    }),
                    padding: MaterialStateProperty.all(
                        const EdgeInsets.symmetric(horizontal: 24, vertical: 14)),
                    shape: MaterialStateProperty.all(
                        RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                  ),
                  child: Text(
                    Lang.t('connection_established_continue'), // 🔹 چندزبانه
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
          if (_message != null)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Text(_message!, style: const TextStyle(fontSize: 16, color: Colors.red), textAlign: TextAlign.center),
            ),
        ],
      ),
    );
  }

  Widget _buildConnectionCheck() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SvgPicture.asset(_svgWiFiForm, height: 100),
        const SizedBox(height: 16),
        _loading
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 12),
                  Text(Lang.t('checking_device_connection'), style: const TextStyle(fontSize: 16)), // 🔹 چندزبانه
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_message != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Text(_message!, style: const TextStyle(fontSize: 16, color: Colors.red), textAlign: TextAlign.center),
                    ),
                  _blueButton(
                    text: Lang.t('retry'), // 🔹 چندزبانه
                    onPressed: _checkDeviceSerial,
                  ),
                  const SizedBox(height: 12),
                  _blueButton(
                    text: Lang.t('continue_to_wifi_setup'), // 🔹 چندزبانه
                    onPressed: () => setState(() => _step = 2),
                  ),
                ],
              ),
      ],
    );
  }

  Widget _buildWiFiForm() {
    if (_step == 3) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(_svgSuccess, height: 150),
            const SizedBox(height: 20),
            SvgPicture.asset('assets/svg/SuccessfulConfig.svg', height: 120),
            const SizedBox(height: 12),
            SvgPicture.asset('assets/svg/SuccessfulConfigmsg.svg', height: 80),
            const SizedBox(height: 24),
            if (_message != null)
              Text(_message!, textAlign: TextAlign.center, style: TextStyle(fontSize: 16, color: _message!.contains("✅") ? Colors.green : Colors.red)),
            const SizedBox(height: 30),
            _blueButton(
              text: Lang.t('start_using_app'), // 🔹 چندزبانه
              onPressed: () {
                Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) =>  HomePage()));
              },
            ),
          ],
        ),
      );
    }

    return Stack(
      children: [
        Column(
          children: [
            SvgPicture.asset(_svgWiFiForm, height: 120),
            const SizedBox(height: 16),
            TextField(
              controller: _ssidController,
              decoration: InputDecoration(labelText: Lang.t('wifi_ssid')), // 🔹 چندزبانه
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: Lang.t('wifi_password')), // 🔹 چندزبانه
              obscureText: true,
            ),
            const SizedBox(height: 24),
            _loading
                ? const SizedBox(height: 150, child: Center(child: CircularProgressIndicator()))
                : _blueButton(text: Lang.t('save_and_connect'), onPressed: _onSubmitWiFiForm), // 🔹 چندزبانه
            const SizedBox(height: 16),
            if (_message != null)
              Column(
                children: [
                  SvgPicture.asset(_svgSuccess, height: 80),
                  const SizedBox(height: 12),
                  Text(_message!, style: TextStyle(fontSize: 16, color: _message!.contains("✅") ? Colors.green : Colors.red), textAlign: TextAlign.center),
                ],
              ),
          ],
        ),
        if (_showOverlay && _currentOverlaySVG != null)
          Container(
            color: Colors.white,
            alignment: Alignment.center,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SvgPicture.asset(_svgWiFiForm, height: 80),
                const SizedBox(height: 16),
                SvgPicture.asset(_currentOverlaySVG!, height: 150),
              ],
            ),
          ),
      ],
    );
  }

  bool _validateFormInputs() {
    final ssid = _ssidController.text.trim();
    final pass = _passwordController.text.trim();
    if (ssid.isEmpty) {
      setState(() => _message = "❌ ${Lang.t('enter_ssid')}"); // 🔹 چندزبانه
      return false;
    }
    if (pass.length < 8) {
      setState(() => _message = "❌ ${Lang.t('password_min_8_chars')}"); // 🔹 چندزبانه
      return false;
    }
    setState(() => _message = null);
    return true;
  }

  Future<void> _onSubmitWiFiForm() async {
    if (!_validateFormInputs()) return;

    setState(() => _showOverlay = true);

    final List<String> svgSteps = [_svgStep1, _svgStep2, _svgStep3];
    for (String svgPath in svgSteps) {
      setState(() => _currentOverlaySVG = svgPath);
      await Future.delayed(const Duration(seconds: 2));
    }

    setState(() {
      _showOverlay = false;
      _currentOverlaySVG = null;
      _step = 3;
      _message = "✅ ${Lang.t('credentials_sent')}"; // 🔹 چندزبانه
    });

    await _sendCredentials(_ssidController.text.trim(), _passwordController.text.trim());
  }

  Future<void> _sendCredentials(String ssid, String password) async {
    setState(() => _loading = true);
    final body = {"ssid": ssid, "password": password, "serial": widget.sn};

    try {
      final response = await http.post(
        Uri.parse("http://192.168.4.1/set-credentials"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        setState(() => _message = "❌ ${Lang.t('send_failed')} (${Lang.t('code')}: ${response.statusCode})"); // 🔹 چندزبانه
      }
    } catch (_) {
      // ignore
    } finally {
      setState(() => _loading = false);
    }
  }
}