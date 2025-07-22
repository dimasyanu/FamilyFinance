import 'dart:convert';

import 'package:family_financial_app/abstractions/serializable.dart';
import 'package:family_financial_app/abstractions/store.dart';
import 'package:family_financial_app/constants/storage_key.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class MobileStore extends Store {
  final storage = FlutterSecureStorage();

  @override
  Future<void> delete(String key) async {
    await storage.delete(key: StorageKey.user);
  }
  
  @override
  Future<T> get<T implements Serializable>(String key) async {
    final value = await storage.read(key: key);
    if (value == null) throw Exception('No data found for key: $key');
    final jsonData = jsonDecode(value);
    return T.fromJson(jsonData) as T;
  }
  
  @override
  Future<void> set<T extends Serializable>(String key, T value) async {
    final jsonData = jsonEncode(value.toJson());
    await storage.write(key: key, value: jsonData);
  }
}
