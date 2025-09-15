class DeviceModel {
  final String title;
  final String deviceId;
  final String type;
  final bool onlineStatus;
  final String deviceTypeName;
  final String deviceTypeCode;
  final Map<String, dynamic> ledColor; // ✅ اضافه شد

  DeviceModel({
    required this.title,
    required this.deviceId,
    required this.type,
    required this.onlineStatus,
    required this.deviceTypeName,
    required this.deviceTypeCode,
    required this.ledColor,
  });

  factory DeviceModel.fromJson(Map<String, dynamic> json) {
    return DeviceModel(
      title: json['title'],
      deviceId: json['deviceId'],
      type: json['type'],
      onlineStatus: json['onlineStatus'],
      deviceTypeName: json['deviceTypeName'],
      deviceTypeCode: json['deviceTypeCode'],
      ledColor: json['ledColor'] ?? {}, // 🔹 مطمئن می‌شویم خالی نباشد
    );
  }

  static List<DeviceModel> listFromJson(List data) {
    return data.map((e) => DeviceModel.fromJson(e)).toList();
  }
}
