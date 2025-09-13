class RegisterDeviceRequestModel {
  final String serialNumber;
  final String label;

  RegisterDeviceRequestModel({
    required this.serialNumber,
    required this.label,
  });

  Map<String, dynamic> toJson() {
    return {
      'serialNumber': serialNumber,
      'label': label,
    };
  }
} 