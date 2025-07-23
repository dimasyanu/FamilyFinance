import 'dart:convert';

import 'package:family_financial_app/abstractions/serializable.dart';
import 'package:family_financial_app/abstractions/store.dart';
import 'package:family_financial_app/constants/storage_key.dart';
import 'package:family_financial_app/models/responses/login_response.dart';
// import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';

class WebStore extends Store {

  WebStore() : super(null);

  @override
  String get loginTitle => 'Web Family Financial';

  @override
  Future<void> delete(String key) async {
    await Future.sync(() {
      localStorage.removeItem(StorageKey.user);
    });
  }

  @override
  Future<Map<String, dynamic>> get(String key) async {
    final value = localStorage.getItem(key);
    if (value == null) throw Exception('No data found for key: $key');
    return await Future.value(jsonDecode(value) as Map<String, dynamic>);
  }

  @override
  Future<void> set<T extends Serializable>(String key, T value) async {
    await Future.sync(() {
      localStorage.setItem(key, jsonEncode(value.toJson()));
    });
  }

  @override
  LoginResponse? getUser() {
    LoginResponse? user = super.getUser();
    if (user == null) {
      user = LoginResponse.fromJson(
        jsonDecode(localStorage.getItem(StorageKey.user) ?? '{}') as Map<String, dynamic>,
      );
      super.user = user;
      return user;
    }
    return user;
  }
}
