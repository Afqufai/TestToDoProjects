/// Data model representing an authenticated user.
class User {
  final String id;
  final String username;
  final String email;

  const User({
    required this.id,
    required this.username,
    required this.email,
  });

  /// Deserialises a [User] from a JSON map.
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String? ?? '',
      username: json['username'] as String? ?? '',
      email: json['email'] as String? ?? '',
    );
  }

  /// Serialises this user to a JSON-compatible map.
  Map<String, dynamic> toJson() => {
        'id': id,
        'username': username,
        'email': email,
      };
}
