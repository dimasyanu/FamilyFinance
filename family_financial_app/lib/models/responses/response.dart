class Response<T> {
  final T? data;
  final List<String>? errors;
  final String? message;
  final bool success;

  Response({this.data, this.errors, this.message, this.success = true});

  bool get hasError => errors != null && errors!.isNotEmpty;
}