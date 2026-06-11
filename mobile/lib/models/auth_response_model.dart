/// Data model representing the JWT authentication response from the API.
class AuthResponse {
  /// The signed JWT bearer token.
  final String token;

  /// The authenticated user's display name.
  final String username;

  /// The authenticated user's email address.
  final String email;

  /// UTC timestamp when the [token] expires.
  final DateTime expireAt;

  const AuthResponse({
    required this.token,
    required this.username,
    required this.email,
    required this.expireAt,
  });

  /// Deserialises an [AuthResponse] from a JSON map returned by the API.
  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      token: json['token'] as String? ?? '',
      username: json['username'] as String? ?? '',
      email: json['email'] as String? ?? '',
      expireAt: json['expireAt'] != null
          ? DateTime.parse(json['expireAt'] as String)
          : DateTime.now(),
    );
  }

  /// Serialises this response to a JSON-compatible map.
  Map<String, dynamic> toJson() => {
        'token': token,
        'username': username,
        'email': email,
        'expireAt': expireAt.toIso8601String(),
      };
}
