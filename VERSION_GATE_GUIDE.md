# VersionGate Widget - Complete Guide

## Overview

`VersionGate` is a custom widget that wraps your entire app and automatically checks if an update is required. If the server version is higher than the current app version, it shows a **blocking update screen** that prevents users from using the app until they update.

## Features

✅ **Automatic Version Checking** - Checks on app startup
✅ **Blocks App Usage** - Non-dismissible update screen
✅ **Beautiful UI** - Dark theme with smooth animations
✅ **Fully Localized** - English & Arabic support
✅ **Reactive** - Updates when server version changes
✅ **Fail-Safe** - If check fails, app continues normally

## How It Works

```
App Starts
    ↓
VersionGate Wraps App
    ↓
Fetches Current Version (from pubspec.yaml)
    ↓
Compares with Server Version (from AuthState)
    ↓
┌─────────────────────────────────────┐
│  Server > Current?                  │
├─────────────────────────────────────┤
│  YES → Show Update Screen (BLOCK)  │
│  NO  → Show Normal App             │
└─────────────────────────────────────┘
```

## Implementation

### 1. Widget Structure

```dart
VersionGate(
  serverVersion: '1.0.0', // From server API
  child: YourApp(),       // Your entire app
)
```

### 2. Current Integration (main.dart)

```dart
VersionGate(
  serverVersion: authState.appVersion ?? '0.0.0',
  child: ScreenUtilInit(
    // Your app...
  ),
)
```

## Testing

### Scenario 1: Trigger Update Screen

**Current Setup:**
- App Version: `2.0.0` (pubspec.yaml)
- Server Version: `1.0.0` (API)
- Result: ❌ No update screen (app is newer)

**To Test:**

#### Option A: Change App Version (Easiest)
```yaml
# pubspec.yaml
version: 0.9.0+1  # Lower than server
```

Then run:
```bash
flutter clean
flutter pub get
flutter run
```

#### Option B: Change Server Version
Update your API to return:
```json
{
  "version": "3.0.0",
  "currencies": [...]
}
```

### Scenario 2: Test Version Comparison

| App Version | Server Version | Result |
|-------------|----------------|--------|
| 1.0.0       | 1.0.1          | ✅ Update Required |
| 1.0.0       | 1.1.0          | ✅ Update Required |
| 1.0.0       | 2.0.0          | ✅ Update Required |
| 2.0.0       | 1.0.0          | ❌ No Update |
| 1.5.0       | 1.5.0          | ❌ No Update |

## Debug Output

When the app runs, check console for:

```
=== VERSION GATE ===
Current Version: 2.0.0
Server Version: 1.0.0
Needs Update: false
```

## Update Screen Features

### UI Elements

1. **Large Update Icon** - System update icon in a circle
2. **Title** - "Update Available" (localized)
3. **Message** - Explains update is required
4. **Version Comparison Box**:
   - Current Version (grayed out)
   - New Version (highlighted in blue)
5. **Update Button** - Opens app store
6. **Warning Text** - "The app will not continue without updating"

### Behavior

- **Non-Dismissible** - User cannot close or bypass
- **No Back Button** - Cannot navigate away
- **Single Action** - Only "Update Now" button
- **Opens Store** - Launches Google Play/App Store

## Customization

### 1. Change Store URL

Edit `version_gate.dart`:

```dart
Future<void> _launchStore() async {
  const url = 'YOUR_PLAY_STORE_URL';
  // or
  const url = 'YOUR_APP_STORE_URL';
  
  final uri = Uri.parse(url);
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}
```

### 2. Change Colors

```dart
// Background
backgroundColor: const Color(0xFF0F1623),

// Primary Color
color: const Color(0xFF1F68F9),

// Update to your brand colors
```

### 3. Add Platform Detection

```dart
import 'dart:io';

Future<void> _launchStore() async {
  final url = Platform.isIOS
      ? 'https://apps.apple.com/app/idYOUR_ID'
      : 'https://play.google.com/store/apps/details?id=YOUR_PACKAGE';
  
  // Launch URL...
}
```

## Translations

Already added to `en.json` and `ar.json`:

```json
{
  "update": {
    "title": "Update Available",
    "mandatory_message": "A new version of the app is available. Please update to continue.",
    "current_version": "Current Version",
    "new_version": "New Version",
    "update_now": "Update Now"
  }
}
```

## Advanced Usage

### Make Update Optional (Not Recommended)

If you want to allow users to skip:

1. Add a "Later" button
2. Make dialog dismissible
3. Store "skip" preference

**Not recommended** because:
- Users may miss critical updates
- Security vulnerabilities may exist
- API compatibility issues

### Version-Specific Messages

```dart
String _getUpdateMessage() {
  final current = _parseVersion(_currentVersion);
  final server = _parseVersion(_serverVersion);
  
  if (server[0] > current[0]) {
    return 'Major update available with new features!';
  } else if (server[1] > current[1]) {
    return 'New features and improvements available!';
  } else {
    return 'Bug fixes and performance improvements!';
  }
}
```

## Troubleshooting

### Update Screen Not Showing?

1. **Check Debug Output**
   ```
   === VERSION GATE ===
   Current Version: X.X.X
   Server Version: Y.Y.Y
   Needs Update: true/false
   ```

2. **Verify Versions**
   - App: `grep "version:" pubspec.yaml`
   - Server: Check API response

3. **Clear Cache**
   ```bash
   flutter clean
   flutter pub get
   flutter run
   ```

### App Store Not Opening?

1. **Check URL** - Verify store URL is correct
2. **Test URL** - Open in browser first
3. **Check Permissions** - Ensure app can open URLs

### Version Not Updating?

1. **Rebuild App** - `flutter clean && flutter run`
2. **Check pubspec.yaml** - Ensure version changed
3. **Restart App** - Kill and restart completely

## Best Practices

1. **Semantic Versioning** - Use `MAJOR.MINOR.PATCH`
2. **Test Before Release** - Always test update flow
3. **Clear Messages** - Explain why update is needed
4. **Easy Access** - Make store link prominent
5. **Monitor Analytics** - Track update adoption

## Production Checklist

- [ ] Update store URLs with real links
- [ ] Test on both Android and iOS
- [ ] Verify translations in both languages
- [ ] Test with different version combinations
- [ ] Ensure API returns correct version
- [ ] Monitor crash reports
- [ ] Have rollback plan

## Example Flow

```
User Opens App (v1.0.0)
    ↓
VersionGate Checks
    ↓
Server Says: v2.0.0 Available
    ↓
🚫 BLOCKED - Update Screen Shows
    ↓
User Taps "Update Now"
    ↓
Opens Google Play/App Store
    ↓
User Updates to v2.0.0
    ↓
✅ App Works Normally
```

## Notes

- Version check is **automatic** on every app start
- Update screen is **mandatory** - cannot be bypassed
- If version check **fails**, app continues (fail-safe)
- Versions are compared **semantically** (1.0.0 < 1.0.1 < 1.1.0 < 2.0.0)
- Widget is **reactive** - updates when server version changes

## Support

For issues or questions:
1. Check debug console output
2. Verify version comparison logic
3. Test with different version numbers
4. Review translation keys
