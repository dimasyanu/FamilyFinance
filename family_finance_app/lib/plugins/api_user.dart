import 'dart:convert';

import 'package:family_financial_app/models/responses/dto_user.dart';
import 'package:family_financial_app/models/responses/res.dart';
import 'package:family_financial_app/plugins/api.dart';
import 'package:http/http.dart' as http;

class ApiUser extends Api {
  ApiUser(super.context);

  Future<Res<DtoUser>> getUserProfile(int userId) async {
    final url = Uri.parse('$baseUrl/api/users/$userId');

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        if (accessToken.isNotEmpty) 'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode != 200) {
      final body = Res.fromJson(jsonDecode(response.body), (data) => data);
      throw Exception(body.message ?? 'Failed to fetch user profile');
    }

    final result = Res<DtoUser>.fromJson(
      jsonDecode(response.body),
      (data) => DtoUser.fromJson(data),
    );

    if (result.hasError) {
      throw Exception('Failed to fetch account: ${result.errors?.join(', ')}');
    }

    return result;
  }
}
