import 'dart:convert';

GetDevicesRequestModel getDevicesRequestModelFromJson(String str) =>
    GetDevicesRequestModel.fromJson(json.decode(str));

String getDevicesRequestModelToJson(GetDevicesRequestModel data) =>
    json.encode(data.toJson());

class GetDevicesRequestModel {
  GetDevicesRequestModel(
      {required this.pageSize,
      required this.page,
      this.type,
      this.textSearch,
      required this.sortProperty,
      required this.sortOrder});

  factory GetDevicesRequestModel.fromJson(Map<String, dynamic> json) =>
      GetDevicesRequestModel(
        pageSize: json["pageSize"],
        page: json["password"],
        type: json["type"],
        textSearch: json["textSearch"],
        sortProperty: json["sortProperty"],
        sortOrder: json["sortOrder"],
      );
  int? pageSize;
  int? page;
  String? type;
  String? textSearch;
  String? sortProperty;
  String? sortOrder;

  Map<String, dynamic> toJson() => {
        "pageSize": pageSize,
        "page": page,
        "textSearch": textSearch,
        "type": type,
        "sortProperty": sortProperty,
        "sortOrder": sortOrder,
      };
}
