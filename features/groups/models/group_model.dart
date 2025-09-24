class GroupModel {
  final String id;
  final String title;
  final String description;
  final DateTime createdTime;

  GroupModel({
    required this.id,
    required this.title,
    required this.description,
    required this.createdTime,
  });

  factory GroupModel.fromJson(Map<String, dynamic> json) {
    return GroupModel(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      createdTime: DateTime.tryParse(json['createdTime']?.toString() ?? '') ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'createdTime': createdTime.toIso8601String(),
    };
  }
}
