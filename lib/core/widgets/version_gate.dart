import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:easy_localization/easy_localization.dart'
    show tr, StringTranslateExtension;
import '../utils/app_spacing.dart';

/// A widget that wraps the app and shows an update overlay when needed
/// Shows as a Stack with the app underneath and update dialog on top
class VersionGate extends StatefulWidget {
  final Widget child;
  final String serverVersion;

  const VersionGate({
    super.key,
    required this.child,
    required this.serverVersion,
  });

  @override
  State<VersionGate> createState() => _VersionGateState();
}

class _VersionGateState extends State<VersionGate> {
  bool _isLoading = true;
  bool _needsUpdate = false;
  String _currentVersion = '';
  String _serverVersion = '';

  @override
  void initState() {
    super.initState();
    _checkVersion();
  }

  @override
  void didUpdateWidget(VersionGate oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Re-check if server version changes
    if (oldWidget.serverVersion != widget.serverVersion) {
      _checkVersion();
    }
  }

  Future<void> _checkVersion() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;
      final serverVersion = widget.serverVersion;

      final needsUpdate = _compareVersions(currentVersion, serverVersion);

      setState(() {
        _currentVersion = currentVersion;
        _serverVersion = serverVersion;
        _needsUpdate = needsUpdate;
        _isLoading = false;
      });

      debugPrint('=== VERSION GATE ===');
      debugPrint('Current Version: $currentVersion');
      debugPrint('Server Version: $serverVersion');
      debugPrint('Needs Update: $needsUpdate');
    } catch (e) {
      debugPrint('Version check error: $e');
      // If check fails, allow app to continue
      setState(() {
        _isLoading = false;
        _needsUpdate = false;
      });
    }
  }

  /// Compare versions - returns true if server version is greater
  bool _compareVersions(String currentVersion, String serverVersion) {
    final current = _parseVersion(currentVersion);
    final server = _parseVersion(serverVersion);

    // Compare major version
    if (server[0] > current[0]) return true;
    if (server[0] < current[0]) return false;

    // Compare minor version
    if (server[1] > current[1]) return true;
    if (server[1] < current[1]) return false;

    // Compare patch version
    if (server[2] > current[2]) return true;

    return false;
  }

  /// Parse version string to list of integers
  List<int> _parseVersion(String version) {
    try {
      final versionOnly = version.split('+').first;
      final parts = versionOnly.split('.');
      return [
        int.parse(parts[0]),
        int.parse(parts.length > 1 ? parts[1] : '0'),
        int.parse(parts.length > 2 ? parts[2] : '0'),
      ];
    } catch (e) {
      return [0, 0, 0];
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show loading while checking version
    if (_isLoading) {
      return Directionality(
        textDirection: TextDirection.ltr,
        child: const Center(
          child: CircularProgressIndicator(color: Color(0xFF1F68F9)),
        ),
      );
    }

    // Show app with update overlay if needed
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Main app (always visible underneath)
          widget.child,

          // Update overlay (shown on top when update is needed)
          if (_needsUpdate)
            _UpdateOverlay(
              currentVersion: _currentVersion,
              serverVersion: _serverVersion,
            ),
        ],
      ),
    );
  }
}

/// The update overlay that appears on top of the app
class _UpdateOverlay extends StatelessWidget {
  final String currentVersion;
  final String serverVersion;

  const _UpdateOverlay({
    required this.currentVersion,
    required this.serverVersion,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.6),
      child: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.transparent,
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(AppSpacing.xl),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 380),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A2332),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: const Color(0xFF2A3A4F),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.5),
                      blurRadius: 30,
                      spreadRadius: 10,
                    ),
                  ],
                ),
                child: Padding(
                  padding: EdgeInsets.all(AppSpacing.xl * 1.5),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Rocket Image in Circle
                      Center(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.asset(
                            'assets/images/update.png',
                            width: 120.w,
                            height: 120.h,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),

                      SizedBox(height: AppSpacing.xl),

                      // Title
                      Text(
                        'update.title'.tr(),
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: -0.5,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      SizedBox(height: AppSpacing.md),

                      // Message
                      Text(
                        'update.mandatory_message'.tr(),
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.white.withValues(alpha: 0.6),
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      SizedBox(height: AppSpacing.xl * 1.5),

                      // Update Button with Gradient
                      Container(
                        width: double.infinity,
                        height: 56,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(
                                0xFF3B82F6,
                              ).withValues(alpha: 0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: _launchStore,
                            borderRadius: BorderRadius.circular(16),
                            child: Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'update.update_now'.tr(),
                                    style: const TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                      letterSpacing: 0.2,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Icon(
                                    Icons.arrow_forward,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: AppSpacing.xl),

                      // Version Info
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'V$currentVersion',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.white.withValues(alpha: 0.4),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Icon(
                              Icons.arrow_forward,
                              size: 14,
                              color: Colors.white.withValues(alpha: 0.4),
                            ),
                          ),
                          Text(
                            'V$serverVersion',
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF3B82F6),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _launchStore() async {
    // TODO: Replace with your actual app store URL
    const url =
        'https://play.google.com/store/apps/details?id=com.example.crypto_app';

    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
