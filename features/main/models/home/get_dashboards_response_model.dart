import 'dart:convert';

DashboardResponseModel dashboardResponseModelFromJson(
        Map<String, dynamic> json) =>
    DashboardResponseModel.fromJson(json);

String dashboardResponseModelToJson(DashboardResponseModel data) =>
    json.encode(data.toJson());

class DashboardResponseModel {
  DashboardResponseModel({
    this.message,
    this.statusCode,
    this.data,
  });

  factory DashboardResponseModel.fromJson(Map<String, dynamic> json) =>
      DashboardResponseModel(
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
            : List<DashboardItemModel>.from(
                json["data"]!.map((x) => DashboardItemModel.fromJson(x))),
        totalPages: json["totalPages"],
        totalElements: json["totalElements"],
        hasNext: json["hasNext"],
      );

  Map<String, dynamic> toJson() => {
        "data": data == null
            ? []
            : List<dynamic>.from(data!.map((x) => x.toJson())),
        "totalPages": totalPages,
        "totalElements": totalElements,
        "hasNext": hasNext,
      };

  List<DashboardItemModel>? data;
  int? totalPages;
  int? totalElements;
  bool? hasNext;
}

class DashboardItemModel {
  DashboardItemModel({
    this.id,
    this.createdTime,
    this.tenantId,
    this.title,
    this.image,
    this.assignedCustomers,
    this.mobileHide,
    this.mobileOrder,
    this.name,
  });

  factory DashboardItemModel.fromJson(Map<String, dynamic> json) =>
      DashboardItemModel(
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
        name: json["name"],
      );

  Id? id;
  int? createdTime;
  Id? tenantId;
  String? title;
  String? image;
  List<AssignedCustomer>? assignedCustomers;
  bool? mobileHide;
  int? mobileOrder;
  String? name;

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
        "name": name,
      };
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

  String? id;
  String? entityType;
}
