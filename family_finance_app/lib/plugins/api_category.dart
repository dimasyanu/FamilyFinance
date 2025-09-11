import 'dart:convert';

import 'package:family_financial_app/models/requests/save_category.dart';
import 'package:family_financial_app/models/responses/creation_response.dart';
import 'package:family_financial_app/models/responses/dto_category.dart';
import 'package:family_financial_app/models/responses/item_category.dart';
import 'package:family_financial_app/models/responses/paginated.dart';
import 'package:family_financial_app/models/responses/res.dart';
import 'package:family_financial_app/plugins/api.dart';
import 'package:http/http.dart' as http;

class ApiCategory extends Api {
  ApiCategory(super.context);

  Future<Res<Paginated<ItemCategory>>> getCategories({
    int page = 1,
    int pageSize = 25,
  }) async {
    final url = Uri.parse(
      '${super.baseUrl}/api/categories?page=$page&pageSize=$pageSize',
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
      throw Exception(body.message ?? 'Failed to fetch categories');
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;

    final result = Res<Paginated<ItemCategory>>.fromJson(
      body,
      (data) => Paginated<ItemCategory>.fromJson(
        data,
        (item) => ItemCategory.fromJson(item),
      ),
    );

    if (result.hasError) {
      throw Exception(
        'Failed to fetch categories: ${result.errors?.join(', ')}',
      );
    }

    return result;
  }

  Future<Res<DtoCategory>> getCategoryById({required int categoryId}) async {
    final url = Uri.parse('$baseUrl/api/categories/$categoryId');

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        if (accessToken.isNotEmpty) 'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode != 200) {
      final body = Res.fromJson(jsonDecode(response.body), (data) => data);
      throw Exception(body.message ?? 'Failed to fetch category');
    }

    final result = Res<DtoCategory>.fromJson(
      jsonDecode(response.body),
      (data) => DtoCategory.fromJson(data),
    );

    if (result.hasError) {
      throw Exception('Failed to fetch category: ${result.errors?.join(', ')}');
    }

    return result;
  }

  Future<Res<CreationResponse>> saveCategory({
    required SaveCategory payload,
  }) async {
    final uri = Uri.parse('$baseUrl/api/categories');

    http.Response response;
    if (payload.id != null && payload.id! > 0) {
      final updateUri = uri.replace(
        path: '${uri.path}/${payload.id}',
      ); // Update existing category

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
        throw Exception(body.message ?? 'Failed to save category');
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
        throw Exception(body.message ?? 'Failed to save category');
      }
    }

    final result = Res<CreationResponse>.fromJson(
      jsonDecode(response.body),
      (data) => CreationResponse.fromJson(data),
    );

    if (result.hasError) {
      throw Exception('Failed to save category: ${result.errors?.join(', ')}');
    }

    return result;
  }

  Future<Res<void>> deleteCategory({required int categoryId}) async {
    final url = Uri.parse('$baseUrl/api/categories/$categoryId');

    final response = await http.delete(
      url,
      headers: {
        'Content-Type': 'application/json',
        if (accessToken.isNotEmpty) 'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode != 200) {
      final body = Res.fromJson(jsonDecode(response.body), (data) => data);
      throw Exception(body.message ?? 'Failed to delete category');
    }

    return Res<void>(success: true);
  }
}
