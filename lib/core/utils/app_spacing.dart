import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppSpacing {
  // Vertical Spacing
  static double get xs => 4.h;
  static double get sm => 8.h;
  static double get md => 16.h;
  static double get lg => 24.h;
  static double get xl => 32.h;
  static double get xxl => 48.h;
  static double get xxxl => 64.h;

  // Horizontal Spacing
  static double get xsW => 4.w;
  static double get smW => 8.w;
  static double get mdW => 16.w;
  static double get lgW => 24.w;
  static double get xlW => 32.w;
  static double get xxlW => 48.w;
  static double get xxxlW => 64.w;

  // Custom Heights
  static double height(double value) => value.h;
  static double width(double value) => value.w;

  // Radius
  static double get radiusSm => 8.r;
  static double get radiusMd => 12.r;
  static double get radiusLg => 16.r;
  static double get radiusXl => 24.r;

  // Icon Sizes
  static double get iconSm => 16.sp;
  static double get iconMd => 20.sp;
  static double get iconLg => 24.sp;
  static double get iconXl => 32.sp;
}
