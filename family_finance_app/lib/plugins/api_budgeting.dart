import 'dart:convert';

import 'package:family_financial_app/models/requests/save_budget.dart';
import 'package:family_financial_app/models/responses/creation_response.dart';
import 'package:family_financial_app/models/responses/dto_budget.dart';
import 'package:family_financial_app/models/responses/item_budget.dart';
import 'package:family_financial_app/models/responses/paginated.dart';
import 'package:family_financial_app/models/responses/res.dart';
import 'package:family_financial_app/plugins/api.dart';
import 'package:http/http.dart' as http;

class ApiBudgeting extends Api {
  ApiBudgeting(super.context);

  Future<Res<Paginated<ItemBudget>>> getBudgets({
    int page = 1,
    int pageSize = 25,
  }) async {
    final url = Uri.parse(
      '${super.baseUrl}/api/budgets?page=$page&pageSize=$pageSize',
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
      throw Exception(body.message ?? 'Failed to fetch budgets');
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;

    final result = Res<Paginated<ItemBudget>>.fromJson(
      body,
      (data) => Paginated<ItemBudget>.fromJson(
        data,
        (item) => ItemBudget.fromJson(item),
      ),
    );

    if (result.hasError) {
      throw Exception('Failed to fetch budget: ${result.errors?.join(', ')}');
    }

    return result;
  }

  Future<Res<DtoBudget>> getBudgetById({required int budgetId}) async {
    final url = Uri.parse('$baseUrl/api/budgets/$budgetId');

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        if (accessToken.isNotEmpty) 'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode != 200) {
      final body = Res.fromJson(jsonDecode(response.body), (data) => data);
      throw Exception(body.message ?? 'Failed to fetch budget');
    }

    final result = Res<DtoBudget>.fromJson(
      jsonDecode(response.body),
      (data) => DtoBudget.fromJson(data),
    );

    if (result.hasError) {
      throw Exception('Failed to fetch budget: ${result.errors?.join(', ')}');
    }

    return result;
  }

  Future<Res<CreationResponse>> saveBudget({
    required SaveBudget payload,
  }) async {
    final uri = Uri.parse('$baseUrl/api/budgets');

    http.Response response;
    if (payload.id != null && payload.id! > 0) {
      final updateUri = uri.replace(
        path: '${uri.path}/${payload.id}',
      ); // Update existing budget

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
        throw Exception(body.message ?? 'Failed to save budget');
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
        throw Exception(body.message ?? 'Failed to save budget');
      }
    }

    final result = Res<CreationResponse>.fromJson(
      jsonDecode(response.body),
      (data) => CreationResponse.fromJson(data),
    );

    if (result.hasError) {
      throw Exception('Failed to save budget: ${result.errors?.join(', ')}');
    }

    return result;
  }

  Future<Res<void>> deleteBudget({required int budgetId}) async {
    final url = Uri.parse('$baseUrl/api/budgets/$budgetId');

    final response = await http.delete(
      url,
      headers: {
        'Content-Type': 'application/json',
        if (accessToken.isNotEmpty) 'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode != 200) {
      final body = Res.fromJson(jsonDecode(response.body), (data) => data);
      throw Exception(body.message ?? 'Failed to delete budget');
    }

    return Res<void>(success: true);
  }
}
