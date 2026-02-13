# Currency Conversion Feature

## Overview
This implementation adds dynamic cryptocurrency conversion to the balance card widget. Users can select different cryptocurrencies and see their balance converted in real-time.

## Features Implemented

### 1. **CryptoCurrency Enum** (`lib/core/enums/crypto_currency.dart`)
- Defines 10 cryptocurrencies with their conversion rates
- Includes currency symbols (₿, Ξ, $, etc.)
- Provides conversion methods:
  - `convertFromUSD()` - Convert USD to selected currency
  - `convertToUSD()` - Convert selected currency to USD
  - `formatAmount()` - Format with appropriate decimal places
  - `fromCode()` - Get enum from currency code string

### 2. **Updated BalanceCardWidget**
The widget now:
- Uses `CryptoCurrency` enum instead of plain strings
- Calculates balance in selected currency
- Formats amounts with proper decimal precision
- Shows profit/loss in selected currency
- Dynamically changes arrow icon (up/down) based on P&L

### 3. **Enhanced CurrencyModel**
Added support for:
- `conversionRate` field (optional, from API)
- `cryptoCurrency` getter to get enum value
- `effectiveConversionRate` - uses API rate if available, otherwise enum default

## Supported Currencies

| Currency | Code | Symbol | Example (for $100) |
|----------|------|--------|-------------------|
| US Dollar | USD | $ | $100.00 |
| Bitcoin | BTC | ₿ | ₿0.00100000 |
| Ethereum | ETH | Ξ | Ξ0.025000 |
| Binance Coin | BNB | BNB | BNB0.1500 |
| Tether | USDT | ₮ | ₮100.00 |
| Ripple | XRP | XRP | XRP150.00 |
| Cardano | ADA | ADA | ADA200.00 |
| Dogecoin | DOGE | Ð | Ð750.00 |
| Solana | SOL | SOL | SOL0.5000 |
| Polkadot | DOT | DOT | DOT12.0000 |

## How It Works

### Balance Conversion
1. User balance is stored in USD in the database
2. When currency is selected, balance is converted using the formula:
   ```
   converted_balance = usd_balance × conversion_rate
   ```
3. Amount is formatted with appropriate decimal places based on currency value

### Daily P&L Conversion
1. Daily change is also stored in USD
2. Converted to selected currency using same formula
3. Percentage remains the same across all currencies
4. Icon changes to up arrow (green) for profit, down arrow (red) for loss

## Usage Example

```dart
// User has $100 USD balance
// Daily change: +$1,230.40 (2.4%)

// When USD is selected:
// Display: $100.00
// P&L: +$1,230.40 (2.4%)

// When BTC is selected:
// Display: ₿0.00100000
// P&L: +₿0.01230400 (2.4%)

// When ETH is selected:
// Display: Ξ0.025000
// P&L: +Ξ0.307600 (2.4%)
```

## Customization

### Update Conversion Rates
Edit `lib/core/enums/crypto_currency.dart`:
```dart
enum CryptoCurrency {
  btc('BTC', 0.000010, '₿'), // Change the rate here
  // ...
}
```

### Add New Currency
1. Add to enum:
```dart
enum CryptoCurrency {
  // ... existing currencies
  matic('MATIC', 1.2, 'MATIC'),
}
```

2. Ensure backend returns it in currencies list

### Use Dynamic Rates from API
Add `conversion_rate` to your currency API response:
```json
{
  "id": 1,
  "name": "BTC",
  "conversion_rate": 0.000010,
  "created_at": "...",
  "updated_at": "..."
}
```

The system will use API rate if available, otherwise falls back to enum default.

## Future Enhancements

1. **Real-time rates**: Integrate with crypto price API for live conversion rates
2. **Historical data**: Show balance changes over time in selected currency
3. **Multiple balances**: Support holding actual crypto (not just USD equivalent)
4. **Favorite currencies**: Let users pin their preferred currencies
5. **Rate refresh**: Add pull-to-refresh for updating conversion rates

## Notes

- All calculations are done client-side for instant response
- The `_dailyChangeUSD` is currently mocked - replace with actual API data
- Conversion rates are approximate and should be updated regularly
- For production, consider fetching real-time rates from a crypto API
