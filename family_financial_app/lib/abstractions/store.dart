import 'dart:convert';

import 'package:family_financial_app/api.dart';
import 'package:family_financial_app/constants/storage_key.dart';
import 'package:family_financial_app/models/responses/login_response.dart';
import 'package:family_financial_app/models/responses/response.dart';
import 'package:flutter/foundation.dart';

abstract class Store with ChangeNotifier, DiagnosticableTreeMixin {
  final Api api = Api();

  LoginResponse? loginResponse;

  // Abstract methods for store operations
  void set(String key, Map<String, dynamic> value);
  T get<T>(String key);
  Future<void> delete(String key);

  Future<Response<LoginResponse>> login(String username, String password) async {
    // Implement login logic here
    final response = await api.login(username, password);
    if (response.data == null) {
      throw Exception('Login failed');
    }
    loginResponse = response.data;
    notifyListeners();
    set(StorageKey.user, loginResponse!.toJson());
    return response;
  }

  Future<void> logout() async {
    loginResponse = null;
    await delete(StorageKey.user);
    notifyListeners();
  }
}
