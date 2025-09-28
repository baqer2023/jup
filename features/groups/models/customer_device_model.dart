class CustomerDevice {
  final String id;
  final String name;
  final String label;
  // final bool active;
  final String deviceProfileName;

  CustomerDevice({
    required this.id,
    required this.name,
    required this.label,
    // required this.active,
    required this.deviceProfileName,
  });

  factory CustomerDevice.fromJson(Map<String, dynamic> json) {
    return CustomerDevice(
      id: json['id']?['id'] ?? "",   // 👈 اینجا
      name: json['name'] ?? "",
      label: json['label'] ?? "",
      // active: json['active'] ?? false,
      deviceProfileName: json['deviceProfileName'] ?? "",
    );
  }
}
