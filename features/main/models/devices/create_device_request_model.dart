import 'dart:convert';

CreateDeviceRequestModel createDeviceRequestModelFromJson(String str) =>
    CreateDeviceRequestModel.fromJson(json.decode(str));

String createDeviceRequestModelToJson(CreateDeviceRequestModel data) =>
    json.encode(data.toJson());

class CreateDeviceRequestModel {
  CreateDeviceRequestModel({
    this.name,
    this.deviceProfileId,
  });

  factory CreateDeviceRequestModel.fromJson(Map<String, dynamic> json) =>
      CreateDeviceRequestModel(
        name: json["name"],
        deviceProfileId: json["deviceProfileId"] == null
            ? null
            : NewDeviceProfileId.fromJson(json["deviceProfileId"]),
      );

  String? name;
  NewDeviceProfileId? deviceProfileId;

  Map<String, dynamic> toJson() => {
        "name": name,
        "deviceProfileId": deviceProfileId?.toJson(),
      };
}

class NewDeviceProfileId {
  NewDeviceProfileId({
    this.id,
    this.entityType,
  });

  factory NewDeviceProfileId.fromJson(Map<String, dynamic> json) =>
      NewDeviceProfileId(
        id: json["id"],
        entityType: json["entityType"],
      );

  String? id;
  String? entityType;

  Map<String, dynamic> toJson() => {
        "id": id,
        "entityType": entityType,
      };
}
