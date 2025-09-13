import 'dart:convert';

GetCurrentUserResponseModel getCurrentUserResponseModelFromJson(
        Map<String, dynamic> json) =>
    GetCurrentUserResponseModel.fromJson(json);

String getCurrentUserResponseModelToJson(GetCurrentUserResponseModel data) =>
    json.encode(data.toJson());

class GetCurrentUserResponseModel {
  GetCurrentUserResponseModel({
    this.message,
    this.statusCode,
    this.data,
  });

  factory GetCurrentUserResponseModel.fromJson(Map<String, dynamic> json) =>
      GetCurrentUserResponseModel(
        data: json["data"] == null ? null : Data.fromJson(json["data"]),
      );
  String? message;
  int? statusCode;
  Data? data;

  Map<String, dynamic> toJson() => {"data": data?.toJson()};
}

class Data {
  Data({
    this.id,
    this.createdTime,
    this.tenantId,
    this.customerId,
    this.email,
    this.authority,
    this.firstName,
    this.lastName,
    this.phone,
    this.name,
    this.additionalInfo,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        id: json["id"] == null ? null : CustomerId.fromJson(json["id"]),
        createdTime: json["createdTime"],
        tenantId: json["tenantId"] == null
            ? null
            : CustomerId.fromJson(json["tenantId"]),
        customerId: json["customerId"] == null
            ? null
            : CustomerId.fromJson(json["customerId"]),
        email: json["email"],
        authority: json["authority"],
        firstName: json["firstName"],
        lastName: json["lastName"],
        phone: json["phone"],
        name: json["name"],
        additionalInfo: json["additionalInfo"] == null
            ? null
            : AdditionalInfo.fromJson(json["additionalInfo"]),
      );

  CustomerId? id;
  int? createdTime;
  CustomerId? tenantId;
  CustomerId? customerId;
  String? email;
  String? authority;
  dynamic firstName;
  dynamic lastName;
  dynamic phone;
  String? name;
  AdditionalInfo? additionalInfo;

  Map<String, dynamic> toJson() => {
        "id": id?.toJson(),
        "createdTime": createdTime,
        "tenantId": tenantId?.toJson(),
        "customerId": customerId?.toJson(),
        "email": email,
        "authority": authority,
        "firstName": firstName,
        "lastName": lastName,
        "phone": phone,
        "name": name,
        "additionalInfo": additionalInfo?.toJson(),
      };
}

class AdditionalInfo {
  AdditionalInfo({
    this.failedLoginAttempts,
    this.lastLoginTs,
    this.userCredentialsEnabled,
  });

  factory AdditionalInfo.fromJson(Map<String, dynamic> json) => AdditionalInfo(
        failedLoginAttempts: json["failedLoginAttempts"],
        lastLoginTs: json["lastLoginTs"],
        userCredentialsEnabled: json["userCredentialsEnabled"],
      );

  int? failedLoginAttempts;
  int? lastLoginTs;
  bool? userCredentialsEnabled;

  Map<String, dynamic> toJson() => {
        "failedLoginAttempts": failedLoginAttempts,
        "lastLoginTs": lastLoginTs,
        "userCredentialsEnabled": userCredentialsEnabled,
      };
}

class CustomerId {
  CustomerId({
    this.entityType,
    this.id,
  });

  factory CustomerId.fromJson(Map<String, dynamic> json) => CustomerId(
        entityType: json["entityType"],
        id: json["id"],
      );

  String? entityType;
  String? id;

  Map<String, dynamic> toJson() => {
        "entityType": entityType,
        "id": id,
      };
}
