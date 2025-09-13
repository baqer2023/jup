import 'dart:convert';

OtpResponseModel otpResponseModelFromJson(Map<String, dynamic> json) => OtpResponseModel.fromJson(json);

String otpResponseModelToJson(OtpResponseModel data) => json.encode(data.toJson());

class OtpResponseModel {
  OtpResponseModel({
    this.message,
    this.statusCode,
    this.data,
  });

  factory OtpResponseModel.fromJson(Map<String, dynamic> json) => OtpResponseModel(
        data: json["data"] == null ? null : Data.fromJson(json["data"]),
      );
  String? message;
  int? statusCode;
  Data? data;

  Map<String, dynamic> toJson() => {"data": data?.toJson()};
}

class Data {
  Data({
    this.token,
    this.refreshToken,
    this.scope,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        token: json["token"],
        refreshToken: json["refreshToken"],
        scope: json["scope"],
      );
  String? token;
  String? refreshToken;
  dynamic scope;

  Map<String, dynamic> toJson() => {
        "token": token,
        "refreshToken": refreshToken,
        "scope": scope,
      };
}
