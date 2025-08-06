import 'dart:convert';

import 'package:family_financial_app/models/requests/save_transaction.dart';
import 'package:family_financial_app/models/responses/creation_response.dart';
import 'package:family_financial_app/models/responses/dto_transaction.dart';
import 'package:family_financial_app/models/responses/item_transaction.dart';
import 'package:family_financial_app/models/responses/paginated.dart';
import 'package:family_financial_app/models/responses/res.dart';
import 'package:family_financial_app/plugins/api.dart';
import 'package:http/http.dart' as http;

class ApiTransactions extends Api {
  ApiTransactions(super.context);

  Future<Res<Paginated<ItemTransaction>>> getTransactions({
    int page = 1,
    int pageSize = 25,
  }) async {
    final url = Uri.parse(
      '${super.baseUrl}/api/transactions?page=$page&pageSize=$pageSize',
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
      throw Exception(body.message ?? 'Failed to fetch transactions');
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;

    final result = Res<Paginated<ItemTransaction>>.fromJson(
      body,
      (data) => Paginated<ItemTransaction>.fromJson(
        data,
        (item) => ItemTransaction.fromJson(item),
      ),
    );

    if (result.hasError) {
      throw Exception(
        'Failed to fetch transactions: ${result.errors?.join(', ')}',
      );
    }

    return result;
  }

  Future<Res<DtoTransaction>> getTransactionById({
    required String transactionId,
  }) async {
    final url = Uri.parse('$baseUrl/api/transactions/$transactionId');

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        if (accessToken.isNotEmpty) 'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode != 200) {
      final body = Res.fromJson(jsonDecode(response.body), (data) => data);
      throw Exception(body.message ?? 'Failed to fetch transaction');
    }

    final result = Res<DtoTransaction>.fromJson(
      jsonDecode(response.body),
      (data) => DtoTransaction.fromJson(data),
    );

    if (result.hasError) {
      throw Exception(
        'Failed to fetch transaction: ${result.errors?.join(', ')}',
      );
    }

    return result;
  }

  Future<Res<CreationResponse>> saveTransaction({
    required SaveTransaction payload,
  }) async {
    final uri = Uri.parse('$baseUrl/api/transactions');

    http.Response response;
    if (payload.id != null && payload.id!.isNotEmpty) {
      final updateUri = uri.replace(
        path: '${uri.path}/${payload.id}',
      ); // Update existing transaction

      response = await http.put(
        updateUri,
        headers: {
          'Content-Type': 'application/json',
          if (accessToken.isNotEmpty) 'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode(payload),
      );
      if (response.statusCode != 200) {
        final body = Res.fromJson(jsonDecode(response.body), (data) => data);
        throw Exception(body.message ?? 'Failed to save transaction');
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
        throw Exception(body.message ?? 'Failed to save transaction');
      }
    }

    final result = Res<CreationResponse>.fromJson(
      jsonDecode(response.body),
      (data) => CreationResponse.fromJson(data),
    );

    if (result.hasError) {
      throw Exception(
        'Failed to save transaction: ${result.errors?.join(', ')}',
      );
    }

    return result;
  }

  Future<Res<void>> deleteTransaction({required String transactionId}) async {
    final url = Uri.parse('$baseUrl/api/transactions/$transactionId');

    final response = await http.delete(
      url,
      headers: {
        'Content-Type': 'application/json',
        if (accessToken.isNotEmpty) 'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode != 200) {
      final body = Res.fromJson(jsonDecode(response.body), (data) => data);
      throw Exception(body.message ?? 'Failed to delete transaction');
    }

    return Res<void>(success: true);
  }
}
