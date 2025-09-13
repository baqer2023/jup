import 'dart:convert';

CredentialResponseModel credentialResponseModelFromJson(Map<String, dynamic> json) => CredentialResponseModel.fromJson(json);

String credentialResponseModelToJson(CredentialResponseModel data) => json.encode(data.toJson());

class CredentialResponseModel {
  CredentialResponseModel({
    this.message,
    this.statusCode,
    this.status,
    this.error,
  });

  factory CredentialResponseModel.fromJson(Map<String, dynamic> json) => CredentialResponseModel(
        status: json["status"],
        error: json['error'],
      );
  String? message;
  int? statusCode;
  String? status;
  String? error;

  Map<String, dynamic> toJson() => {
        "status": status ?? '',
        'error': error ?? '',
      };
}
