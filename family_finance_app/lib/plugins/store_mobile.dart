import 'dart:convert';
import 'package:family_financial_app/abstractions/serializable.dart';
import 'package:family_financial_app/abstractions/store.dart';
import 'package:family_financial_app/constants/storage_key.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StoreMobile extends Store {
  final storage = FlutterSecureStorage();

  StoreMobile() : super(null);

  @override
  String get loginTitle => 'Mobile Family Financial';

  @override
  Future<void> delete(String key) async {
    await storage.delete(key: StorageKey.login);
  }

  @override
  Future<Map<String, dynamic>?> get(String key) async {
    final value = await storage.read(key: key);
    if (value == null) return null;
    final jsonData = jsonDecode(value);

    final result = jsonData as Map<String, dynamic>;

    return result;
  }

  @override
  Future<String?> getString(String key) async {
    final value = await storage.read(key: key);
    if (value == null) return null;
    return value;
  }

  @override
  Future<void> set<T extends Serializable>(String key, T value) async {
    final jsonData = jsonEncode(value.toJson());
    await storage.write(key: key, value: jsonData);
  }

  @override
  Future<void> setString(String key, String value) async {
    await storage.write(key: key, value: value);
  }
}
