import 'dart:convert';

import 'package:family_financial_app/models/requests/login_request.dart';
import 'package:family_financial_app/models/responses/login_response.dart';
import 'package:family_financial_app/models/responses/response.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class Api {
  final String baseUrl = dotenv.env['API_BASE_URL'] ?? 'http://localhost:5000';

  Future<Response<LoginResponse>> login(String username, String password) async {
    final url = Uri.parse('$baseUrl/api/auth/login');
    final requestBody = LoginRequest(username, password);

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(requestBody.toJson()),
    );

    if (response.statusCode != 200) {
      final body = Response.fromJson(
        jsonDecode(response.body),
        (data) => data,
      );
      throw Exception(body.message ?? 'Login failed');
    }

    final result = Response<LoginResponse>.fromJson(
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
}
