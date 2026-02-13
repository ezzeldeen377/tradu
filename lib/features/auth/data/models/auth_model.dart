import 'user_model.dart';

class AuthModel {
  final String? uid;
  final String? email;
  final String? fullName;
  final String? token;
  final String? refreshToken;
  final User? user;

  const AuthModel({
    this.uid,
    this.email,
    this.fullName,
    this.token,
    this.refreshToken,
    this.user,
  });

  factory AuthModel.fromJson(Map<String, dynamic> json) {
    // Handle nested user object if present
    final userData = json['user'] as Map<String, dynamic>?;

    // If response is from /api/auth/me (no tokens, just user data)
    if (json['access_token'] == null &&
        json['token'] == null &&
        userData == null) {
      return AuthModel(
        user: User.fromMap(json),
        uid: json['id']?.toString(),
        email: json['email'] as String?,
        fullName: json['name'] as String?,
      );
    }

    // If response is from login/register (has tokens and user data)
    return AuthModel(
      uid:
          userData?['id']?.toString() ??
          userData?['uid']?.toString() ??
          json['id']?.toString() ??
          json['uid']?.toString(),
      email: userData?['email'] as String? ?? json['email'] as String?,
      fullName:
          userData?['name'] as String? ??
          userData?['fullName'] as String? ??
          json['name'] as String? ??
          json['fullName'] as String?,
      token: json['access_token'] as String? ?? json['token'] as String?,
      refreshToken: json['refresh_token'] as String?,
      user: userData != null ? User.fromMap(userData) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'fullName': fullName,
      'token': token,
      'refreshToken': refreshToken,
      'user': user?.toMap(),
    };
  }

  AuthModel copyWith({
    String? uid,
    String? email,
    String? fullName,
    String? token,
    String? refreshToken,
    User? user,
  }) {
    return AuthModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      token: token ?? this.token,
      refreshToken: refreshToken ?? this.refreshToken,
      user: user ?? this.user,
    );
  }
}
