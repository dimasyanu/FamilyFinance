abstract class Serializable {
  /// Converts the object to a JSON-serializable map.
  Map<String, dynamic> toJson();

  /// Creates an object from a JSON-serializable map.
  factory Serializable.fromJson(Map<String, dynamic> json) {
    throw UnimplementedError('fromJson must be implemented by subclasses');
  }
}
