# OTP Verification Flow Implementation

## Overview
Implemented a complete OTP verification flow after user signup. Users must verify their account via OTP before being logged in.

## Flow Diagram

```
User Signs Up
     ↓
API Creates Account
     ↓
Status: awaitingVerification
     ↓
Navigate to Verify Account Screen
     ↓
User Enters OTP Code
     ↓
Verify OTP with API
     ↓
If Valid: Login User → Dashboard
If Invalid: Show Error, Stay on Verification
```

## Changes Made

### 1. **AuthState** (`auth_state.dart`)

**Added:**
- ✅ `awaitingVerification` status to `AuthStatus` enum
- ✅ `email` field to store user's email during verification
- ✅ `isAwaitingVerification` getter

**Purpose:** Track verification state and store email for OTP resend

### 2. **AuthCubit** (`auth_cubit.dart`)

**Updated `signUp()` method:**
- Now emits `awaitingVerification` status after successful signup
- Stores user's email in state for verification

**Added `verifyOtp()` method:**
```dart
Future<void> verifyOtp({required String code}) async {
  // 1. Verify OTP code with API
  await _repository.verifyAccount(code: code);
  
  // 2. Get user data from server
  final user = await _repository.getCurrentUser();
  
  // 3. Login user (emit authenticated status)
  emit(state.copyWith(
    status: AuthStatus.authenticated,
    user: user,
  ));
}
```

**Added `resendOtp()` method:**
- Resends OTP to user's email
- Uses stored email from state

**Cleaned up `login()` method:**
- Removed dead code (null check)

### 3. **SignUpScreen** (`signup_screen.dart`)

**Updated BlocConsumer listener:**
```dart
if (state.status == AuthStatus.awaitingVerification) {
  // Navigate to OTP verification screen
  context.push(AppRoutes.verifyAccount);
}
```

### 4. **VerifyAccountScreen** (`verify_account_screen.dart`)

**Completely refactored:**
- ✅ Integrated with `AuthCubit`
- ✅ Displays masked email from state (e.g., `jo***@gmail.com`)
- ✅ Captures 6-digit OTP code
- ✅ Calls `verifyOtp()` when user submits
- ✅ Shows loading state during verification
- ✅ Navigates to dashboard on success
- ✅ Shows error message on failure
- ✅ Resend OTP functionality
- ✅ Disable verify button until 6 digits entered

### 5. **VerificationCodeWidget** (`verification_code_widget.dart`)

**Enhanced:**
- ✅ Added `onChanged` callback to notify parent of code changes
- ✅ Configurable length (default: 6 digits)
- ✅ Auto-focus next field on input
- ✅ Auto-focus previous field on delete
- ✅ Returns complete code string

## API Integration

### Endpoints Used:

1. **Sign Up:** `POST /api/auth/register`
   - Creates account
   - Sends OTP to email
   - Returns user data (but not logged in yet)

2. **Verify OTP:** `POST /api/auth/verifyCode`
   - Body: `{ "code": "123456" }`
   - Verifies the OTP code

3. **Get Current User:** `GET /api/auth/me`
   - Gets authenticated user data
   - Called after successful verification

4. **Resend OTP:** `POST /api/auth/resendVerificationCode`
   - Body: `{ "email": "user@example.com" }`
   - Sends new OTP code

## User Experience Flow

### 1. **Signup**
```
User fills form → Clicks Sign Up
     ↓
Loading state shown
     ↓
Account created successfully
     ↓
Navigate to Verify Account Screen
```

### 2. **Verification**
```
User sees masked email (jo***@gmail.com)
     ↓
Enters 6-digit OTP code
     ↓
Verify button enabled when 6 digits entered
     ↓
Clicks Verify Now
     ↓
Loading state shown
     ↓
If valid: Navigate to Dashboard (logged in)
If invalid: Show error, stay on screen
```

### 3. **Resend OTP**
```
User clicks "Didn't receive code?"
     ↓
New OTP sent to email
     ↓
Success message shown
```

## Error Handling

### Verification Errors:
- **Invalid Code:** Shows error, stays on verification screen
- **Network Error:** Shows network error message
- **Server Error:** Shows server error message

### State Management:
- On error during verification, status returns to `awaitingVerification`
- User can retry without leaving the screen
- Email is preserved in state for resend functionality

## Features

### ✅ **Email Masking**
```dart
String _maskEmail(String email) {
  // "john@gmail.com" → "jo***@gmail.com"
  // "a@test.com" → "a***@test.com"
}
```

### ✅ **Auto-focus OTP Fields**
- Automatically moves to next field on input
- Automatically moves to previous field on delete
- Smooth user experience

### ✅ **Button States**
- Verify button disabled until 6 digits entered
- Loading state during verification
- Prevents multiple submissions

### ✅ **Resend OTP**
- Uses email from state
- Shows success message
- Disabled during loading

## Testing the Flow

### 1. **Sign Up**
```dart
// Fill signup form
fullName: "John Doe"
email: "john@example.com"
phone: "+201234567890"
password: "password123"

// Click Sign Up
// Should navigate to Verify Account Screen
```

### 2. **Verify OTP**
```dart
// Enter 6-digit code from email
// Click Verify Now
// Should navigate to Dashboard if valid
// Should show error if invalid
```

### 3. **Resend OTP**
```dart
// Click "Didn't receive code?"
// New OTP sent to john@example.com
// Success message shown
```

## Code Examples

### Using in UI:
```dart
// In any screen, check verification status
BlocBuilder<AuthCubit, AuthState>(
  builder: (context, state) {
    if (state.isAwaitingVerification) {
      return Text('Please verify your email: ${state.email}');
    }
    return SomeOtherWidget();
  },
)
```

### Programmatic verification:
```dart
// Verify OTP
context.read<AuthCubit>().verifyOtp(code: '123456');

// Resend OTP
context.read<AuthCubit>().resendOtp();
```

## Benefits

1. **Security:** Users must verify email before accessing app
2. **Clean Flow:** Clear separation between signup and verification
3. **User-Friendly:** Masked email, auto-focus, clear error messages
4. **Robust:** Proper error handling and state management
5. **Reusable:** Can be used for forgot password flow too

## Notes

- OTP code is 6 digits (configurable in `VerificationCodeWidget`)
- Email is stored in state during verification process
- Email is cleared after successful verification
- User can go back from verification screen (won't be logged in)
- Resend OTP uses the same endpoint as forgot password

## Future Enhancements

- Add countdown timer for resend OTP (e.g., "Resend in 00:30")
- Add auto-submit when 6 digits are entered
- Add paste functionality for OTP codes
- Add biometric verification option
- Store verification status in cache
