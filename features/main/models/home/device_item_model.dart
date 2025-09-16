// مدل دیوایس
class DeviceItem {
  final String deviceId;
  final String title;
  final String type;
  final bool onlineStatus;
  final Map<String, dynamic> ledColor;

  DeviceItem({
    required this.deviceId,
    required this.title,
    required this.type,
    required this.onlineStatus,
    required this.ledColor,
  });

  factory DeviceItem.fromJson(Map<String, dynamic> json) {
    return DeviceItem(
      deviceId: json['deviceId'] ?? '',
      title: json['title'] ?? 'بدون نام',
      type: json['type'] ?? '',
      onlineStatus: json['onlineStatus'] ?? false,
      ledColor: json['ledColor'] ?? {},
    );
  }
}