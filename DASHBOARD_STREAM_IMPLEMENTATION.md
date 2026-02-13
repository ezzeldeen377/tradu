## Market Stream Implementation in Dashboard

### Overview
This document explains how the market stream is now properly initialized and managed in the DashboardScreen to display live cryptocurrency prices.

### Architecture

```
DashboardScreen (StatefulWidget)
  └─> _buildScreens(context) method
      └─> Creates BlocProvider<HomeCubit>
          └─> Initializes HomeCubit with MarketRepository
          └─> Starts market stream with currencies from AuthCubit
          └─> Returns HomeScreen as child
```

### Implementation Details

#### 1. **DashboardScreen** (`dashboard_screen.dart`)

The `DashboardScreen` now uses a `_buildScreens()` method that:
- Creates a new `HomeCubit` instance for the home screen
- Reads currencies from `AuthCubit.state.currencies`
- Calls `homeCubit.startMarketStream(currencyNames)` to initiate the WebSocket connection
- Wraps `HomeScreen` in a `BlocProvider` to provide the cubit

```dart
List<Widget> _buildScreens(BuildContext context) {
  return [
    BlocProvider(
      create: (context) {
        final homeCubit = HomeCubit(MarketRepository());
        
        // Get currencies from AuthCubit
        final currencies = context.read<AuthCubit>().state.currencies;
        
        // Start market stream if currencies are available
        if (currencies != null && currencies.isNotEmpty) {
          final currencyNames = currencies.map((c) => c.name).toList();
          homeCubit.startMarketStream(currencyNames);
        }
        
        return homeCubit;
      },
      child: const HomeScreen(),
    ),
    // ... other screens
  ];
}

@override
Widget build(BuildContext context) {
  final screens = _buildScreens(context);
  return Scaffold(
    body: screens[_currentIndex],
    // ... navigation
  );
}
```

#### 2. **HomeScreen** (`home_screen.dart`)

The `HomeScreen` is now a simple `StatelessWidget` that:
- No longer creates its own `BlocProvider`
- Relies on the parent (DashboardScreen) to provide `HomeCubit`
- Simply displays the UI and reacts to state changes

```dart
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const HomeHeaderWidget(),
            // ... UI components
            const MarketListWidget(), // Uses HomeCubit from parent
          ],
        ),
      ),
    );
  }
}
```

#### 3. **MarketListWidget** (`market_list_widget.dart`)

The `MarketListWidget`:
- No longer starts the stream in `initState()`
- Only handles cleanup in `dispose()`
- Uses `BlocBuilder<HomeCubit, HomeState>` to react to stream data

```dart
class _MarketListWidgetState extends State<MarketListWidget> {
  @override
  void dispose() {
    // Stop market stream when widget disposes
    context.read<HomeCubit>().stopMarketStream();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        // Display loading, error, or success states
      },
    );
  }
}
```

### Data Flow

1. **App Startup** (`main.dart`):
   ```dart
   BlocProvider(
     create: (context) => AuthCubit()
       ..checkAuthStatus()
       ..fetchAppConfig(), // Fetches currencies
   )
   ```

2. **Login & Navigate to Dashboard**:
   - User logs in
   - Navigates to `DashboardScreen`
   - `_buildScreens()` is called

3. **Stream Initialization**:
   - `HomeCubit` is created
   - Currencies are read from `AuthCubit`
   - `startMarketStream(currencies)` is called
   - WebSocket connection established

4. **Data Updates**:
   - WebSocket receives price updates
   - `HomeCubit` emits new states
   - `MarketListWidget` rebuilds with new data
   - UI shows live prices

5. **Cleanup**:
   - User navigates away from home screen
   - `MarketListWidget.dispose()` calls `stopMarketStream()`
   - WebSocket connection closed

### Key Benefits

✅ **Single Source of Truth**: Stream is started once in DashboardScreen  
✅ **Proper Lifecycle**: Stream starts when screen loads, stops when disposed  
✅ **No Timing Issues**: Currencies are guaranteed to be loaded before stream starts  
✅ **Clean Separation**: Each widget has a single responsibility  
✅ **Reusable**: HomeScreen can be used standalone if needed (with BlocProvider)  

### Troubleshooting

#### Stream Not Starting
- **Check**: Are currencies loaded in `AuthCubit`?
- **Solution**: Ensure `fetchAppConfig()` is called in `main.dart`

#### No Data Displayed
- **Check**: Is `startMarketStream()` being called?
- **Solution**: Add debug prints in `_buildScreens()` to verify

#### Stream Not Stopping
- **Check**: Is `dispose()` being called in `MarketListWidget`?
- **Solution**: Verify widget lifecycle

### Testing Checklist

- [ ] Login to app
- [ ] Navigate to Dashboard
- [ ] Verify home screen loads
- [ ] Check that shimmer loading appears briefly
- [ ] Confirm live prices are displayed
- [ ] Verify prices update in real-time
- [ ] Navigate to another tab
- [ ] Return to home tab
- [ ] Verify stream restarts correctly
- [ ] Check for memory leaks (stream properly disposed)

### Files Modified

1. `/lib/features/dashboard/presentation/screens/dashboard_screen.dart`
   - Added `_buildScreens()` method
   - Moved `HomeCubit` creation here
   - Start market stream on cubit creation

2. `/lib/features/home/presentation/screens/home_screen.dart`
   - Removed `BlocProvider`
   - Removed unused imports
   - Now a simple StatelessWidget

3. `/lib/features/home/presentation/widgets/market_list_widget.dart`
   - Removed `initState()` stream initialization
   - Kept only `dispose()` for cleanup

4. `/lib/main.dart`
   - Added `fetchAppConfig()` call on `AuthCubit` initialization
