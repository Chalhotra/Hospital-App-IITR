class LoginResponse {
  final String token;
  final String refreshToken;
  final String expiration;
  final String username;
  final String roles;

  LoginResponse({
    required this.token,
    required this.refreshToken,
    required this.expiration,
    required this.username,
    required this.roles,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      token: json['token'] as String,
      refreshToken: json['refreshToken'] as String,
      expiration: json['expiration'] as String,
      username: json['username'] as String,
      roles: json['roles'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'refreshToken': refreshToken,
      'expiration': expiration,
      'username': username,
      'roles': roles,
    };
  }
}
