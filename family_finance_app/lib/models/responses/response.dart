class Response<T> {
  final T? data;
  final List<String>? errors;
  final String? message;
  final bool success;

  Response({this.data, this.errors, this.message, this.success = true});

  bool get hasError => errors != null && errors!.isNotEmpty;

  factory Response.fromJson(Map<String, dynamic> json, T Function(Map<String, dynamic>) fromJsonT) {
    return Response<T>(
      data: json['data'] != null ? fromJsonT(json['data']) : null,
      errors: json['errors'] != null ? List<String>.from(json['errors']) : null,
      message: json['message'],
      success: json['success'] ?? true,
    );
  }
}
