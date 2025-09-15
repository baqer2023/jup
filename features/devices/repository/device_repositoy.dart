import 'package:dio/dio.dart';

class DeviceRepository {
  final Dio dio = Dio();

  Future<dynamic> getFirstDashboardData({required String token}) async {
    try {
      final headers = {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };

      final data = ' '; // رشته با فاصله، همونطور که API جواب می‌ده

      final response = await dio.request(
        'http://45.149.76.245:8080/api/dashboard/getFirst',
        options: Options(
          method: 'POST',
          headers: headers,
        ),
        data: data,
      );

      if (response.statusCode == 200) {
        return response.data; // ✅ List یا Map
      } else {
        print("❌ StatusCode: ${response.statusCode}");
        print("❌ StatusMessage: ${response.statusMessage}");
        return null;
      }
    } catch (e) {
      print("❌ Error: $e");
      return null;
    }
  }
}
