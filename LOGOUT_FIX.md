## Fix: Logout Preserving App Configuration

### Problem
When logging out, the `AuthCubit` was emitting a completely new `AuthState` instance with only the `status` field set. This caused:
- `currencies` to become `null`
- `appVersion` to become `null`
- `DashboardScreen` to show infinite loading or crash
- Market stream unable to initialize on next login

### Root Cause
```dart
// BEFORE (problematic)
Future<void> logout() async {
  try {
    await _repository.logout();
    emit(const AuthState(status: AuthStatus.unauthenticated)); // ❌ Loses all data
  }
}
```

This created a brand new `AuthState` with all fields set to their default values (null), losing the currencies and app version that were fetched at app startup.

### Solution
Preserve the app configuration (currencies and appVersion) while clearing only user-specific data:

```dart
// AFTER (fixed)
Future<void> logout() async {
  try {
    await _repository.logout();
    // Preserve currencies and app version when logging out
    emit(
      state.copyWith(
        status: AuthStatus.unauthenticated,
        user: null,           // Clear user data
        email: null,          // Clear email
        phone: null,          // Clear phone
        errorMessage: null,   // Clear errors
        // currencies and appVersion are preserved automatically
      ),
    );
  }
}
```

### What Gets Preserved
✅ `currencies` - List of available cryptocurrencies  
✅ `appVersion` - Current app version from server  

### What Gets Cleared
❌ `user` - User authentication data  
❌ `email` - User email  
❌ `phone` - User phone  
❌ `errorMessage` - Any previous errors  

### Benefits

1. **No More Null Currencies**: Currencies remain available after logout
2. **Faster Re-login**: No need to fetch currencies again
3. **Better UX**: Dashboard doesn't show loading spinner after logout
4. **Market Stream Works**: Stream can initialize immediately on next login
5. **Consistent State**: App configuration persists across auth state changes

### Files Modified

1. `/lib/features/auth/presentation/cubit/auth_cubit.dart`
   - Updated `logout()` method to use `state.copyWith()`
   - Updated `deleteAccount()` method to use `state.copyWith()`
   - Both methods now preserve currencies and appVersion

### Testing Checklist

- [ ] Login to the app
- [ ] Navigate to Dashboard
- [ ] Verify market data loads
- [ ] Logout from the app
- [ ] Verify no errors occur
- [ ] Verify currencies are still available
- [ ] Login again
- [ ] Verify market stream starts immediately
- [ ] Verify no loading spinner on dashboard

### Why This Approach?

**Alternative 1**: Fetch currencies again after logout
- ❌ Extra API call
- ❌ Slower
- ❌ Unnecessary network usage

**Alternative 2**: Check for null currencies everywhere
- ❌ Defensive programming everywhere
- ❌ More complex code
- ❌ Easy to miss edge cases

**Our Approach**: Preserve app config on logout
- ✅ Simple and clean
- ✅ No extra API calls
- ✅ Consistent state management
- ✅ Better performance

### State Lifecycle

```
App Start
  ↓
fetchAppConfig() → currencies loaded
  ↓
checkAuthStatus() → check if logged in
  ↓
Login → user data added (currencies preserved)
  ↓
Use App → all data available
  ↓
Logout → user data cleared (currencies preserved) ✅
  ↓
Login Again → user data added (currencies still there) ✅
```

### Important Notes

- Currencies are fetched once at app startup
- They persist across login/logout cycles
- Only cleared when app is completely restarted
- This is the expected behavior for app-level configuration
