import 'dart:convert';

class DeviceItem {
  final String title;
  final String deviceId;
  final String type;
  final bool onlineStatus;
  final String deviceTypeName; // این خط باید باشه
  final String deviceTypeCode;
  final Map<String, dynamic>? ledColor; // ← تغییر داده شد

  DeviceItem({
    required this.title,
    required this.deviceId,
    required this.type,
    required this.onlineStatus,
    required this.deviceTypeName,
    required this.deviceTypeCode,
    this.ledColor,
  });

  factory DeviceItem.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic>? led;

    if (json['ledColor'] != null) {
      if (json['ledColor'] is String) {
        try {
          led = jsonDecode(json['ledColor']);
        } catch (_) {
          led = null;
        }
      } else if (json['ledColor'] is Map<String, dynamic>) {
        led = json['ledColor'];
      }
    }

    return DeviceItem(
      title: json['title'] ?? '',
      deviceId: json['deviceId'] ?? '',
      type: json['type'] ?? '',
      onlineStatus: json['onlineStatus'] ?? false,
      deviceTypeName: json['deviceTypeName'] ?? '',
      deviceTypeCode: json['deviceTypeCode'] ?? '',
      ledColor: led,
    );
  }
}
