import 'dart:convert';

DefaultProfileInfoResponseModel defaultProfileInfoResponseModelFromJson(
        Map<String, dynamic> json) =>
    DefaultProfileInfoResponseModel.fromJson(json);

String defaultProfileInfoResponseModelToJson(
        DefaultProfileInfoResponseModel data) =>
    json.encode(data.toJson());

class DefaultProfileInfoResponseModel {
  DefaultProfileInfoResponseModel({
    this.message,
    this.statusCode,
    this.data,
  });

  factory DefaultProfileInfoResponseModel.fromJson(Map<String, dynamic> json) =>
      DefaultProfileInfoResponseModel(
        data: json["data"] == null ? null : Data.fromJson(json["data"]),
      );
  String? message;
  int? statusCode;
  Data? data;

  Map<String, dynamic> toJson() => {"data": data?.toJson()};
}

class Data {
  DeviceProfileId? id;
  DeviceProfileId? tenantId;
  String? name;
  String? image;
  DeviceProfileId? defaultDashboardId;
  String? type;
  String? transportType;

  Data({
    this.id,
    this.tenantId,
    this.name,
    this.image,
    this.defaultDashboardId,
    this.type,
    this.transportType,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        id: json["id"] == null ? null : DeviceProfileId.fromJson(json["id"]),
        tenantId: json["tenantId"] == null
            ? null
            : DeviceProfileId.fromJson(json["tenantId"]),
        name: json["name"],
        image: json["image"],
        defaultDashboardId: json["defaultDashboardId"] == null
            ? null
            : DeviceProfileId.fromJson(json["defaultDashboardId"]),
        type: json["type"],
        transportType: json["transportType"],
      );

  Map<String, dynamic> toJson() => {
        "id": id?.toJson(),
        "tenantId": tenantId?.toJson(),
        "name": name,
        "image": image,
        "defaultDashboardId": defaultDashboardId?.toJson(),
        "type": type,
        "transportType": transportType,
      };
}

class DeviceProfileId {
  String? id;
  String? entityType;

  DeviceProfileId({
    this.id,
    this.entityType,
  });

  factory DeviceProfileId.fromJson(Map<String, dynamic> json) =>
      DeviceProfileId(
        id: json["id"],
        entityType: json["entityType"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "entityType": entityType,
      };
}
