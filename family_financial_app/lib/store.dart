import 'dart:convert';

import 'package:family_financial_app/api.dart';
import 'package:family_financial_app/constants/storage_key.dart';
import 'package:family_financial_app/models/responses/login_response.dart';
import 'package:family_financial_app/models/responses/response.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class Store with ChangeNotifier, DiagnosticableTreeMixin {
  final title = 'Family Financial App';
  final api = Api();
  final storage = FlutterSecureStorage();

  LoginResponse? loginResponse;

  Future<Response<LoginResponse>> login(String username, String password) async {
    // Implement login logic here
    final response = await api.login(username, password);
    if (response.data == null) {
      throw Exception('Login failed');
    }
    loginResponse = response.data;
    notifyListeners();
    storage.write(key: StorageKey.user, value: jsonEncode(loginResponse!.toJson()));
    return response;
  }

  Future<void> logout() async {
    loginResponse = null;
    await storage.delete(key: StorageKey.user);
    notifyListeners();
  }

  void test() {
    // Example method to test the store functionality
    debugPrint('Store test method called');
  }
}
