class FilterBase {
  String? searchTerm;
  int? page;
  int? pageSize;
  String? sortBy;
  String? sortDirection;

  FilterBase({
    this.searchTerm,
    this.page,
    this.pageSize,
    this.sortBy,
    this.sortDirection,
  });
}
