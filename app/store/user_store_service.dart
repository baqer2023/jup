import 'dart:async';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:my_app32/app/core/app_constants.dart';
import 'package:my_app32/app/services/storage_service.dart';

class UserStoreService {
  UserStoreService(this._storage);

  final LocalStorage _storage;
  final _secureStorage = const FlutterSecureStorage();

  static UserStoreService get to => Get.find();

  Future<void> saveToken(String tokenString) async {
    await _secureStorage.write(key: AppConstants.TOKEN, value: tokenString);
  }

  Future<void> saveRefreshToken(String tokenString) async {
    await _secureStorage.write(
      key: AppConstants.REFRESH_TOKEN,
      value: tokenString,
    );
  }

  Future<String?> getToken() async {
    return await _secureStorage.read(key: AppConstants.TOKEN);
  }

  Future<String?> getRefreshToken() async {
    return await _secureStorage.read(key: AppConstants.REFRESH_TOKEN);
  }

  Future<void> deleteToken() async {
    await _secureStorage.delete(key: AppConstants.TOKEN);
  }

  Future<void> deleteRefreshToken() async {
    await _secureStorage.delete(key: AppConstants.REFRESH_TOKEN);
  }

  Future<void> save({required String key, required dynamic value}) async {
    await _storage.write(key, value);
  }

  dynamic get({required String key}) {
    return _storage.read(key);
  }

Future<void> delete({required String key}) async {
  _storage.remove(key); // اگه void باشه → بدون await
}


Future<void> deleteAll() async {
  _storage.removeAll();              // این void هست → await لازم نداره
  await _secureStorage.deleteAll();  // این Future<void> هست → باید await بشه
}

}
