# Localization & Theme System Documentation

## 📚 Overview

This document explains the localization and theme system implemented in the Crypto App.

## 🌍 Localization

### Setup

The app uses **easy_localization** package for internationalization (i18n).

**Supported Languages:**
- English (en)
- Arabic (ar)

### Translation Files

Translation files are located in `assets/translations/`:
- `en.json` - English translations
- `ar.json` - Arabic translations

### Usage

```dart
import 'package:easy_localization/easy_localization.dart';

// Simple translation
Text('onboarding.skip'.tr())

// With parameters
Text('welcome_message'.tr(args: ['John']))
```

### Changing Language

```dart
// Change to Arabic
context.setLocale(const Locale('ar'));

// Change to English
context.setLocale(const Locale('en'));

// Get current locale
Locale currentLocale = context.locale;
```

## 🎨 Theme System

### AppColors

Centralized color management in `lib/core/theme/app_colors.dart`

**Available Colors:**

```dart
// Primary Colors
AppColors.primary          // #4E7FFF
AppColors.primaryDark      // #3A5FCC

// Background Colors
AppColors.background       // #0A0E27
AppColors.surface          // #1E2442
AppColors.surfaceLight     // #2A3150

// Text Colors
AppColors.textPrimary      // White
AppColors.textSecondary    // #9CA3AF
AppColors.textTertiary     // #6B7280

// Status Colors
AppColors.success          // #10B981
AppColors.error            // #EF4444
AppColors.warning          // #F59E0B
AppColors.info             // #3B82F6

// Accent Colors
AppColors.accent           // #8B5CF6
AppColors.accentLight      // #A78BFA
```

**Helper Methods:**

```dart
// With opacity
AppColors.textPrimaryWithOpacity(0.6)
AppColors.textSecondaryWithOpacity(0.5)
```

### AppTextStyles

Responsive text styles using ScreenUtil in `lib/core/theme/app_text_styles.dart`

**Available Styles:**

```dart
// Headings
AppTextStyles.h1           // 32sp, Bold
AppTextStyles.h2           // 28sp, Bold
AppTextStyles.h3           // 24sp, Bold
AppTextStyles.h4           // 20sp, SemiBold

// Body Text
AppTextStyles.bodyLarge    // 16sp
AppTextStyles.bodyMedium   // 14sp
AppTextStyles.bodySmall    // 12sp

// Button Text
AppTextStyles.button       // 16sp, SemiBold
AppTextStyles.buttonSmall  // 14sp, SemiBold

// Caption
AppTextStyles.caption      // 12sp
AppTextStyles.captionBold  // 12sp, SemiBold
```

**Helper Methods:**

```dart
// Change color
AppTextStyles.withColor(AppTextStyles.h2, AppColors.primary)

// Change opacity
AppTextStyles.withOpacity(AppTextStyles.bodyMedium, 0.6)
```

## 📏 Responsive Sizing (AppSpacing)

Using **flutter_screenutil** for responsive sizing in `lib/core/utils/app_spacing.dart`

### Vertical Spacing

```dart
AppSpacing.xs      // 4.h
AppSpacing.sm      // 8.h
AppSpacing.md      // 16.h
AppSpacing.lg      // 24.h
AppSpacing.xl      // 32.h
AppSpacing.xxl     // 48.h
AppSpacing.xxxl    // 64.h
```

### Horizontal Spacing

```dart
AppSpacing.xsW     // 4.w
AppSpacing.smW     // 8.w
AppSpacing.mdW     // 16.w
AppSpacing.lgW     // 24.w
AppSpacing.xlW     // 32.w
AppSpacing.xxlW    // 48.w
AppSpacing.xxxlW   // 64.w
```

### Custom Sizing

```dart
// Custom height
AppSpacing.height(280)  // 280.h

// Custom width
AppSpacing.width(200)   // 200.w
```

### Border Radius

```dart
AppSpacing.radiusSm    // 8.r
AppSpacing.radiusMd    // 12.r
AppSpacing.radiusLg    // 16.r
AppSpacing.radiusXl    // 24.r
```

### Icon Sizes

```dart
AppSpacing.iconSm      // 16.sp
AppSpacing.iconMd      // 20.sp
AppSpacing.iconLg      // 24.sp
AppSpacing.iconXl      // 32.sp
```

## 📱 Usage Examples

### Example 1: Using Spacing

```dart
// Before
Padding(
  padding: const EdgeInsets.all(16),
  child: SizedBox(height: 24, child: ...),
)

// After (Responsive)
Padding(
  padding: EdgeInsets.all(AppSpacing.md),
  child: SizedBox(height: AppSpacing.lg, child: ...),
)
```

### Example 2: Using Text Styles

```dart
// Before
Text(
  'Hello',
  style: TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  ),
)

// After
Text(
  'Hello',
  style: AppTextStyles.h2,
)
```

### Example 3: Using Colors

```dart
// Before
Container(
  color: const Color(0xFF4E7FFF),
  child: Text(
    'Hello',
    style: TextStyle(color: Colors.white.withOpacity(0.6)),
  ),
)

// After
Container(
  color: AppColors.primary,
  child: Text(
    'Hello',
    style: AppTextStyles.bodyMedium.copyWith(
      color: AppColors.textPrimaryWithOpacity(0.6),
    ),
  ),
)
```

### Example 4: Using Localization

```dart
// Before
Text('Skip')

// After
Text('onboarding.skip'.tr())
```

## 🔧 Configuration

### ScreenUtil Configuration

In `main.dart`:

```dart
ScreenUtilInit(
  designSize: const Size(375, 812),  // iPhone 11 Pro
  minTextAdapt: true,
  splitScreenMode: true,
  builder: (context, child) {
    return MaterialApp.router(...);
  },
)
```

### Localization Configuration

In `main.dart`:

```dart
EasyLocalization(
  supportedLocales: const [Locale('en'), Locale('ar')],
  path: 'assets/translations',
  fallbackLocale: const Locale('en'),
  startLocale: const Locale('en'),
  child: const MyApp(),
)
```

## ✅ Best Practices

1. **Always use AppColors** instead of hardcoded colors
2. **Always use AppTextStyles** instead of creating TextStyle inline
3. **Always use AppSpacing** for sizing (`.h`, `.w`, `.r`, `.sp`)
4. **Always use `.tr()` for user-facing text**
5. **Never use magic numbers** for spacing or sizing
6. **Use semantic naming** from AppColors (e.g., `textPrimary` not `white`)

## 🚀 Adding New Translations

1. Add key to `assets/translations/en.json`
2. Add corresponding translation to `assets/translations/ar.json`
3. Use in code: `'your.new.key'.tr()`

Example:

```json
// en.json
{
  "settings": {
    "title": "Settings",
    "language": "Language"
  }
}

// ar.json
{
  "settings": {
    "title": "الإعدادات",
    "language": "اللغة"
  }
}
```

```dart
// In code
Text('settings.title'.tr())
```
