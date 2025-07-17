class Paginated<T> {
  final List<T> items;
  final int totalCount;
  final int pageSize;
  final int page;

  bool get hasNextPage => (page * pageSize) < totalCount;
  bool get hasPreviousPage => page > 1;
  int get totalPages => (totalCount / pageSize).ceil();

  Paginated({
    required this.items,
    required this.totalCount,
    required this.pageSize,
    required this.page,
  });
}
