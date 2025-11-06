class RegisterRequest {
  final String username;
  final String password;
  final String roles;

  RegisterRequest({
    required this.username,
    required this.password,
    this.roles = 'PAT',
  });

  Map<String, dynamic> toJson() {
    return {'username': username, 'password': password, 'roles': roles};
  }
}
