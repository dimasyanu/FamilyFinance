import 'package:family_financial_app/api.dart';
import 'package:family_financial_app/models/responses/login_response.dart';
import 'package:family_financial_app/models/responses/response.dart';
import 'package:flutter/foundation.dart';

class Store with ChangeNotifier, DiagnosticableTreeMixin {
  final String title = 'Family Financial App';
  final Api api = Api();
  LoginResponse? loginResponse;

  Future<Response<LoginResponse>> login(String username, String password) async {
    // Implement login logic here
    final response = await api.login(username, password);
    loginResponse = response.data;
    notifyListeners();
    return response;
  }

  void test() {
    // Example method to test the store functionality
    debugPrint('Store test method called');
  }
}
