import 'package:family_financial_app/models/requests/filter_base.dart';

class FilterAccount extends FilterBase {
  bool? isActive;

  FilterAccount({
    super.searchTerm,
    super.page,
    super.pageSize,
    super.sortBy,
    super.sortDirection,
    this.isActive,
  });
}
