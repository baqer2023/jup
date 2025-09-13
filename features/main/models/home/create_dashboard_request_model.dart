import 'dart:convert';

CreateDashboardRequestModel createDashboardRequestModelFromJson(String str) =>
    CreateDashboardRequestModel.fromJson(json.decode(str));

String createDashboardRequestModelToJson(CreateDashboardRequestModel data) =>
    json.encode(data.toJson());

class CreateDashboardRequestModel {
  CreateDashboardRequestModel({required this.title, this.description});

  factory CreateDashboardRequestModel.fromJson(Map<String, dynamic> json) =>
      CreateDashboardRequestModel(
        title: json["title"],
        description: json["description"],
      );

  String? title;
  String? description;

  Map<String, dynamic> toJson() => {
        "title": title,
        "description": description
      };
}
