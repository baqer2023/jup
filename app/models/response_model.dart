// class ResponseModel {
//   ResponseModel({
//     required this.body,
//     required this.statusCode,
//     required this.success,
//     this.message,
//   });
//
//   final dynamic body;
//   final int? statusCode;
//   final bool success;
//   final String? message;
// }


import 'dart:convert';

class ResponseModel {
  ResponseModel({
    required this.body,
    required this.statusCode,
    required this.success,
    this.message,
  });

  final dynamic body;
  final int? statusCode;
  final bool success;
  final String? message;

  // Add these getters for easier data access
  Map<String, dynamic> get data {
    if (body is Map<String, dynamic>) {
      return body as Map<String, dynamic>;
    }
    throw Exception('Response body is not a Map');
  }

  // For APIs that return the data in a 'data' field
  Map<String, dynamic> get responseData {
    final json = data;
    return json['data'] as Map<String, dynamic>? ?? json;
  }

  // For handling JSON string responses
  Map<String, dynamic> getJsonData() {
    if (body is String) {
      return jsonDecode(body) as Map<String, dynamic>;
    }
    return data;
  }
}
