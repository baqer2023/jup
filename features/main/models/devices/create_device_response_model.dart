import 'dart:convert';

CreateDeviceResponseModel createDeviceResponseModelFromJson(
        Map<String, dynamic> json) =>
    CreateDeviceResponseModel.fromJson(json);

String createDeviceResponseModelToJson(CreateDeviceResponseModel data) =>
    json.encode(data.toJson());

class CreateDeviceResponseModel {
  CreateDeviceResponseModel({
    this.message,
    this.statusCode,
    this.data,
  });

  factory CreateDeviceResponseModel.fromJson(Map<String, dynamic> json) =>
      CreateDeviceResponseModel(
        data: json["data"] == null ? null : Data.fromJson(json["data"]),
      );
  String? message;
  int? statusCode;
  Data? data;

  Map<String, dynamic> toJson() => {"data": data?.toJson()};
}

class Data {
  DeviceProfileId? id;
  String? name;
  String? type;
  String? label;
  DeviceProfileId? deviceProfileId;
  DeviceProfileId? firmwareId;
  DeviceProfileId? softwareId;
  AdditionalInfo? additionalInfo;
  DeviceData? deviceData;

  Data({
    this.id,
    this.name,
    this.type,
    this.label,
    this.deviceProfileId,
    this.firmwareId,
    this.softwareId,
    this.additionalInfo,
    this.deviceData,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        id: json["id"] == null ? null : DeviceProfileId.fromJson(json["id"]),
        name: json["name"],
        type: json["type"],
        label: json["label"],
        deviceProfileId: json["deviceProfileId"] == null
            ? null
            : DeviceProfileId.fromJson(json["deviceProfileId"]),
        firmwareId: json["firmwareId"] == null
            ? null
            : DeviceProfileId.fromJson(json["firmwareId"]),
        softwareId: json["softwareId"] == null
            ? null
            : DeviceProfileId.fromJson(json["softwareId"]),
        additionalInfo: json["additionalInfo"] == null
            ? null
            : AdditionalInfo.fromJson(json["additionalInfo"]),
        deviceData: json["deviceData"] == null
            ? null
            : DeviceData.fromJson(json["deviceData"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id?.toJson(),
        "name": name,
        "type": type,
        "label": label,
        "deviceProfileId": deviceProfileId?.toJson(),
        "firmwareId": firmwareId?.toJson(),
        "softwareId": softwareId?.toJson(),
        "additionalInfo": additionalInfo?.toJson(),
        "deviceData": deviceData?.toJson(),
      };
}

class AdditionalInfo {
  AdditionalInfo();

  factory AdditionalInfo.fromJson(Map<String, dynamic> json) =>
      AdditionalInfo();

  Map<String, dynamic> toJson() => {};
}

class DeviceData {
  Configuration? configuration;
  TransportConfiguration? transportConfiguration;

  DeviceData({
    this.configuration,
    this.transportConfiguration,
  });

  factory DeviceData.fromJson(Map<String, dynamic> json) => DeviceData(
        configuration: json["configuration"] == null
            ? null
            : Configuration.fromJson(json["configuration"]),
        transportConfiguration: json["transportConfiguration"] == null
            ? null
            : TransportConfiguration.fromJson(json["transportConfiguration"]),
      );

  Map<String, dynamic> toJson() => {
        "configuration": configuration?.toJson(),
        "transportConfiguration": transportConfiguration?.toJson(),
      };
}

class Configuration {
  String? type;

  Configuration({
    this.type,
  });

  factory Configuration.fromJson(Map<String, dynamic> json) => Configuration(
        type: json["type"],
      );

  Map<String, dynamic> toJson() => {
        "type": type,
      };
}

class TransportConfiguration {
  String? type;
  String? powerMode;
  int? psmActivityTimer;
  int? edrxCycle;
  int? pagingTransmissionWindow;

  TransportConfiguration({
    this.type,
    this.powerMode,
    this.psmActivityTimer,
    this.edrxCycle,
    this.pagingTransmissionWindow,
  });

  factory TransportConfiguration.fromJson(Map<String, dynamic> json) =>
      TransportConfiguration(
        type: json["type"],
        powerMode: json["powerMode"],
        psmActivityTimer: json["psmActivityTimer"],
        edrxCycle: json["edrxCycle"],
        pagingTransmissionWindow: json["pagingTransmissionWindow"],
      );

  Map<String, dynamic> toJson() => {
        "type": type,
        "powerMode": powerMode,
        "psmActivityTimer": psmActivityTimer,
        "edrxCycle": edrxCycle,
        "pagingTransmissionWindow": pagingTransmissionWindow,
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
