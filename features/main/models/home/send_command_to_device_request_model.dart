import 'dart:convert';

SendCommandToDeviceRequestModel sendCommandToDeviceRequestModelFromJson(
        String str) =>
    SendCommandToDeviceRequestModel.fromJson(json.decode(str));

String sendCommandToDeviceRequestModelToJson(
        SendCommandToDeviceRequestModel data) =>
    json.encode(data.toJson());

class SendCommandToDeviceRequestModel {
  SendCommandToDeviceRequestModel({
    required this.deviceId,
    required this.scope,
    required this.data,
  });

  factory SendCommandToDeviceRequestModel.fromJson(Map<String, dynamic> json) =>
      SendCommandToDeviceRequestModel(
        deviceId: json["deviceId"],
        scope: json["scope"],
        data: json["data"],
      );
  String? deviceId;
  String? scope;
  Map<String, dynamic>? data;

  Map<String, dynamic> toJson() => {
        "pageSize": deviceId,
        "page": scope,
        "data": data,
      };
}
