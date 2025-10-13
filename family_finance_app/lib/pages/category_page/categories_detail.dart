import 'package:family_financial_app/models/responses/item_category.dart';
import 'package:flutter/material.dart';

class CategoriesDetail extends StatelessWidget {
  final ItemCategory category;

  const CategoriesDetail({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Center(
          child: Text(
            category.name,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
        Text(category.description ?? ''),
        Text('Created: ${category.createdAt}'),
        Text('Updated: ${category.createdBy}'),
      ],
    );
  }
}
