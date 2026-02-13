## Fix: Market Stream Not Working After Login

### Problem
After logging in and navigating to the home screen, the live cryptocurrency prices stream was not working. The market data wasn't being fetched or displayed.

### Root Cause
The `HomeCubit` was being created in the `HomeScreen`, but the `startMarketStream()` method was never being called to initiate the WebSocket connection to fetch live prices.

The `MarketListWidget` was attempting to start the stream in its `initState()` using `addPostFrameCallback`, but this had timing issues and wasn't reliable.

### Solution
**Moved stream initialization to `HomeScreen`'s `BlocProvider.create()`**

The fix ensures that:
1. When `HomeCubit` is created, we immediately read currencies from `AuthCubit`
2. If currencies are available, we start the market stream right away
3. This happens before any widgets are built, ensuring data flows immediately

### Changes Made

#### 1. `/lib/features/home/presentation/screens/home_screen.dart`
```dart
BlocProvider(
  create: (context) {
    final homeCubit = HomeCubit(MarketRepository());
    
    // Start market stream immediately with currencies from AuthCubit
    final currencies = context.read<AuthCubit>().state.currencies;
    if (currencies != null && currencies.isNotEmpty) {
      final currencyNames = currencies.map((c) => c.name).toList();
      homeCubit.startMarketStream(currencyNames);
    }
    
    return homeCubit;
  },
  // ... rest of the widget
)
```

#### 2. `/lib/features/home/presentation/widgets/market_list_widget.dart`
- Removed duplicate `initState()` that was trying to start the stream
- Kept only the `dispose()` method to clean up the stream

### How It Works Now

1. **User logs in** → `AuthCubit` fetches and stores currencies
2. **Navigate to HomeScreen** → `HomeCubit` is created
3. **During creation** → Stream starts immediately with currency list
4. **MarketListWidget builds** → Displays loading shimmer
5. **Stream receives data** → UI updates with live prices
6. **User leaves screen** → Stream is properly disposed

### Benefits
✅ Stream starts immediately when screen loads
✅ No timing issues or race conditions
✅ Cleaner code with single source of truth
✅ Proper cleanup on dispose
✅ Live prices update in real-time

### Testing
- Login to the app
- Navigate to home screen
- You should see:
  - Loading shimmer briefly
  - Live cryptocurrency prices appearing
  - Prices updating in real-time
  - Proper error handling if connection fails
