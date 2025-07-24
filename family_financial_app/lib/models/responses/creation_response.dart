class CreationResponse {
  final String id;

  CreationResponse({required this.id});

  factory CreationResponse.fromJson(Map<String, dynamic> json) {
    return CreationResponse(
      id: json['id'] as String,
    );
  }
}
