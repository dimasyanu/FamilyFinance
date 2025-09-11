class ItemUser {
  final int id;
  final String name;
  final String username;
  final bool isActive;

  ItemUser({
    required this.id,
    required this.name,
    required this.username,
    this.isActive = true,
  });
}
