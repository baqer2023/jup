class UserLocationsResponseModel {
  final List<LocationItem> data;
  final int totalPages;
  final int totalElements;
  final bool hasNext;

  UserLocationsResponseModel({
    required this.data,
    required this.totalPages,
    required this.totalElements,
    required this.hasNext,
  });

  factory UserLocationsResponseModel.fromJson(Map<String, dynamic> json) {
    return UserLocationsResponseModel(
      data: (json['data'] as List<dynamic>)
          .map((e) => LocationItem.fromJson(e))
          .toList(),
      totalPages: json['totalPages'] ?? 0,
      totalElements: json['totalElements'] ?? 0,
      hasNext: json['hasNext'] ?? false,
    );
  }
}

class LocationItem {
  final String id;
  final String title;
  final int? iconIndex; // ✅ اضافه شد

  LocationItem({
    required this.id,
    required this.title,
    this.iconIndex,
  });

  factory LocationItem.fromJson(Map<String, dynamic> json) {
    return LocationItem(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      iconIndex: json['iconIndex'] != null
          ? int.tryParse(json['iconIndex'].toString())
          : null, // ✅ در صورت وجود مقدار
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "title": title,
      if (iconIndex != null) "iconIndex": iconIndex,
    };
  }
}
