import 'package:family_financial_app/abstractions/store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

class Api {
  final String baseUrl = dotenv.env['API_BASE_URL'] ?? 'http://localhost:5000';
  final BuildContext? context;
  late final String accessToken;

  Api(this.context) {
    accessToken = context?.read<Store>().getUser()?.accessToken ?? '';
  }
}
