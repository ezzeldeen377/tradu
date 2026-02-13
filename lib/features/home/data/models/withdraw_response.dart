// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:crypto_app/features/auth/data/models/user_model.dart';

class WithdrawResponse {
  final String? message;
  final User? user;

  WithdrawResponse({this.message, this.user});

  WithdrawResponse copyWith({String? message, User? user}) {
    return WithdrawResponse(
      message: message ?? this.message,
      user: user ?? this.user,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{'message': message, 'user': user?.toMap()};
  }

  factory WithdrawResponse.fromMap(Map<String, dynamic> map) {
    return WithdrawResponse(
      message: map['message'] != null ? map['message'] as String : null,
      user: map['user'] != null
          ? User.fromMap(map['user'] as Map<String, dynamic>)
          : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory WithdrawResponse.fromJson(String source) =>
      WithdrawResponse.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'WithdrawResponse(message: $message, user: $user)';

  @override
  bool operator ==(covariant WithdrawResponse other) {
    if (identical(this, other)) return true;

    return other.message == message && other.user == user;
  }

  @override
  int get hashCode => message.hashCode ^ user.hashCode;
}
