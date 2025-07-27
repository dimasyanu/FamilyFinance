import 'dart:convert';

import 'package:family_financial_app/abstractions/store.dart';
import 'package:family_financial_app/models/requests/login_request.dart';
import 'package:family_financial_app/models/requests/save_account.dart';
import 'package:family_financial_app/models/responses/creation_response.dart';
import 'package:family_financial_app/models/responses/dto_account.dart';
import 'package:family_financial_app/models/responses/item_account.dart';
import 'package:family_financial_app/models/responses/login_response.dart';
import 'package:family_financial_app/models/responses/paginated.dart';
import 'package:family_financial_app/models/responses/response.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class Api {
  final String baseUrl = dotenv.env['API_BASE_URL'] ?? 'http://localhost:5000';
  final BuildContext? context;
  final String accessToken; // You can set this from your authentication flow

  Api(this.context)
    : accessToken = context?.read<Store>().getUser()?.accessToken ?? '';

  Future<Response<LoginResponse>> login(
    String username,
    String password,
  ) async {
    final url = Uri.parse('$baseUrl/api/auth/login');
    final requestBody = LoginRequest(username, password);

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(requestBody.toJson()),
    );

    if (response.statusCode != 200) {
      final body = Response.fromJson(jsonDecode(response.body), (data) => data);
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

  Future<Response<Paginated<ItemAccount>>> getAccounts({
    required String userId,
    int page = 1,
    int pageSize = 25,
  }) async {
    final url = Uri.parse(
      '$baseUrl/api/users/$userId/accounts?page=$page&pageSize=$pageSize',
    );

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        if (accessToken.isNotEmpty) 'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode != 200) {
      final body = Response.fromJson(jsonDecode(response.body), (data) => data);
      throw Exception(body.message ?? 'Failed to fetch accounts');
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;

    final result = Response<Paginated<ItemAccount>>.fromJson(
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

  Future<Response<DtoAccount>> getAccountById({
    required String userId,
    required String accountId,
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
      final body = Response.fromJson(jsonDecode(response.body), (data) => data);
      throw Exception(body.message ?? 'Failed to fetch account');
    }

    final result = Response<DtoAccount>.fromJson(
      jsonDecode(response.body),
      (data) => DtoAccount.fromJson(data),
    );

    if (result.hasError) {
      throw Exception('Failed to fetch account: ${result.errors?.join(', ')}');
    }

    return result;
  }

  Future<Response<CreationResponse>> saveAccount({
    required String userId,
    required SaveAccount payload,
  }) async {
    final url = Uri.parse('$baseUrl/api/users/$userId/accounts');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        if (accessToken.isNotEmpty) 'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode(payload.toJson()),
    );

    if (response.statusCode != 201) {
      final body = Response.fromJson(jsonDecode(response.body), (data) => data);
      throw Exception(body.message ?? 'Failed to save account');
    }

    final result = Response<CreationResponse>.fromJson(
      jsonDecode(response.body),
      (data) => CreationResponse.fromJson(data),
    );

    if (result.hasError) {
      throw Exception('Failed to save account: ${result.errors?.join(', ')}');
    }

    return result;
  }

  Future<Response<void>> deleteAccount({
    required String userId,
    required String accountId,
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
      final body = Response.fromJson(jsonDecode(response.body), (data) => data);
      throw Exception(body.message ?? 'Failed to delete account');
    }

    return Response<void>(success: true);
  }
}
