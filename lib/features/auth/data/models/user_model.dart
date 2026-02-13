import 'dart:convert';

class User {
  final int? id;
  final String? name;
  final String? email;
  final String? emailVerifiedAt;
  final String? password;
  final String? phone;
  final int? balance;
  final int? profit;
  final String? verificationCode;
  final bool? isVerified;
  final String? rememberToken;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? role;
  final String? userIdentifier;
  final bool? giftRedeemed;
  final int? isBannedChat; // 0 = not banned, 1 = banned
  final String? deviceId;
  final String? referralCode;
  final int? referredBy;

  User({
    this.id,
    this.name,
    this.email,
    this.emailVerifiedAt,
    this.password,
    this.phone,
    this.balance,
    this.profit,
    this.verificationCode,
    this.isVerified,
    this.rememberToken,
    this.createdAt,
    this.updatedAt,
    this.role,
    this.userIdentifier,
    this.giftRedeemed,
    this.isBannedChat,
    this.deviceId,
    this.referralCode,
    this.referredBy,
  });

  User copyWith({
    int? id,
    String? name,
    String? email,
    String? emailVerifiedAt,
    String? password,
    String? phone,
    int? balance,
    int? profit,
    String? verificationCode,
    bool? isVerified,
    String? rememberToken,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? role,
    String? userIdentifier,
    bool? giftRedeemed,
    int? isBannedChat,
    String? deviceId,
    String? referralCode,
    int? referredBy,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      emailVerifiedAt: emailVerifiedAt ?? this.emailVerifiedAt,
      password: password ?? this.password,
      phone: phone ?? this.phone,
      balance: balance ?? this.balance,
      profit: profit ?? this.profit,
      verificationCode: verificationCode ?? this.verificationCode,
      isVerified: isVerified ?? this.isVerified,
      rememberToken: rememberToken ?? this.rememberToken,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      role: role ?? this.role,
      userIdentifier: userIdentifier ?? this.userIdentifier,
      giftRedeemed: giftRedeemed ?? this.giftRedeemed,
      isBannedChat: isBannedChat ?? this.isBannedChat,
      deviceId: deviceId ?? this.deviceId,
      referralCode: referralCode ?? this.referralCode,
      referredBy: referredBy ?? this.referredBy,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'email': email,
      'email_verified_at': emailVerifiedAt,
      'password': password,
      'phone': phone,
      'balance': balance,
      'profit': profit,
      'verification_code': verificationCode,
      'is_verified': isVerified,
      'remember_token': rememberToken,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'role': role,
      'user_identifier': userIdentifier,
      'gift_redeemed': giftRedeemed,
      'is_banned_chat': isBannedChat,
      'device_id': deviceId,
      'referral_code': referralCode,
      'referred_by': referredBy,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] != null ? map['id'] as int : null,
      name: map['name'] != null ? map['name'] as String : null,
      email: map['email'] != null ? map['email'] as String : null,
      emailVerifiedAt: map['email_verified_at'] as String?,
      password: map['password'] != null ? map['password'] as String : null,
      phone: map['phone'] != null ? map['phone'] as String : null,
      balance: map['balance'] != null ? map['balance'] as int : null,
      profit: map['profit'] != null ? map['profit'] as int : null,
      verificationCode: map['verification_code'] as String?,
      isVerified: map['is_verified'] != null ? (map['is_verified'] == 1) : null,
      rememberToken: map['remember_token'] as String?,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'])
          : null,
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'])
          : null,
      role: map['role'] != null ? map['role'] as String : null,
      userIdentifier: map['user_identifier'] != null
          ? map['user_identifier'] as String
          : null,
      giftRedeemed: map['gift_redeemed'] != null
          ? (map['gift_redeemed'] == 1 || map['gift_redeemed'] == true)
          : false,
      isBannedChat: map['is_banned_chat'] != null
          ? map['is_banned_chat'] as int
          : 0,
      deviceId: map['device_id'] != null ? map['device_id'] as String : null,
      referralCode: map['referral_code'] as String?,
      referredBy: map['referred_by'] as int?,
    );
  }

  @override
  bool operator ==(covariant User other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.name == name &&
        other.email == email &&
        other.emailVerifiedAt == emailVerifiedAt &&
        other.password == password &&
        other.phone == phone &&
        other.balance == balance &&
        other.profit == profit &&
        other.verificationCode == verificationCode &&
        other.isVerified == isVerified &&
        other.rememberToken == rememberToken &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        other.role == role &&
        other.userIdentifier == userIdentifier &&
        other.giftRedeemed == giftRedeemed &&
        other.isBannedChat == isBannedChat &&
        other.deviceId == deviceId &&
        other.referralCode == referralCode &&
        other.referredBy == referredBy;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        email.hashCode ^
        emailVerifiedAt.hashCode ^
        password.hashCode ^
        phone.hashCode ^
        balance.hashCode ^
        profit.hashCode ^
        verificationCode.hashCode ^
        isVerified.hashCode ^
        rememberToken.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode ^
        role.hashCode ^
        userIdentifier.hashCode ^
        giftRedeemed.hashCode ^
        isBannedChat.hashCode ^
        deviceId.hashCode ^
        referralCode.hashCode ^
        referredBy.hashCode;
  }

  String toJson() => json.encode(toMap());

  factory User.fromJson(String source) =>
      User.fromMap(json.decode(source) as Map<String, dynamic>);
}
