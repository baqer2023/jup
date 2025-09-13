import 'dart:convert';

GetDashboardsRequestModel getDashboardsRequestModelFromJson(String str) =>
    GetDashboardsRequestModel.fromJson(json.decode(str));

String getDashboardsRequestModelToJson(GetDashboardsRequestModel data) =>
    json.encode(data.toJson());

class GetDashboardsRequestModel {
  GetDashboardsRequestModel(
      {required this.pageSize,
      required this.page,
      this.mobile,
      required this.sortProperty,
      required this.sortOrder});

  factory GetDashboardsRequestModel.fromJson(Map<String, dynamic> json) =>
      GetDashboardsRequestModel(
        pageSize: json["pageSize"],
        page: json["password"],
        mobile: json["mobile"],
        sortProperty: json["sortProperty"],
        sortOrder: json["sortOrder"],
      );
  int? pageSize;
  int? page;
  String? mobile = 'true';
  String? sortProperty;
  String? sortOrder;

  Map<String, dynamic> toJson() => {
        "pageSize": pageSize,
        "page": page,
        "mobile": mobile,
        "sortProperty": sortProperty,
        "sortOrder": sortOrder,
      };
}
