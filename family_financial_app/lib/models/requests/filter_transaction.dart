import 'package:family_financial_app/models/requests/filter_base.dart';

class FilterTransaction extends FilterBase {
  double? minAmount;
  double? maxAmount;
  DateTime? startDate;
  DateTime? endDate;
  List<String>? userIds;
  List<String>? categoryIds;
  bool? isActive;

  FilterTransaction({
    this.minAmount,
    this.maxAmount,
    this.startDate,
    this.endDate,
    this.userIds,
    this.categoryIds,
    this.isActive,
    super.searchTerm,
    super.page,
    super.pageSize,
    super.sortBy,
    super.sortDirection,
  });
}
