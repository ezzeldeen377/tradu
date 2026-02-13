import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ExitAppWrapper extends StatefulWidget {
  final Widget child;

  const ExitAppWrapper({super.key, required this.child});

  @override
  State<ExitAppWrapper> createState() => _ExitAppWrapperState();
}

class _ExitAppWrapperState extends State<ExitAppWrapper> {
  DateTime? _lastPressedAt;

  Future<bool> _onWillPop() async {
    final now = DateTime.now();

    // If last pressed was null or more than 2 seconds ago
    if (_lastPressedAt == null ||
        now.difference(_lastPressedAt!) > const Duration(seconds: 2)) {
      // Update last pressed time
      _lastPressedAt = now;

      // Show snackbar
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'common.press_again_to_exit'.tr(),
              style: const TextStyle(color: Colors.white),
            ),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            backgroundColor: const Color(0xFF1F68F9),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }

      // Don't exit
      return false;
    }

    // Exit the app
    SystemNavigator.pop();
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop) {
          await _onWillPop();
        }
      },
      child: widget.child,
    );
  }
}
