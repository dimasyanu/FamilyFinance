import 'dart:convert';

import 'package:family_financial_app/models/requests/save_account.dart';
import 'package:family_financial_app/models/responses/creation_response.dart';
import 'package:family_financial_app/models/responses/dto_account.dart';
import 'package:family_financial_app/models/responses/item_account.dart';
import 'package:family_financial_app/models/responses/paginated.dart';
import 'package:family_financial_app/models/responses/res.dart';
import 'package:family_financial_app/plugins/api.dart';
import 'package:http/http.dart' as http;

class ApiAccounts extends Api {
  ApiAccounts(super.context);

  Future<Res<Paginated<ItemAccount>>> getAccounts({
    required int userId,
    int page = 1,
    int pageSize = 25,
  }) async {
    final url = Uri.parse(
      '${super.baseUrl}/api/users/$userId/accounts?page=$page&pageSize=$pageSize',
    );

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        if (accessToken.isNotEmpty) 'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode != 200) {
      final body = Res.fromJson(jsonDecode(response.body), (data) => data);
      throw Exception(body.message ?? 'Failed to fetch accounts');
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;

    final result = Res<Paginated<ItemAccount>>.fromJson(
      body,
      (data) => Paginated<ItemAccount>.fromJson(
        data,
        (item) => ItemAccount.fromJson(item),
      ),
    );

    if (result.hasError) {
      throw Exception('Failed to fetch accounts: ${result.errors?.join(', ')}');
    }

    return result;
  }

  Future<Res<DtoAccount>> getAccountById({
    required int userId,
    required int accountId,
  }) async {
    final url = Uri.parse('$baseUrl/api/users/$userId/accounts/$accountId');

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        if (accessToken.isNotEmpty) 'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode != 200) {
      final body = Res.fromJson(jsonDecode(response.body), (data) => data);
      throw Exception(body.message ?? 'Failed to fetch account');
    }

    final result = Res<DtoAccount>.fromJson(
      jsonDecode(response.body),
      (data) => DtoAccount.fromJson(data),
    );

    if (result.hasError) {
      throw Exception('Failed to fetch account: ${result.errors?.join(', ')}');
    }

    return result;
  }

  Future<Res<CreationResponse<int>>> saveAccount({
    required int userId,
    required SaveAccount payload,
  }) async {
    final uri = Uri.parse('$baseUrl/api/users/$userId/accounts');

    http.Response response;
    if (payload.id != null && payload.id! > 0) {
      final updateUri = uri.replace(
        path: '${uri.path}/${payload.id}',
      ); // Update existing account

      response = await http.patch(
        updateUri,
        headers: {
          'Content-Type': 'application/json',
          if (accessToken.isNotEmpty) 'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode(payload.toJson()),
      );
      if (response.statusCode != 200) {
        final body = Res.fromJson(jsonDecode(response.body), (data) => data);
        throw Exception(body.message ?? 'Failed to save account');
      }
    } else {
      response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          if (accessToken.isNotEmpty) 'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode(payload.toJson()),
      );
      if (response.statusCode != 201) {
        final body = Res.fromJson(jsonDecode(response.body), (data) => data);
        throw Exception(body.message ?? 'Failed to save account');
      }
    }

    final result = Res<CreationResponse<int>>.fromJson(
      jsonDecode(response.body),
      (data) => CreationResponse<int>.fromJson(data),
    );

    if (result.hasError) {
      throw Exception('Failed to save account: ${result.errors?.join(', ')}');
    }

    return result;
  }

  Future<Res<void>> deleteAccount({
    required int userId,
    required int accountId,
  }) async {
    final url = Uri.parse('$baseUrl/api/users/$userId/accounts/$accountId');

    final response = await http.delete(
      url,
      headers: {
        'Content-Type': 'application/json',
        if (accessToken.isNotEmpty) 'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode != 200) {
      final body = Res.fromJson(jsonDecode(response.body), (data) => data);
      throw Exception(body.message ?? 'Failed to delete account');
    }

    return Res<void>(success: true);
  }
}
