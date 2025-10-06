import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:my_app32/features/main/pages/home/home_page.dart';
import 'dart:convert';

import 'package:my_app32/features/widgets/custom_appbar.dart';
import 'package:my_app32/features/widgets/sidebar.dart';

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

  // تابع ساخت دکمه آبی با متن سفید
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

  // بررسی سریال دستگاه و مقایسه با آخرین ارقام سریال نرم‌افزاری
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
            _step = 1; // مرحله بعدی فعال
            _message = "✅ سریال دستگاه مطابقت دارد.";
          });
        } else {
          setState(() {
            _serialMatched = false;
            _message = "❌ سریال دستگاه مطابقت ندارد!";
          });
        }
      } else {
        setState(() {
          _serialMatched = false;
          _message = "❌ پاسخ نامعتبر از دستگاه!";
        });
      }
    } catch (e) {
      print("خطا در دریافت سریال: $e");
      setState(() {
        _serialMatched = false;
        _message = "❌ ارتباط برقرار نشد.";
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
          const Text(
            "راهنما:",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            textAlign: TextAlign.right,
          ),
          const SizedBox(height: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text("۱- اینترنت سیم‌کارت دستگاه خود را (در صورت روشن بودن) خاموش کنید.", style: TextStyle(fontSize: 18)),
              SizedBox(height: 12),
              Text("۲- از برنامه خارج شده و به تنظیمات Wi-Fi گوشی خود بروید.", style: TextStyle(fontSize: 18)),
              SizedBox(height: 12),
              Text("۳- در لیست شبکه‌ها، به شبکه [نام شبکه] متصل شوید.", style: TextStyle(fontSize: 18)),
              SizedBox(height: 12),
              Text("۴- پس از اتصال، به این برنامه بازگردید.", style: TextStyle(fontSize: 18)),
            ],
          ),
          const Spacer(),
          Center(
            child: Column(
              children: [
                _blueButton(
                  text: "تلاش مجدد برای بررسی سریال",
                  onPressed: _checkDeviceSerial,
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: _serialMatched ? () => setState(() => _step = 1) : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _serialMatched ? Colors.blue : Colors.blue.shade200,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text("اتصال برقرار شد، ادامه دهید", style: TextStyle(fontSize: 16)),
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
                children: const [
                  CircularProgressIndicator(),
                  SizedBox(height: 12),
                  Text("در حال بررسی اتصال به دستگاه...", style: TextStyle(fontSize: 16)),
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
                    text: "تلاش مجدد",
                    onPressed: _checkDeviceSerial,
                  ),
                  const SizedBox(height: 12),
                  _blueButton(
                    text: "ادامه به مرحله تنظیم وای‌فای",
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
              text: "شروع استفاده از برنامه",
              onPressed: () {
                Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const HomePage()));
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
              decoration: const InputDecoration(labelText: "SSID وای‌فای"),
            ),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: "Password وای‌فای"),
              obscureText: true,
            ),
            const SizedBox(height: 24),
            _loading
                ? const SizedBox(height: 150, child: Center(child: CircularProgressIndicator()))
                : _blueButton(text: "ذخیره و اتصال نهایی", onPressed: _onSubmitWiFiForm),
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
      setState(() => _message = "❌ لطفا SSID را وارد کنید.");
      return false;
    }
    if (pass.length < 8) {
      setState(() => _message = "❌ پسورد باید حداقل ۸ کاراکتر باشد.");
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
      _message = "✅ اطلاعات ارسال شد.\nدستگاه در حال اتصال به وای‌فای جدید است.";
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
        setState(() => _message = "❌ ارسال اطلاعات ناموفق (کد: ${response.statusCode})");
      }
    } catch (_) {
      // ignore
    } finally {
      setState(() => _loading = false);
    }
  }
}
