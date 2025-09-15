import 'dart:convert';

import 'package:family_financial_app/abstractions/serializable.dart';
import 'package:family_financial_app/abstractions/store.dart';
import 'package:family_financial_app/constants/storage_key.dart';
import 'package:family_financial_app/models/responses/login_response.dart';
import 'package:localstorage/localstorage.dart';

class StoreWeb extends Store {
  StoreWeb() : super(null);

  @override
  String get loginTitle => 'Web Family Financial';

  @override
  Future<void> delete(String key) async {
    await Future.sync(() {
      localStorage.removeItem(StorageKey.login);
    });
  }

  @override
  Future<Map<String, dynamic>?> get(String key) async {
    final value = localStorage.getItem(key);
    if (value == null) return null;
    return await Future.value(jsonDecode(value) as Map<String, dynamic>);
  }

  @override
  Future<String?> getString(String key) async {
    final value = localStorage.getItem(key);
    if (value == null) return null;
    return await Future.value(value);
  }

  @override
  Future<void> set<T extends Serializable>(String key, T value) async {
    await Future.sync(() {
      localStorage.setItem(key, jsonEncode(value.toJson()));
    });
  }

  @override
  Future<void> setString(String key, String value) async {
    await Future.sync(() {
      localStorage.setItem(key, value);
    });
  }

  @override
  LoginResponse? getLoginData() {
    LoginResponse? user = super.getLoginData();
    if (user != null) return user;

    final loginDataStr = localStorage.getItem(StorageKey.login);
    if (loginDataStr == null) return null;
    user = LoginResponse.fromJson(
      jsonDecode(loginDataStr) as Map<String, dynamic>,
    );
    super.loginData = user;
    return user;
  }
}
