import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../data/auth_repository.dart';
import '../../../admin/data/repositories/chat_repository.dart';
import '../../../../core/errors/app_exception.dart';
import 'auth_state.dart';

@injectable
class AuthCubit extends Cubit<AuthState> {
  final AuthRepository repository;
  final ChatRepository chatRepository;

  AuthCubit({required this.repository, required this.chatRepository})
    : super(AuthState());

  /// Fetch app configuration (version and currencies)
  Future<void> fetchAppConfig() async {
    try {
      final appVersionData = await repository.getAppVersion();
      emit(
        state.copyWith(
          appVersion: appVersionData.version,
          currencies: appVersionData.currencies,
        ),
      );
    } on AppException catch (e) {
      emit(state.copyWith(status: AuthStatus.error, errorMessage: e.message));
    } catch (e) {
      emit(
        state.copyWith(
          status: AuthStatus.error,
          errorMessage: _extractErrorMessage(e),
        ),
      );
    }
  }

  Future<void> checkAuthStatus() async {
    try {
      // Fetch app version and currencies first
      await fetchAppConfig();

      final islogin = await repository.getSavedUser();
      if (islogin) {
        await fetchUserData();
      } else {
        emit(state.copyWith(status: AuthStatus.unauthenticated));
      }
    } on AppException catch (e) {
      emit(state.copyWith(status: AuthStatus.error, errorMessage: e.message));
    } catch (e) {
      emit(
        state.copyWith(
          status: AuthStatus.error,
          errorMessage: _extractErrorMessage(e),
        ),
      );
    }
  }

  Future<void> login({required String email, required String password}) async {
    emit(state.copyWith(status: AuthStatus.loading));

    try {
      final user = await repository.login(email: email, password: password);

      // Emit savingToken status to show loading overlay
      emit(state.copyWith(status: AuthStatus.savingToken, user: user));

      // Add a small delay to ensure token is saved
      await Future.delayed(const Duration(milliseconds: 500));

      // Now emit authenticated status
      emit(state.copyWith(status: AuthStatus.authenticated, user: user));
    } on AppException catch (e) {
      print("message: ${e.message}");

      emit(state.copyWith(status: AuthStatus.error, errorMessage: e.message));
    } catch (e) {
      emit(
        state.copyWith(
          status: AuthStatus.error,
          errorMessage: _extractErrorMessage(e),
        ),
      );
    }
  }

  Future<void> signUp({
    required String fullName,
    required String email,
    required String phone,
    required String password,
    String? referralCode,
  }) async {
    emit(state.copyWith(status: AuthStatus.loading));

    try {
      await repository.signUp(
        fullName: fullName,
        email: email,
        phone: phone,
        password: password,
        referralCode: referralCode,
      );

      // After successful signup, user needs to verify OTP
      emit(
        state.copyWith(
          status: AuthStatus.awaitingVerification,
          email: email,
          phone: phone,
        ),
      );
    } on AppException catch (e) {
      emit(state.copyWith(status: AuthStatus.error, errorMessage: e.message));
    } catch (e) {
      emit(
        state.copyWith(
          status: AuthStatus.error,
          errorMessage: _extractErrorMessage(e),
        ),
      );
    }
  }

  Future<void> verifyOtp({required String code}) async {
    emit(state.copyWith(status: AuthStatus.loading));

    try {
      // Verify the OTP code with phone and get user data
      final user = await repository.verifyAccount(
        email: state.email ?? '',
        code: code,
      );

      // User is now authenticated with data from verification response
      emit(
        state.copyWith(
          status: AuthStatus.authenticated,
          user: user,
          phone: null, // Clear phone after successful verification
        ),
      );
    } on AppException catch (e) {
      emit(
        state.copyWith(
          status:
              AuthStatus.awaitingVerification, // Stay on verification screen
          errorMessage: e.message,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status:
              AuthStatus.awaitingVerification, // Stay on verification screen
          errorMessage: _extractErrorMessage(e),
        ),
      );
    }
  }

  Future<void> resendOtp() async {
    if (state.email == null && state.phone == null) return;

    try {
      await repository.forgotPassword(email: state.email, phone: state.phone);
      // Show success message through state if needed
    } on AppException catch (e) {
      emit(state.copyWith(status: AuthStatus.error, errorMessage: e.message));
    } catch (e) {
      emit(
        state.copyWith(
          status: AuthStatus.error,
          errorMessage: _extractErrorMessage(e),
        ),
      );
    }
  }

  Future<void> forgotPassword({required String email}) async {
    emit(state.copyWith(status: AuthStatus.loading));

    try {
      await repository.forgotPassword(email: email);
      emit(
        state.copyWith(status: AuthStatus.forgotPasswordSuccess, email: email),
      );
    } on AppException catch (e) {
      emit(state.copyWith(status: AuthStatus.error, errorMessage: e.message));
    } catch (e) {
      emit(
        state.copyWith(
          status: AuthStatus.error,
          errorMessage: _extractErrorMessage(e),
        ),
      );
    }
  }

  Future<void> verifyForgotPasswordOtp({required String code}) async {
    emit(state.copyWith(status: AuthStatus.loading));

    try {
      // For forgot password, verification usually returns a token or just success
      // If verifyAccount is also used for this, let's use it
      await repository.verifyForgotPasswordOtp(
        email: state.email ?? '',
        code: code,
      );

      // We need to store the code for resetPassword if it's needed
      emit(
        state.copyWith(
          status: AuthStatus.forgotPasswordOtpVerified,
          errorMessage: null,
        ),
      );
      // Wait, if it's successful, we should move to reset password screen
      // Let's use awaitingVerification as a signal to move to next step or define a new one
      // Actually, 'awaitingVerification' is used for signup.
      // Let's just use it and rely on the UI to decide which screen to go to based on current flow
    } on AppException catch (e) {
      emit(state.copyWith(status: AuthStatus.error, errorMessage: e.message));
    } catch (e) {
      emit(
        state.copyWith(
          status: AuthStatus.error,
          errorMessage: _extractErrorMessage(e),
        ),
      );
    }
  }

  Future<void> resetPassword({
    required String code,
    required String newPassword,
  }) async {
    emit(state.copyWith(status: AuthStatus.loading));

    try {
      await repository.resetPassword(
        email: state.email ?? '',
        code: code,
        newPassword: newPassword,
      );
      emit(state.copyWith(status: AuthStatus.resetPasswordSuccess));
    } on AppException catch (e) {
      emit(state.copyWith(status: AuthStatus.error, errorMessage: e.message));
    } catch (e) {
      emit(
        state.copyWith(
          status: AuthStatus.error,
          errorMessage: _extractErrorMessage(e),
        ),
      );
    }
  }

  Future<void> logout() async {
    try {
      await repository.logout();
      // Preserve currencies and app version when logging out
      emit(
        state.copyWith(
          status: AuthStatus.unauthenticated,
          user: null,
          email: null,
          phone: null,
          errorMessage: null,
        ),
      );
    } on AppException catch (e) {
      emit(state.copyWith(status: AuthStatus.error, errorMessage: e.message));
    } catch (e) {
      emit(
        state.copyWith(
          status: AuthStatus.error,
          errorMessage: _extractErrorMessage(e),
        ),
      );
    }
  }

  Future<void> deleteAccount() async {
    try {
      await repository.deleteAccount();
      // Preserve currencies and app version when deleting account
      emit(
        state.copyWith(
          status: AuthStatus.unauthenticated,
          user: null,
          email: null,
          phone: null,
          errorMessage: null,
        ),
      );
    } on AppException catch (e) {
      emit(state.copyWith(status: AuthStatus.error, errorMessage: e.message));
    } catch (e) {
      emit(
        state.copyWith(
          status: AuthStatus.error,
          errorMessage: _extractErrorMessage(e),
        ),
      );
    }
  }

  void clearError() {
    emit(state.copyWith(errorMessage: null));
  }

  /// Extract clean error message from exception
  String _extractErrorMessage(dynamic error) {
    // For other exceptions, convert to string and clean up
    String errorMessage = error.toString();

    // Remove "Exception: " prefix if present
    if (errorMessage.startsWith('Exception: ')) {
      errorMessage = errorMessage.substring(11);
    }

    // Return cleaned message or default
    return errorMessage.isNotEmpty
        ? errorMessage
        : 'An unexpected error occurred. Please try again.';
  }

  /// Fetch current user data from server
  Future<void> fetchUserData() async {
    try {
      final user = await repository.getUserData();
      emit(state.copyWith(user: user, status: AuthStatus.authenticated));
    } on AppException catch (e) {
      emit(state.copyWith(status: AuthStatus.error, errorMessage: e.message));
    } catch (e) {
      emit(
        state.copyWith(
          status: AuthStatus.error,
          errorMessage: _extractErrorMessage(e),
        ),
      );
    }
  }

  /// Update FCM device token
  Future<void> updateFCMToken(String token) async {
    try {
      await repository.updateFCMToken(token);
    } on AppException catch (e) {
      // Silently fail for FCM token update
      debugPrint('FCM Token update failed: ${e.message}');
    } catch (e) {
      // Silently fail for FCM token update
      debugPrint('FCM Token update failed: ${_extractErrorMessage(e)}');
    }
  }

  /// Create or get support chat
  Future<void> createSupportChat() async {
    try {
      final chatsResponse = await chatRepository.getAllChats();
      final supportChat = chatsResponse.chats.firstOrNull;

      emit(
        state.copyWith(
          supportChat: supportChat,
          unreadMessagesCount: supportChat?.unreadMessagesCount ?? 0,
        ),
      );
    } on AppException catch (e) {
      // Silently fail for support chat creation
      print('Support chat creation failed: ${e.message}');
    } catch (e) {
      // Silently fail for support chat creation
      print('Support chat creation failed: ${_extractErrorMessage(e)}');
    }
  }
}
