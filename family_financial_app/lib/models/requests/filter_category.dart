import 'package:family_financial_app/models/requests/filter_base.dart';

class FilterCategory extends FilterBase {
  FilterCategory({
    super.searchTerm,
    super.page,
    super.pageSize,
    super.sortBy,
    super.sortDirection,
  });
}
