import 'dart:io';
import 'package:crypto_app/core/utils/show_snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/app_spacing.dart';
import '../../../../core/routes/app_routes.dart';

class IdentityVerificationScreen extends StatefulWidget {
  const IdentityVerificationScreen({super.key});

  @override
  State<IdentityVerificationScreen> createState() =>
      _IdentityVerificationScreenState();
}

class _IdentityVerificationScreenState
    extends State<IdentityVerificationScreen> {
  File? _frontImage;
  File? _backImage;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(bool isFront) async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (image != null) {
      setState(() {
        if (isFront) {
          _frontImage = File(image.path);
        } else {
          _backImage = File(image.path);
        }
      });
    }
  }

  Future<void> _captureImage(bool isFront) async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
    );

    if (image != null) {
      setState(() {
        if (isFront) {
          _frontImage = File(image.path);
        } else {
          _backImage = File(image.path);
        }
      });
    }
  }

  void _showImageSourceDialog(bool isFront) {
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(
                  Icons.camera_alt,
                  color: theme.colorScheme.primary,
                ),
                title: Text(
                  'identity_verification.take_photo'.tr(),
                  style: AppTextStyles.bodyMedium,
                ),
                onTap: () {
                  Navigator.pop(context);
                  _captureImage(isFront);
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.photo_library,
                  color: theme.colorScheme.primary,
                ),
                title: Text(
                  'identity_verification.choose_from_gallery'.tr(),
                  style: AppTextStyles.bodyMedium,
                ),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(isFront);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submitVerification() {
    if (_frontImage == null || _backImage == null) {
      showSnackBar(context, 'identity_verification.upload_both_images'.tr());
      return;
    }
    context.go(AppRoutes.dashboard);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.colorScheme.onSurface),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'identity_verification.title'.tr(),
          style: AppTextStyles.h3.copyWith(color: theme.colorScheme.onSurface),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(AppSpacing.lg),
          child: Column(
            children: [
              SizedBox(height: AppSpacing.sm),
              // Shield Icon
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: AppSpacing.height(60),
                    height: AppSpacing.height(60),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      Icons.shield_outlined,
                      size: AppSpacing.height(30),
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'identity_verification.verify_title'.tr(),
                          style: AppTextStyles.h2.copyWith(
                            color: theme.colorScheme.onSurface,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: AppSpacing.xs),
                        Text(
                          'identity_verification.verify_subtitle'.tr(),
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.6,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppSpacing.lg),
              // Front ID Card Upload
              _buildImageUploadCard(
                isFront: true,
                image: _frontImage,
                onTap: () => _showImageSourceDialog(true),
              ),
              SizedBox(height: AppSpacing.sm),
              // Back ID Card Upload
              _buildImageUploadCard(
                isFront: false,
                image: _backImage,
                onTap: () => _showImageSourceDialog(false),
              ),
              SizedBox(height: AppSpacing.lg),
              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitVerification,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'identity_verification.submit'.tr(),
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: theme.colorScheme.onPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(width: AppSpacing.sm),
                      Icon(Icons.arrow_forward, size: AppSpacing.iconMd),
                    ],
                  ),
                ),
              ),
              SizedBox(height: AppSpacing.sm),
              // Skip Button
              TextButton(
                onPressed: () => context.go(AppRoutes.dashboard),
                child: Text(
                  'identity_verification.skip'.tr(),
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ),
              SizedBox(height: AppSpacing.xs),
              // Encryption Notice
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.lock_outline,
                    size: AppSpacing.iconSm,
                    color: theme.colorScheme.primary,
                  ),
                  SizedBox(width: AppSpacing.xs),
                  Text(
                    'auth.end_to_end_encrypted'.tr(),
                    style: AppTextStyles.caption.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppSpacing.xs),
              // Info Text
              Text(
                'identity_verification.info_text'.tr(),
                style: AppTextStyles.caption.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageUploadCard({
    required bool isFront,
    required File? image,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: AppSpacing.height(200),
        decoration: BoxDecoration(
          color: image != null
              ? theme.colorScheme.surface
              : theme.colorScheme.surfaceContainerHighest.withValues(
                  alpha: 0.3,
                ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: theme.dividerColor.withValues(alpha: 0.2),
            width: 1.5,
          ),
        ),
        child: image != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Stack(
                  children: [
                    Image.file(
                      image,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                    ),
                    Positioned(
                      top: AppSpacing.sm,
                      right: AppSpacing.sm,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.6),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.close, color: Colors.white),
                          onPressed: () {
                            setState(() {
                              if (isFront) {
                                _frontImage = null;
                              } else {
                                _backImage = null;
                              }
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: AppSpacing.height(60),
                    height: AppSpacing.height(60),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.camera_alt,
                      size: AppSpacing.iconLg,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  SizedBox(height: AppSpacing.md),
                  Text(
                    isFront
                        ? 'identity_verification.id_front'.tr()
                        : 'identity_verification.id_back'.tr(),
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: theme.colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: AppSpacing.xs),
                  Text(
                    'identity_verification.tap_to_upload'.tr(),
                    style: AppTextStyles.bodySmall.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
