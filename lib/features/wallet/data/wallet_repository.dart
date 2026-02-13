import 'package:crypto_app/core/networking/api_constant.dart';
import 'package:crypto_app/core/networking/http_services.dart';
import 'package:crypto_app/features/wallet/data/models/user_wallet_model.dart';
import 'package:injectable/injectable.dart';

@injectable
class WalletRepository {
  final HttpServices httpServices;

  WalletRepository(this.httpServices);

  Future<UserWalletModel> getUserWallet() async {
    final response = await httpServices.get(ApiConstant.userWalletEndPoint);
    return UserWalletModel.fromJson(response);
  }

  Future<Map<String, dynamic>> depositUsdToCrypto({
    required String currencyApiId,
    required double usdAmount,
  }) async {
    final response = await httpServices.post(
      ApiConstant.usdToCryptoEndPoint,
      body: {
        'currency_api_id': currencyApiId,
        'usd_amount': usdAmount.toString(),
      },
    );
    return response;
  }

  Future<Map<String, dynamic>> withdrawCryptoToUsd({
    required String currencyApiId,
    required double cryptoAmount,
  }) async {
    final response = await httpServices.post(
      ApiConstant.cryptoToUsdEndPoint,
      body: {
        'currency_api_id': currencyApiId,
        'crypto_amount': cryptoAmount.toString(),
      },
    );
    return response;
  }

  Future<Map<String, dynamic>> exchangeCryptoToCrypto({
    required String fromCurrencyApiId,
    required String toCurrencyApiId,
    required double cryptoAmount,
  }) async {
    final response = await httpServices.post(
      ApiConstant.cryptoToCryptoEndPoint,
      body: {
        'from_currency_api_id': fromCurrencyApiId,
        'to_currency_api_id': toCurrencyApiId,
        'crypto_amount': cryptoAmount.toString(),
      },
    );
    return response;
  }
}
