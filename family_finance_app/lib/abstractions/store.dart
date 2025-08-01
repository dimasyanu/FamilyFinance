import 'package:family_financial_app/abstractions/serializable.dart';
import 'package:family_financial_app/constants/storage_key.dart';
import 'package:family_financial_app/models/responses/login_response.dart';
import 'package:family_financial_app/models/responses/res.dart';
import 'package:family_financial_app/plugins/api_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

abstract class Store with ChangeNotifier, DiagnosticableTreeMixin {
  final ApiAuth authApi;

  Store(BuildContext? context) : authApi = ApiAuth(context);

  String get loginTitle =>
      throw UnimplementedError('loginTitle must be implemented in subclasses');

  LoginResponse? user;

  // Abstract methods for store operations
  Future<void> set<T extends Serializable>(String key, T value);
  Future<Map<String, dynamic>> get(String key);
  Future<void> delete(String key);
  LoginResponse? getUser() {
    return user;
  }

  Future<Res<LoginResponse>> login(String username, String password) async {
    // Implement login logic here
    final response = await authApi.login(username, password);
    if (response.data == null) {
      throw Exception('Login failed');
    }
    user = response.data;
    notifyListeners();
    set(StorageKey.user, user!);
    return response;
  }

  Future<void> logout() async {
    user = null;
    await delete(StorageKey.user);
    notifyListeners();
  }
}
