class Res<T> {
  final T? data;
  final List<String>? errors;
  final String? message;
  final bool success;

  Res({this.data, this.errors, this.message, this.success = true});

  bool get hasError => errors != null && errors!.isNotEmpty;

  factory Res.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    return Res<T>(
      data: json['data'] != null ? fromJsonT(json['data']) : null,
      errors: json['errors'] != null ? List<String>.from(json['errors']) : null,
      message: json['message'],
      success: json['success'] ?? true,
    );
  }
}
