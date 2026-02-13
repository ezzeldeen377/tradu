import 'package:crypto_app/features/auth/data/models/auth_model.dart';
import 'package:crypto_app/features/auth/data/models/currency_model.dart';
import 'package:crypto_app/features/admin/data/models/chat_model.dart';

enum AuthStatus {
  initial,
  loading,
  savingToken,
  authenticated,
  unauthenticated,
  awaitingVerification,
  forgotPasswordSuccess,
  forgotPasswordOtpVerified,
  resetPasswordSuccess,
  error,
}

class AuthState {
  final AuthStatus status;
  final AuthModel? user;
  final String? errorMessage;
  final String? phone;
  final String? email; // Store email for verification
  final String? appVersion;
  final List<CurrencyModel>? currencies;
  final Chat? supportChat;
  final int? unreadMessagesCount;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.errorMessage,
    this.phone,
    this.email,
    this.appVersion,
    this.currencies,
    this.supportChat,
    this.unreadMessagesCount,
  });

  AuthState copyWith({
    AuthStatus? status,
    AuthModel? user,
    String? errorMessage,
    String? phone,
    String? email,
    String? appVersion,
    List<CurrencyModel>? currencies,
    Chat? supportChat,
    int? unreadMessagesCount,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      appVersion: appVersion ?? this.appVersion,
      currencies: currencies ?? this.currencies,
      supportChat: supportChat ?? this.supportChat,
      unreadMessagesCount: unreadMessagesCount ?? this.unreadMessagesCount,
    );
  }

  bool get isAuthenticated => status == AuthStatus.authenticated;
  bool get isLoading => status == AuthStatus.loading;
  bool get isSavingToken => status == AuthStatus.savingToken;
  bool get isAwaitingVerification => status == AuthStatus.awaitingVerification;
}
