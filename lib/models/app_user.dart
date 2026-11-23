class AppUser {
  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.accessToken,
  });

  final String id;
  final String name;
  final String email;
  final String role;
  final String? accessToken;

  bool get isAdmin => role == 'admin';

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: _requiredString(json, 'id'),
      name: _requiredString(json, 'nom'),
      email: _requiredString(json, 'email'),
      role: _requiredString(json, 'role'),
      accessToken: json['accessToken'] as String?,
    );
  }
}

String _requiredString(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is String) return value;
  throw FormatException('User $key must be a string.');
}
