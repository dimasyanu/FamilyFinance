import 'package:family_financial_app/abstractions/serializable.dart';
import 'package:family_financial_app/constants/storage_key.dart';
import 'package:family_financial_app/models/responses/dto_user.dart';
import 'package:family_financial_app/models/responses/login_response.dart';
import 'package:family_financial_app/models/responses/res.dart';
import 'package:family_financial_app/plugins/api_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

abstract class Store with ChangeNotifier, DiagnosticableTreeMixin {
  final ApiAuth authApi;
  ThemeMode _themeMode = ThemeMode.system; // Initial theme mode
  ThemeMode get themeMode => _themeMode;

  Store(BuildContext? context) : authApi = ApiAuth(context);

  String get loginTitle =>
      throw UnimplementedError('loginTitle must be implemented in subclasses');

  LoginResponse? loginData;
  DtoUser? userData;

  // Abstract methods for store operations
  Future<Map<String, dynamic>?> get(String key);
  Future<String?> getString(String key);
  Future<void> set<T extends Serializable>(String key, T value);
  Future<void> setString(String key, String value);
  Future<void> delete(String key);

  LoginResponse? getLoginData() {
    return loginData;
  }

  Future<DtoUser?> getUserData() async {
    final user = await get(StorageKey.user);
    return user != null ? DtoUser.fromJson(user) : null;
  }

  Future<Res<LoginResponse>> login(String username, String password) async {
    // Implement login logic here
    final response = await authApi.login(username, password);
    if (response.data == null) {
      throw Exception('Login failed');
    }
    loginData = response.data;
    final userDataRes = await authApi.userInfo(loginData!.accessToken);
    if (userDataRes.data != null) {
      userData = userDataRes.data;
      set(StorageKey.user, userData!);
    }
    set(StorageKey.login, loginData!);
    notifyListeners();
    return response;
  }

  Future<void> logout() async {
    loginData = null;
    await delete(StorageKey.login);
    await delete(StorageKey.user);
    notifyListeners();
  }

  Future<void> reloadThemeMode() async {
    final isDarkThemeStr = await getString(StorageKey.isDarkTheme);
    _themeMode = (isDarkThemeStr == 'true') ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }
}
