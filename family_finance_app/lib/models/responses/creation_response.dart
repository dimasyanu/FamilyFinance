class CreationResponse<TId> {
  final TId id;

  CreationResponse({required this.id});

  factory CreationResponse.fromJson(Map<String, dynamic> json) {
    return CreationResponse(id: json['id'] as TId);
  }
}
