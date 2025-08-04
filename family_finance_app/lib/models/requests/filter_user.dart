import 'package:family_financial_app/models/requests/filter_base.dart';

class FilterUser extends FilterBase {
  bool? isActive;

  FilterUser({
    this.isActive,
    super.searchTerm,
    super.page,
    super.pageSize,
    super.sortBy,
    super.sortDirection,
  });
}
