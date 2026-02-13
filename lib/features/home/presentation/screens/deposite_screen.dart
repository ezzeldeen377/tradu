import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/app_spacing.dart';

class DepositScreen extends StatefulWidget {
  const DepositScreen({super.key});

  @override
  State<DepositScreen> createState() => _DepositScreenState();
}

class _DepositScreenState extends State<DepositScreen> {
  // USDT Charge Information
  final String usdtWalletAddress2 = 'TKmnjBEsVwoaTp2DKYHqWZvqMUCvSArH6b';
  final String usdtWalletAddress3 = 'TYwn7R8Xb8qKt1emdZcUihELQqXDW4tLaH';
  final String usdtNetwork = 'TRC20 (Tron Network)';

  // Sham Cash Charge Information
  final String shamCashAccountNumber = '243f8cffc62d64ef9859f2b1e2759210';
  final String shamCashAccountName = "محفظة اثراء واليت";

  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text)).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('deposit.copied_to_clipboard'.tr(args: [label])),
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.all(AppSpacing.md),
          duration: const Duration(seconds: 2),
        ),
      );
    });
  }

  Widget _buildChargeOption({
    required String title,
    required IconData icon,
    required Color iconColor,
    required List<Map<String, String>> infoItems,
    bool isAvailable = true,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: !isAvailable
          ? ListTile(
              title: Row(
                children: [
                  Text(title, style: AppTextStyles.h4),
                  SizedBox(width: AppSpacing.sm),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryWithAlpha(0.1),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                    ),
                    child: Text(
                      'Soon',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              leading: Container(
                padding: EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.withAlpha(iconColor, 0.2),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                ),
                child: Icon(icon, color: iconColor, size: AppSpacing.iconLg),
              ),
            )
          : ExpansionTile(
              initiallyExpanded: false,
              title: Text(title, style: AppTextStyles.h4),
              leading: Container(
                padding: EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.withAlpha(iconColor, 0.2),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                ),
                child: Icon(icon, color: iconColor, size: AppSpacing.iconLg),
              ),
              backgroundColor: Colors.transparent,
              collapsedIconColor: AppColors.primary,
              iconColor: AppColors.primary,
              children: [
                Padding(
                  padding: EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ...infoItems.map((item) {
                        final isMinDeposit =
                            item['label'] == 'deposit.minimum_deposit'.tr();
                        return Container(
                          margin: EdgeInsets.only(bottom: AppSpacing.sm),
                          padding: EdgeInsets.all(AppSpacing.sm),
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(
                              AppSpacing.radiusMd,
                            ),
                            border: Border.all(
                              color: AppColors.primaryWithAlpha(0.2),
                              width: 0.5,
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item['label'] ?? '',
                                      style: AppTextStyles.caption.copyWith(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    SizedBox(height: AppSpacing.xs),
                                    Text(
                                      item['value'] ?? '',
                                      style: AppTextStyles.bodyMedium,
                                    ),
                                  ],
                                ),
                              ),
                              if (!isMinDeposit)
                                IconButton(
                                  icon: Icon(
                                    Icons.copy,
                                    color: AppColors.primary,
                                    size: AppSpacing.iconMd,
                                  ),
                                  onPressed: () {
                                    _copyToClipboard(
                                      item['value'] ?? '',
                                      item['label'] ?? '',
                                    );
                                  },
                                ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildInstructionsCard() {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: AppColors.primary,
                  size: AppSpacing.iconLg,
                ),
                SizedBox(width: AppSpacing.sm),
                Text(
                  'deposit.instructions_title'.tr(),
                  style: AppTextStyles.h4,
                ),
              ],
            ),
            SizedBox(height: AppSpacing.md),
            _buildInstructionItem('deposit.instruction_1'.tr()),
            _buildInstructionItem('deposit.instruction_2'.tr()),
            _buildInstructionItem('deposit.instruction_3'.tr()),
            _buildInstructionItem('deposit.instruction_4'.tr()),
            _buildInstructionItem('deposit.instruction_5'.tr()),
            SizedBox(height: AppSpacing.sm),
            Container(
              padding: EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.primaryWithAlpha(0.1),
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.access_time,
                    color: AppColors.primary,
                    size: AppSpacing.iconMd,
                  ),
                  SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      'deposit.processing_time'.tr(),
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textPrimaryWithAlpha(0.9),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructionItem(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(top: AppSpacing.xs),
            child: Icon(Icons.circle, size: 8, color: AppColors.primary),
          ),
          SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textPrimaryWithAlpha(0.9),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'deposit.title'.tr(),
          style: AppTextStyles.h3.copyWith(color: AppColors.primary),
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            SizedBox(height: AppSpacing.md),

            // Instructions Card
            _buildInstructionsCard(),

            SizedBox(height: AppSpacing.md),

            // USDT Charge Option
            _buildChargeOption(
              title: 'deposit.usdt_title'.tr(),
              icon: Icons.currency_bitcoin,
              iconColor: AppColors.secondary,
              infoItems: [
                {
                  'label': "${'deposit.wallet_address'.tr()} 1",
                  'value': usdtWalletAddress2,
                },
                {
                  'label': "${'deposit.wallet_address'.tr()} 2",
                  'value': usdtWalletAddress3,
                },
                {'label': 'deposit.network'.tr(), 'value': usdtNetwork},
                {
                  'label': 'deposit.minimum_deposit'.tr(),
                  'value': 'deposit.usdt_min_amount'.tr(),
                },
              ],
            ),

            // Sham Cash Charge Option
            _buildChargeOption(
              title: 'deposit.sham_cash_title'.tr(),
              icon: Icons.account_balance_wallet,
              iconColor: AppColors.primary,
              isAvailable: false,
              infoItems: [
                {
                  'label': 'deposit.account_number'.tr(),
                  'value': shamCashAccountNumber,
                },
                {
                  'label': 'deposit.account_name'.tr(),
                  'value': shamCashAccountName,
                },
                {
                  'label': 'deposit.minimum_deposit'.tr(),
                  'value': 'deposit.sham_cash_min_amount'.tr(),
                },
              ],
            ),

            SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }
}
