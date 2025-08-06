import 'dart:convert';
import 'package:family_financial_app/abstractions/serializable.dart';
import 'package:family_financial_app/abstractions/store.dart';
import 'package:family_financial_app/constants/storage_key.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class MobileStore extends Store {
  final storage = FlutterSecureStorage();

  MobileStore() : super(null);

  @override
  String get loginTitle => 'Mobile Family Financial';

  @override
  Future<void> delete(String key) async {
    await storage.delete(key: StorageKey.user);
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
  Future<void> set<T extends Serializable>(String key, T value) async {
    final jsonData = jsonEncode(value.toJson());
    await storage.write(key: key, value: jsonData);
  }
}
