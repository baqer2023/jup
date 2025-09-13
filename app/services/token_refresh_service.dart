import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:my_app32/app/store/user_store_service.dart';

class TokenRefreshService extends GetxService {
  static TokenRefreshService get to => Get.find();

  final UserStoreService _userStore = Get.find<UserStoreService>();

  // Check if token is expired (you can adjust this logic based on your token structure)
  bool _isTokenExpired(String? token) {
    if (token == null) return true;

    try {
      // Decode JWT token to check expiration
      final parts = token.split('.');
      if (parts.length != 3) return true;

      final payload = json.decode(
        utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))),
      );
      final exp = payload['exp'] as int?;

      if (exp == null) return true;

      final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      return now >= exp;
    } catch (e) {
      print('Error checking token expiration: $e');
      return true;
    }
  }

  // Refresh token using the API
  Future<bool> refreshToken() async {
    try {
      final refreshToken = await _userStore.getRefreshToken();

      if (refreshToken == null) {
        print('No refresh token available');
        return false;
      }

      final response = await http.post(
        Uri.parse('http://45.149.76.245:8080/api/auth/token'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $refreshToken',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['token'] != null && data['refreshToken'] != null) {
          // Save new tokens
          await _userStore.saveToken(data['token']);
          await _userStore.saveRefreshToken(data['refreshToken']);

          print('Token refreshed successfully');
          return true;
        } else {
          print('Invalid response format for token refresh');
          return false;
        }
      } else {
        print('Token refresh failed with status: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Error refreshing token: $e');
      return false;
    }
  }

  // Check and refresh token if needed
  Future<bool> checkAndRefreshToken() async {
    final currentToken = await _userStore.getToken();

    if (currentToken == null) {
      print('No token available');
      return false;
    }

    if (_isTokenExpired(currentToken)) {
      print('Token is expired, attempting to refresh');
      return await refreshToken();
    } else {
      print('Token is still valid');
      return true;
    }
  }

  // Force refresh token (for manual refresh)
  Future<bool> forceRefreshToken() async {
    return await refreshToken();
  }
}
