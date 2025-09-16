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

  LocationItem({required this.id, required this.title});

  factory LocationItem.fromJson(Map<String, dynamic> json) {
    return LocationItem(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
    );
  }
}
