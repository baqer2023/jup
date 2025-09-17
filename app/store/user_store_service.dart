import 'dart:async';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:my_app32/app/core/app_constants.dart';
import 'package:my_app32/app/services/storage_service.dart';

class UserStoreService extends GetxService {
  UserStoreService(this._storage);

  final LocalStorage _storage;
  final _secureStorage = const FlutterSecureStorage();

  static UserStoreService get to => Get.find();

  Future<void> saveToken(String tokenString) async {
    await _secureStorage.write(key: AppConstants.TOKEN, value: tokenString);
    print("✅ Token saved: $tokenString");
  }

  Future<void> saveRefreshToken(String tokenString) async {
    await _secureStorage.write(
      key: AppConstants.REFRESH_TOKEN,
      value: tokenString,
    );
    print("✅ Refresh token saved: $tokenString");
  }

  Future<String?> getToken() async {
    final token = await _secureStorage.read(key: AppConstants.TOKEN);
    print("📥 Token loaded: $token");
    return token;
  }

  Future<String?> getRefreshToken() async {
    final refreshToken = await _secureStorage.read(key: AppConstants.REFRESH_TOKEN);
    print("📥 Refresh token loaded: $refreshToken");
    return refreshToken;
  }

  Future<void> deleteToken() async {
    await _secureStorage.delete(key: AppConstants.TOKEN);
    print("🗑 Token deleted");
  }

  Future<void> deleteRefreshToken() async {
    await _secureStorage.delete(key: AppConstants.REFRESH_TOKEN);
    print("🗑 Refresh token deleted");
  }

  Future<void> save({required String key, required dynamic value}) async {
    await _storage.write(key, value);
    print("💾 Saved [$key] = $value");
  }

  dynamic get({required String key}) {
    final value = _storage.read(key);
    print("📥 Loaded [$key] = $value");
    return value;
  }

  Future<void> delete({required String key}) async {
    _storage.remove(key);
    print("🗑 Deleted key: $key");
  }

  Future<void> deleteAll() async {
    _storage.removeAll();
    await _secureStorage.deleteAll();
    print("🧹 Cleared all storage");
  }
}
