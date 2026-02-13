## Refactoring: Separated App Config Fetching

### What Changed
Created a new `fetchAppConfig()` method in `AuthCubit` to separate the concerns of fetching app version and currencies from the authentication status check.

### Before
```dart
Future<void> checkAuthStatus() async {
  try {
    // Fetch app version and currencies first
    final appVersionData = await _repository.getAppVersion();

    final islogin = await _repository.getSavedUser();
    if (islogin) {
      emit(state.copyWith(
        status: AuthStatus.authenticated,
        appVersion: appVersionData.version,
        currencies: appVersionData.currencies,
      ));
    } else {
      emit(state.copyWith(
        status: AuthStatus.unauthenticated,
        appVersion: appVersionData.version,
        currencies: appVersionData.currencies,
      ));
    }
  } catch (e) {
    // error handling
  }
}
```

### After
```dart
/// Fetch app configuration (version and currencies)
Future<void> fetchAppConfig() async {
  try {
    final appVersionData = await _repository.getAppVersion();
    emit(state.copyWith(
      appVersion: appVersionData.version,
      currencies: appVersionData.currencies,
    ));
  } catch (e) {
    // error handling
  }
}

Future<void> checkAuthStatus() async {
  try {
    // Fetch app version and currencies first
    await fetchAppConfig();

    final islogin = await _repository.getSavedUser();
    if (islogin) {
      emit(state.copyWith(status: AuthStatus.authenticated));
    } else {
      emit(state.copyWith(status: AuthStatus.unauthenticated));
    }
  } catch (e) {
    // error handling
  }
}
```

### Benefits

1. **Separation of Concerns**: App config fetching is now a separate, reusable method
2. **Reusability**: Can call `fetchAppConfig()` independently when needed
3. **Cleaner Code**: `checkAuthStatus()` is now more focused on authentication
4. **Better Maintainability**: Easier to update app config logic in one place
5. **Flexibility**: Can refresh currencies without checking auth status

### Usage

#### Fetch app config independently:
```dart
context.read<AuthCubit>().fetchAppConfig();
```

#### Check auth status (includes app config):
```dart
context.read<AuthCubit>().checkAuthStatus();
```

#### In DashboardScreen:
```dart
@override
void initState() {
  super.initState();
  WidgetsBinding.instance.addPostFrameCallback((_) {
    context.read<AuthCubit>().fetchUserData();
    context.read<AuthCubit>().updateFCMToken();
    context.read<AuthCubit>().checkAuthStatus(); // Fetches config + checks auth
  });
}
```

### When to Use Each Method

- **`fetchAppConfig()`**: When you only need to refresh currencies/version
- **`checkAuthStatus()`**: On app startup or when checking authentication state
- **`fetchUserData()`**: After login or when user data needs refreshing
- **`updateFCMToken()`**: After login or when FCM token changes

### Files Modified
- `/lib/features/auth/presentation/cubit/auth_cubit.dart`
  - Added `fetchAppConfig()` method
  - Refactored `checkAuthStatus()` to use `fetchAppConfig()`
  - Removed unused `package_info_plus` import
