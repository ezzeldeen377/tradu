import 'package:crypto_app/core/errors/app_exception.dart';
import 'package:crypto_app/core/networking/api_constant.dart';
import 'package:crypto_app/core/networking/http_services.dart';
import 'package:crypto_app/core/services/cache_service.dart';
import 'package:crypto_app/features/auth/data/models/auth_model.dart';
import 'package:crypto_app/features/auth/data/models/app_version_model.dart';
import 'package:injectable/injectable.dart';

@injectable
class AuthRepository {
  final HttpServices httpServices;

  AuthRepository({required this.httpServices});

  /// Login with email and password
  Future<AuthModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await httpServices.post(
        ApiConstant.loginEndPoint,
        body: {'email': email, 'password': password},
      );

      final user = AuthModel.fromJson(response);
      await _saveUser(user);
      return user;
    } on Exception catch (e) {
      throw _handleError(e);
    }
  }

  /// Sign up with full name, email, phone and password
  Future<AuthModel> signUp({
    required String fullName,
    required String email,
    required String phone,
    required String password,
    String? referralCode,
  }) async {
    try {
      final response = await httpServices.post(
        ApiConstant.registerEndPoint,
        body: {
          'name': fullName,
          'email': email,
          'phone': phone,
          'password': password,
          'password_confirmation': password,
          if (referralCode != null && referralCode.isNotEmpty)
            'referral_code': referralCode,
        },
      );

      final user = AuthModel.fromJson(response);
      await _saveUser(user);
      return user;
    } on Exception catch (e) {
      throw _handleError(e);
    }
  }

  /// Send forgot password request
  Future<void> forgotPassword({String? email, String? phone}) async {
    try {
      await httpServices.post(
        ApiConstant.forgotPasswordOtpEndPoint,
        body: {
          if (email != null) 'email': email,
          if (phone != null) 'phone': phone,
        },
      );
    } on Exception catch (e) {
      throw _handleError(e);
    }
  }

  /// Verify account with code and phone
  Future<AuthModel> verifyAccount({
    required String email,
    required String code,
  }) async {
    try {
      final response = await httpServices.post(
        ApiConstant.verifyCodeEndPoint,
        body: {'email': email, 'code': code},
      );

      // Parse user data from verification response
      final user = AuthModel.fromJson(response);

      // Save user and tokens
      await _saveUser(user);

      return user;
    } on Exception catch (e) {
      throw _handleError(e);
    }
  }

  /// Verify account with code and phone
  Future<AuthModel> verifyForgotPasswordOtp({
    required String email,
    required String code,
  }) async {
    try {
      final response = await httpServices.post(
        ApiConstant.verifyForgotPasswordOtpEndPoint,
        body: {'email': email, 'code': code},
      );

      // Parse user data from verification response
      final user = AuthModel.fromJson(response);

      // Save user and tokens
      await _saveUser(user);

      return user;
    } on Exception catch (e) {
      throw _handleError(e);
    }
  }

  /// Reset password with code and new password
  Future<void> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    try {
      await httpServices.post(
        ApiConstant.resetPasswordEndPoint,
        body: {
          'email': email,
          'code': code,
          'password': newPassword,
          'password_confirmation': newPassword,
        },
      );
    } on Exception catch (e) {
      throw _handleError(e);
    }
  }

  /// Get current user data from server
  Future<AuthModel> getCurrentUser() async {
    try {
      final response = await httpServices.get(ApiConstant.meEndPoint);
      final user = AuthModel.fromJson(response);

      // Preserve existing tokens
      final existingToken = await CacheService.getAccessToken();
      final existingRefreshToken = await CacheService.getRefreshToken();

      final updatedUser = user.copyWith(
        token: user.token ?? existingToken,
        refreshToken: user.refreshToken ?? existingRefreshToken,
      );

      return updatedUser;
    } on Exception catch (e) {
      throw _handleError(e);
    }
  }

  /// Refresh access token
  Future<AuthModel> refreshToken() async {
    try {
      final refreshToken = await CacheService.getRefreshToken();
      if (refreshToken == null) {
        throw UnauthorizedException(message: 'No refresh token available');
      }

      final response = await httpServices.post(
        ApiConstant.refreshTokenEndPoint,
        body: {'refresh_token': refreshToken},
      );

      final user = AuthModel.fromJson(response);
      await _saveUser(user);
      return user;
    } on Exception catch (e) {
      throw _handleError(e);
    }
  }

  /// Logout user
  Future<void> logout() async {
    try {
      // Try to logout from server
      try {
        await httpServices.post(ApiConstant.logoutEndPoint);
      } catch (_) {
        // Ignore server errors during logout
      }

      // Clear local data
      await CacheService.clearTokens();
    } on Exception catch (e) {
      throw _handleError(e);
    }
  }

  /// Delete user account
  Future<void> deleteAccount() async {
    try {
      await httpServices.post(ApiConstant.deleteAccountEndPoint);
      await CacheService.clearTokens();
    } catch (_) {
      rethrow;
    }
  }

  /// Get saved user from cache
  Future<bool> getSavedUser() async {
    try {
      final token = await CacheService.getAccessToken();
      if (token == null) return false;

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Get saved token
  Future<String?> getToken() async {
    return await CacheService.getAccessToken();
  }

  /// Check if user is logged in
  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null;
  }

  /// Save user data and tokens
  Future<void> _saveUser(AuthModel user) async {
    if (user.token != null) {
      await CacheService.setAccessToken(user.token!);
    }
    if (user.refreshToken != null) {
      await CacheService.setRefreshToken(user.refreshToken!);
    }
  }

  /// Handle and transform errors
  AppException _handleError(Exception error) {
    final errorMessage = error.toString();

    // Network/timeout errors
    if (errorMessage.contains('timeout') ||
        errorMessage.contains('SocketException') ||
        errorMessage.contains('Failed host lookup')) {
      return NetworkException(
        message: 'Network error. Please check your internet connection.',
        originalError: error,
      );
    }

    // Validation errors (422)
    if (errorMessage.contains('empty values') ||
        errorMessage.contains('Validation') ||
        errorMessage.toLowerCase().contains('validation')) {
      return ValidationException(
        message: _extractErrorMessage(errorMessage),
        originalError: error,
      );
    }

    // Unauthorized errors (401)
    if (errorMessage.contains('Unauthorized') || errorMessage.contains('401')) {
      return UnauthorizedException(
        message: 'Session expired. Please login again.',
        originalError: error,
      );
    }

    // Server errors
    if (errorMessage.contains('500') ||
        errorMessage.contains('Server') ||
        errorMessage.contains('server')) {
      return ServerException(
        message: 'Server error. Please try again later.',
        originalError: error,
      );
    }

    // Generic error
    return AppException(
      message: _extractErrorMessage(errorMessage),
      originalError: error,
    );
  }

  /// Extract clean error message from exception string
  String _extractErrorMessage(String errorMessage) {
    // Remove "Exception: " prefix
    if (errorMessage.startsWith('Exception: ')) {
      errorMessage = errorMessage.substring(11);
    }

    // Return cleaned message
    return errorMessage.isNotEmpty
        ? errorMessage
        : 'An unexpected error occurred. Please try again.';
  }

  /// Get current user data
  Future<AuthModel> getUserData() async {
    try {
      final response = await httpServices.post(ApiConstant.meEndPoint);
      final user = AuthModel.fromJson(response);
      return user;
    } on Exception catch (e) {
      throw _handleError(e);
    }
  }

  /// Update FCM device token
  Future<void> updateFCMToken(String fcmToken) async {
    try {
      await httpServices.post(
        ApiConstant.deviceTokenEndPoint,
        body: {'device_token': fcmToken},
      );
    } on Exception catch (e) {
      throw _handleError(e);
    }
  }

  /// Get app version and currencies
  Future<AppVersionModel> getAppVersion() async {
    try {
      final response = await httpServices.get(ApiConstant.appVersionEndPoint);
      final appVersion = AppVersionModel.fromJson(response);
      return appVersion;
    } on Exception catch (e) {
      throw _handleError(e);
    }
  }
}
