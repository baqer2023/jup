import 'dart:convert';

CreateDashboardResponseModel createDashboardResponseModelFromJson(
        Map<String, dynamic> json) =>
    CreateDashboardResponseModel.fromJson(json);

String createDashboardResponseModelToJson(CreateDashboardResponseModel data) =>
    json.encode(data.toJson());

class CreateDashboardResponseModel {
  CreateDashboardResponseModel({
    this.message,
    this.statusCode,
    this.data,
  });

  factory CreateDashboardResponseModel.fromJson(Map<String, dynamic> json) =>
      CreateDashboardResponseModel(
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
    this.title,
    this.image,
    this.assignedCustomers,
    this.mobileHide,
    this.mobileOrder,
    this.configuration,
    this.name,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        id: json["id"] == null ? null : Id.fromJson(json["id"]),
        createdTime: json["createdTime"],
        tenantId:
            json["tenantId"] == null ? null : Id.fromJson(json["tenantId"]),
        title: json["title"],
        image: json["image"],
        assignedCustomers: json["assignedCustomers"] == null
            ? []
            : List<AssignedCustomer>.from(json["assignedCustomers"]!
                .map((x) => AssignedCustomer.fromJson(x))),
        mobileHide: json["mobileHide"],
        mobileOrder: json["mobileOrder"],
        configuration: json["configuration"] == null
            ? null
            : Configuration.fromJson(json["configuration"]),
        name: json["name"],
      );

  Map<String, dynamic> toJson() => {
        "id": id?.toJson(),
        "createdTime": createdTime,
        "tenantId": tenantId?.toJson(),
        "title": title,
        "image": image,
        "assignedCustomers": assignedCustomers == null
            ? []
            : List<dynamic>.from(assignedCustomers!.map((x) => x.toJson())),
        "mobileHide": mobileHide,
        "mobileOrder": mobileOrder,
        "configuration": configuration?.toJson(),
        "name": name,
      };
      
  Id? id;
  int? createdTime;
  Id? tenantId;
  String? title;
  String? image;
  List<AssignedCustomer>? assignedCustomers;
  bool? mobileHide;
  int? mobileOrder;
  Configuration? configuration;
  String? name;

}

class AssignedCustomer {
  AssignedCustomer({
    this.customerId,
    this.title,
    this.public,
  });

  factory AssignedCustomer.fromJson(Map<String, dynamic> json) =>
      AssignedCustomer(
        customerId:
            json["customerId"] == null ? null : Id.fromJson(json["customerId"]),
        title: json["title"],
        public: json["public"],
      );
      
  Id? customerId;
  String? title;
  bool? public;


  Map<String, dynamic> toJson() => {
        "customerId": customerId?.toJson(),
        "title": title,
        "public": public,
      };
}

class Id {
  String? id;
  String? entityType;

  Id({
    this.id,
    this.entityType,
  });

  factory Id.fromJson(Map<String, dynamic> json) => Id(
        id: json["id"],
        entityType: json["entityType"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "entityType": entityType,
      };
}

class Configuration {
  Configuration();

  factory Configuration.fromJson(Map<String, dynamic> json) => Configuration();

  Map<String, dynamic> toJson() => {};
}
