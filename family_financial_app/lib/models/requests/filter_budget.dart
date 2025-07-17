import 'package:family_financial_app/models/requests/filter_base.dart';

class FilterBudget extends FilterBase{
  int? month;
  int? year;
  String? categoryId;

  FilterBudget({
    this.month,
    this.year,
    this.categoryId,
    super.searchTerm,
    super.page,
    super.pageSize,
    super.sortBy,
    super.sortDirection,
  });
}
