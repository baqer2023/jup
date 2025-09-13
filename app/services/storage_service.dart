import 'dart:convert';

import 'package:get_storage/get_storage.dart';

abstract class LocalStorage {
  Future<void> write(String key, dynamic json);

  dynamic read<S>(String key, {S Function(Map) construct});

  Future<void> remove(String key);

  void removeAll();
}

class StorageService implements LocalStorage {
  StorageService() {
    _init();
  }

  late GetStorage storage;

  void _init() {
    storage = GetStorage();
  }

  @override
  Future<void> write(String key, dynamic value) async {
    await storage.write(key, jsonEncode(value));
  }

  @override
  dynamic read<S>(String key, {S Function(Map)? construct}) {
    final value = storage.read(key);
    if (value == null) return;
    if (construct == null) return jsonDecode(value);
    final Map<String, dynamic> json = jsonDecode(value);

    return construct(json);
  }

  @override
  Future<void> remove(String key) async {
    storage.remove(key);
  }

  @override
  void removeAll() {
    storage.erase();
  }
}
