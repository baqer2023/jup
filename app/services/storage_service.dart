import 'dart:convert';
import 'package:get_storage/get_storage.dart';

abstract class LocalStorage {
  Future<void> write(String key, dynamic value);

  dynamic read<S>(String key, {S Function(Map<String, dynamic>)? construct});

  Future<void> remove(String key);

  void removeAll();
}

class StorageService implements LocalStorage {
  late final GetStorage _storage;

  StorageService() {
    _init();
  }

  void _init() {
    _storage = GetStorage();
  }

  @override
  Future<void> write(String key, dynamic value) async {
    // اگر value رشته است، مستقیم ذخیره کن، در غیر این صورت encode
    if (value is String) {
      await _storage.write(key, value);
    } else {
      await _storage.write(key, jsonEncode(value));
    }
  }

  @override
  dynamic read<S>(String key, {S Function(Map<String, dynamic>)? construct}) {
    final storedValue = _storage.read(key);
    if (storedValue == null) return null;

    // اگر construct داده نشده، مستقیم decode کن
    if (construct == null) {
      try {
        return jsonDecode(storedValue);
      } catch (_) {
        // اگر decode نشد یعنی رشته خالی یا ساده بوده
        return storedValue;
      }
    }

    // اگر construct داده شده، assume json map
    final Map<String, dynamic> jsonMap =
        storedValue is String ? jsonDecode(storedValue) : Map<String, dynamic>.from(storedValue);
    return construct(jsonMap);
  }

  @override
  Future<void> remove(String key) async {
    await _storage.remove(key);
  }

  @override
  void removeAll() {
    _storage.erase();
  }
}
