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

  factory Paginated.fromJson(Map<String, dynamic> json, T Function(Map<String, dynamic>) fromJsonT) {
    return Paginated<T>(
      items: (json['items'] as List).map((item) => fromJsonT(item as Map<String, dynamic>)).toList(),
      totalCount: json['totalCount'] as int,
      pageSize: json['pageSize'] as int,
      page: json['page'] as int,
    );
  }
}
