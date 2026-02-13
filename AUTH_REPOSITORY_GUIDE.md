# Auth Repository Implementation Guide

## Overview
The AuthRepository has been fully implemented with proper API integration, comprehensive error handling, and token management.

## Architecture

### 1. **Error Handling System**
Located in `/lib/core/errors/app_exception.dart`

Custom exception classes for different error types:
- `AppException` - Base exception class
- `NetworkException` - Network/connectivity errors
- `ValidationException` - Validation errors (422)
- `UnauthorizedException` - Authentication errors (401)
- `ServerException` - Server errors (500+)

### 2. **AuthModel**
Enhanced to handle various API response formats:
- Supports nested user objects
- Handles both `access_token` and `token` fields
- Includes refresh token support
- Flexible field mapping (id/uid, name/fullName)

### 3. **AuthRepository**
Full implementation with all auth endpoints:

#### Methods:

**Authentication:**
- `login({email, password})` - User login
- `signUp({fullName, email, password})` - User registration
- `logout()` - Logout and clear tokens
- `deleteAccount()` - Delete user account

**Password Management:**
- `forgotPassword({email})` - Request password reset
- `verifyAccount({code})` - Verify account with code
- `resetPassword({code, newPassword})` - Reset password

**Token Management:**
- `getCurrentUser()` - Fetch current user from server
- `refreshToken()` - Refresh access token
- `getToken()` - Get saved access token
- `isLoggedIn()` - Check login status

**Cache Management:**
- `getSavedUser()` - Get user from cache (with server validation)

## Error Handling Strategy

### 1. **Error Detection**
The repository automatically detects and categorizes errors:

```dart
try {
  final user = await authRepository.login(email: email, password: password);
} on NetworkException catch (e) {
  // Handle network errors
  print('Network error: ${e.message}');
} on ValidationException catch (e) {
  // Handle validation errors
  print('Validation error: ${e.message}');
} on UnauthorizedException catch (e) {
  // Handle auth errors
  print('Auth error: ${e.message}');
} on ServerException catch (e) {
  // Handle server errors
  print('Server error: ${e.message}');
} on AppException catch (e) {
  // Handle other errors
  print('Error: ${e.message}');
}
```

### 2. **Error Messages**
Clean, user-friendly error messages:
- Network errors: "Network error. Please check your internet connection."
- Validation errors: Extracted from API response
- Unauthorized: "Session expired. Please login again."
- Server errors: "Server error. Please try again later."

### 3. **Error Transformation**
The `_handleError()` method transforms raw exceptions into typed exceptions:
- Checks error message patterns
- Extracts clean error messages
- Preserves original error for debugging

## Token Management

### Automatic Token Handling:
1. **On Login/Signup:**
   - Access token saved to `CacheService`
   - Refresh token saved to `CacheService`
   - User data cached

2. **On API Calls:**
   - Token automatically included in headers
   - HttpServices handles token injection

3. **On Logout:**
   - Server logout called (errors ignored)
   - All local data cleared via `CacheService.clearAll()`

4. **Token Refresh:**
   - Uses refresh token to get new access token
   - Updates cached tokens automatically

## Usage Examples

### Login
```dart
final authRepository = AuthRepository();

try {
  final user = await authRepository.login(
    email: 'user@example.com',
    password: 'password123',
  );
  print('Logged in: ${user.fullName}');
} on ValidationException catch (e) {
  // Show validation error to user
  showError(e.message);
} on NetworkException catch (e) {
  // Show network error
  showError(e.message);
}
```

### Sign Up
```dart
try {
  final user = await authRepository.signUp(
    fullName: 'John Doe',
    email: 'john@example.com',
    password: 'password123',
  );
  print('Account created: ${user.email}');
} on ValidationException catch (e) {
  showError(e.message);
}
```

### Check Auth Status
```dart
final isLoggedIn = await authRepository.isLoggedIn();
if (isLoggedIn) {
  final user = await authRepository.getSavedUser();
  if (user != null) {
    // User is authenticated
    navigateToDashboard();
  } else {
    // Token exists but invalid
    navigateToLogin();
  }
}
```

### Logout
```dart
try {
  await authRepository.logout();
  navigateToLogin();
} catch (e) {
  // Logout errors are rare, but handle if needed
  print('Logout error: $e');
}
```

## Integration with Cubit

In your AuthCubit, use the repository like this:

```dart
Future<void> login(String email, String password) async {
  emit(state.copyWith(status: AuthStatus.loading));
  
  try {
    final user = await _authRepository.login(
      email: email,
      password: password,
    );
    
    emit(state.copyWith(
      status: AuthStatus.authenticated,
      user: user,
      errorMessage: null,
    ));
  } on ValidationException catch (e) {
    emit(state.copyWith(
      status: AuthStatus.failure,
      errorMessage: e.message,
    ));
  } on NetworkException catch (e) {
    emit(state.copyWith(
      status: AuthStatus.failure,
      errorMessage: e.message,
    ));
  } on AppException catch (e) {
    emit(state.copyWith(
      status: AuthStatus.failure,
      errorMessage: e.message,
    ));
  }
}
```

## API Endpoints Used

All endpoints are defined in `ApiConstant`:
- `loginEndPoint` - POST /api/auth/login
- `registerEndPoint` - POST /api/auth/register
- `meEndPoint` - GET /api/auth/me
- `logoutEndPoint` - POST /api/auth/logout
- `verifyCodeEndPoint` - POST /api/auth/verifyCode
- `resendVerificationCodeEndPoint` - POST /api/auth/resendVerificationCode
- `refreshTokenEndPoint` - POST /api/auth/refresh
- `deleteAccountEndPoint` - POST /api/auth/delete
- `resetPasswordEndPoint` - POST /api/auth/resetPassword

## Best Practices

1. **Always catch specific exceptions** in your Cubit/UI layer
2. **Show user-friendly error messages** from exception.message
3. **Log original errors** for debugging: exception.originalError
4. **Handle network errors gracefully** with retry options
5. **Clear tokens on 401 errors** to force re-login
6. **Validate user input** before calling repository methods

## Testing

To test error handling:
1. Turn off internet → NetworkException
2. Send invalid data → ValidationException
3. Use expired token → UnauthorizedException
4. Test with invalid API URL → ServerException

## Notes

- The repository uses HttpServices for all API calls
- All tokens are stored securely via CacheService (flutter_secure_storage)
- Error messages are extracted and cleaned for user display
- The repository follows clean architecture principles
- No business logic in repository - only data operations
