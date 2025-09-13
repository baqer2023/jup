import 'dart:convert';

SendCommandToDeviceResponseModel sendCommandToDeviceResponseModelFromJson(
        String json) =>
    SendCommandToDeviceResponseModel.fromJson(json);

String sendCommandToDeviceResponseModelToJson(
        SendCommandToDeviceResponseModel data) =>
    json.encode(data.toJson());

class SendCommandToDeviceResponseModel {
  SendCommandToDeviceResponseModel({
    this.message,
    this.statusCode,
    this.data,
  });

  factory SendCommandToDeviceResponseModel.fromJson(String json) =>
      SendCommandToDeviceResponseModel(
        data: Data.fromJson({'data': json}),
      );
  String? message;
  int? statusCode;
  Data? data;

  Map<String, dynamic> toJson() => {"data": data?.toJson()};
}

class Data {
  Data();

  factory Data.fromJson(Map<String, dynamic> json) => Data();

  Map<String, dynamic> toJson() => {};
}
