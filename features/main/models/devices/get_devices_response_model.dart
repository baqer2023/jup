import 'dart:convert';

GetDevicesResponseModel getDevicesResponseModelFromJson(
        Map<String, dynamic> json) =>
    GetDevicesResponseModel.fromJson(json);

String getDevicesResponseModelToJson(GetDevicesResponseModel data) =>
    json.encode(data.toJson());

class GetDevicesResponseModel {
  GetDevicesResponseModel({
    this.message,
    this.statusCode,
    this.data,
  });

  factory GetDevicesResponseModel.fromJson(Map<String, dynamic> json) =>
      GetDevicesResponseModel(
        data: json["data"] == null ? null : Data.fromJson(json["data"]),
      );
  String? message;
  int? statusCode;
  Data? data;

  Map<String, dynamic> toJson() => {"data": data?.toJson()};
}

class Data {
  Data({
    this.data,
    this.totalPages,
    this.totalElements,
    this.hasNext,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        data: json["data"] == null
            ? []
            : List<Datum>.from(json["data"]!.map((x) => Datum.fromJson(x))),
        totalPages: json["totalPages"],
        totalElements: json["totalElements"],
        hasNext: json["hasNext"],
      );

  List<Datum>? data;
  int? totalPages;
  int? totalElements;
  bool? hasNext;

  Map<String, dynamic> toJson() => {
        "data": data == null
            ? []
            : List<dynamic>.from(data!.map((x) => x.toJson())),
        "totalPages": totalPages,
        "totalElements": totalElements,
        "hasNext": hasNext,
      };
}

class Datum {
  Datum({
    this.id,
    this.createdTime,
    this.tenantId,
    this.customerId,
    this.name,
    this.type,
    this.label,
    this.deviceProfileId,
    this.firmwareId,
    this.softwareId,
    this.additionalInfo,
    this.deviceData,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        id: json["id"] == null ? null : CustomerId.fromJson(json["id"]),
        createdTime: json["createdTime"],
        tenantId: json["tenantId"] == null
            ? null
            : CustomerId.fromJson(json["tenantId"]),
        customerId: json["customerId"] == null
            ? null
            : CustomerId.fromJson(json["customerId"]),
        name: json["name"],
        type: json["type"],
        label: json["label"],
        deviceProfileId: json["deviceProfileId"] == null
            ? null
            : CustomerId.fromJson(json["deviceProfileId"]),
        firmwareId: json["firmwareId"] == null
            ? null
            : CustomerId.fromJson(json["firmwareId"]),
        softwareId: json["softwareId"] == null
            ? null
            : CustomerId.fromJson(json["softwareId"]),
        additionalInfo: json["additionalInfo"] == null
            ? null
            : AdditionalInfo.fromJson(json["additionalInfo"]),
        deviceData: json["deviceData"] == null
            ? null
            : DeviceData.fromJson(json["deviceData"]),
      );

  CustomerId? id;
  int? createdTime;
  CustomerId? tenantId;
  CustomerId? customerId;
  String? name;
  String? type;
  String? label;
  CustomerId? deviceProfileId;
  CustomerId? firmwareId;
  CustomerId? softwareId;
  AdditionalInfo? additionalInfo;
  DeviceData? deviceData;

  Map<String, dynamic> toJson() => {
        "id": id?.toJson(),
        "createdTime": createdTime,
        "tenantId": tenantId?.toJson(),
        "customerId": customerId?.toJson(),
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

class CustomerId {
  CustomerId({
    this.id,
    this.entityType,
  });

  factory CustomerId.fromJson(Map<String, dynamic> json) => CustomerId(
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

class DeviceData {
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

  Configuration? configuration;
  TransportConfiguration? transportConfiguration;

  Map<String, dynamic> toJson() => {
        "configuration": configuration?.toJson(),
        "transportConfiguration": transportConfiguration?.toJson(),
      };
}

class Configuration {
  Configuration({
    this.type,
  });

  factory Configuration.fromJson(Map<String, dynamic> json) => Configuration(
        type: json["type"],
      );

  String? type;

  Map<String, dynamic> toJson() => {
        "type": type,
      };
}

class TransportConfiguration {
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

  String? type;
  String? powerMode;
  int? psmActivityTimer;
  int? edrxCycle;
  int? pagingTransmissionWindow;

  Map<String, dynamic> toJson() => {
        "type": type,
        "powerMode": powerMode,
        "psmActivityTimer": psmActivityTimer,
        "edrxCycle": edrxCycle,
        "pagingTransmissionWindow": pagingTransmissionWindow,
      };
}
