import 'dart:convert';

import 'package:family_financial_app/models/requests/login_request.dart';
import 'package:family_financial_app/models/responses/dto_user.dart';
import 'package:family_financial_app/models/responses/login_response.dart';
import 'package:family_financial_app/models/responses/res.dart';
import 'package:family_financial_app/plugins/api.dart';
import 'package:http/http.dart' as http;

class ApiAuth extends Api {
  ApiAuth(super.context);

  Future<Res<LoginResponse>> login(String username, String password) async {
    final url = Uri.parse('$baseUrl/api/auth/login');
    final requestBody = LoginRequest(username, password);

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(requestBody.toJson()),
    );

    if (response.statusCode != 200) {
      final body = Res.fromJson(jsonDecode(response.body), (data) => data);
      throw Exception(body.message ?? 'Login failed');
    }

    final result = Res<LoginResponse>.fromJson(
      jsonDecode(response.body),
      (data) => LoginResponse.fromJson(data),
    );

    if (result.hasError) {
      throw Exception('Login failed: ${result.errors?.join(', ')}');
    }

    if (result.data == null) {
      throw Exception('Login response data is null');
    }

    return result;
  }

  Future<Res<DtoUser>> userInfo(String accessToken) async {
    final url = Uri.parse('$baseUrl/Api/Auth/UserInfo');

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode != 200) {
      final body = Res.fromJson(jsonDecode(response.body), (data) => data);
      throw Exception(body.message ?? 'Registration failed');
    }

    final result = Res<DtoUser>.fromJson(
      jsonDecode(response.body),
      (data) => DtoUser.fromJson(data),
    );

    if (result.hasError) {
      throw Exception('Registration failed: ${result.errors?.join(', ')}');
    }

    if (result.data == null) {
      throw Exception('Registration response data is null');
    }

    return result;
  }
}
