import 'dart:convert';

class DeviceItem {
  final String title;
  final String sn;
  final String dashboardTitle;
  final String dashboardId;
  final String dateCreation;
  final String deviceId;
  final String type;
  final bool onlineStatus;
  final String deviceTypeName;
  final String deviceTypeCode;
  final Map<String, dynamic>? ledColor;

  DeviceItem({
    required this.title,
    required this.sn,
    required this.dashboardTitle,
    required this.dashboardId,
    required this.dateCreation,
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
      sn: json['sn'] ?? '',
      dashboardTitle: json['dashboardTitle'] ?? '',
      dashboardId: json['dashboardId'] ?? '',
      dateCreation: json['dateCreation'] ?? '',
      deviceId: json['deviceId'] ?? '',
      type: json['type'] ?? '',
      onlineStatus: json['onlineStatus'] ?? false,
      deviceTypeName: json['deviceTypeName'] ?? '',
      deviceTypeCode: json['deviceTypeCode'] ?? '',
      ledColor: led,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "title": title,
      "sn": sn,
      "dashboardTitle": dashboardTitle,
      "dashboardId": dashboardId,
      "dateCreation": dateCreation,
      "deviceId": deviceId,
      "type": type,
      "onlineStatus": onlineStatus,
      "deviceTypeName": deviceTypeName,
      "deviceTypeCode": deviceTypeCode,
      "ledColor": ledColor,
    };
  }
}
