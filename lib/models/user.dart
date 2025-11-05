import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String token;
  final String username;
  final String expiration;
  final String roles;

  const User({
    required this.token,
    required this.username,
    required this.expiration,
    required this.roles,
  });

  bool get isTokenExpired {
    try {
      final expirationDate = DateTime.parse(expiration);
      return DateTime.now().isAfter(expirationDate);
    } catch (e) {
      return true;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'username': username,
      'expiration': expiration,
      'roles': roles,
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      token: json['token'] as String,
      username: json['username'] as String,
      expiration: json['expiration'] as String,
      roles: json['roles'] as String,
    );
  }

  @override
  List<Object?> get props => [token, username, expiration, roles];
}
