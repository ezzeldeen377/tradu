/// Currency Conversion Example
///
/// This file demonstrates how the currency conversion system works
/// in the BalanceCardWidget.
///
/// ## How it works:
///
/// 1. **Base Currency**: All balances are stored in USD in the database
/// 2. **Conversion Rates**: Each cryptocurrency has a conversion rate defined in the CryptoCurrency enum
/// 3. **Display**: When user selects a currency, the balance is converted and displayed
///
/// ## Example Conversions:
///
/// If user has $100 USD balance:
/// - USD: $100.00
/// - BTC: ₿0.00100000 (100 * 0.000010)
/// - ETH: Ξ0.025000 (100 * 0.00025)
/// - BNB: BNB0.1500 (100 * 0.0015)
/// - USDT: ₮100.00 (100 * 1.0)
/// - XRP: XRP150.00 (100 * 1.5)
/// - ADA: ADA200.00 (100 * 2.0)
/// - DOGE: Ð750.00 (100 * 7.5)
/// - SOL: SOL0.5000 (100 * 0.005)
/// - DOT: DOT12.0000 (100 * 0.12)
///
/// ## Daily P&L Calculation:
///
/// The daily profit/loss is also converted to the selected currency.
/// For example, if the daily change is +$1,230.40 USD:
/// - USD: +$1,230.40 (2.4%)
/// - BTC: +₿0.01230400 (2.4%)
/// - ETH: +Ξ0.307600 (2.4%)
/// - And so on...
///
/// ## Updating Conversion Rates:
///
/// You can update conversion rates in two ways:
///
/// 1. **Static (in code)**: Edit the CryptoCurrency enum in crypto_currency.dart
/// 2. **Dynamic (from API)**: Add conversion_rate field to your currency API response
///    The CurrencyModel will use the API rate if available, otherwise falls back to enum
///
/// ## Adding New Currencies:
///
/// To add a new cryptocurrency:
/// 1. Add it to the CryptoCurrency enum with its conversion rate
/// 2. Ensure your backend returns this currency in the currencies list
/// 3. The UI will automatically support it
///
/// Example:
/// ```dart
/// // In crypto_currency.dart
/// enum CryptoCurrency {
///   // ... existing currencies
///   matic('MATIC', 1.2, 'MATIC'), // 1 USD = 1.2 MATIC
/// }
/// ```

void main() {
  // This is just a documentation file
  // See the actual implementation in:
  // - lib/core/enums/crypto_currency.dart
  // - lib/features/home/presentation/widgets/balance_card_widget.dart
  // - lib/features/auth/data/models/currency_model.dart
}
