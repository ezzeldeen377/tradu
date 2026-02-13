// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:flutter_secure_storage/flutter_secure_storage.dart' as _i558;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:shared_preferences/shared_preferences.dart' as _i460;

import '../../features/admin/data/repositories/chat_repository.dart' as _i403;
import '../../features/admin/presentation/cubits/chat_detail_cubit/chat_detail_cubit.dart'
    as _i1024;
import '../../features/admin/presentation/cubits/chats_cubit/chats_cubit.dart'
    as _i355;
import '../../features/auth/data/auth_repository.dart' as _i726;
import '../../features/auth/presentation/cubit/auth_cubit.dart' as _i117;
import '../../features/history/data/history_repository.dart' as _i769;
import '../../features/history/presentation/cubit/history_cubit.dart' as _i232;
import '../../features/home/data/home_repository.dart' as _i65;
import '../../features/home/presentation/cubit/home/home_cubit.dart' as _i273;
import '../../features/home/presentation/cubit/withdraw/withdraw_cubit.dart'
    as _i394;
import '../../features/language/data/language_repository.dart' as _i186;
import '../../features/language/presentation/cubit/language_cubit.dart'
    as _i647;
import '../../features/notifications/data/notification_repository.dart' as _i8;
import '../../features/notifications/presentation/cubit/notification_cubit.dart'
    as _i459;
import '../../features/plan/data/repositories/plan_repository.dart' as _i1067;
import '../../features/plan/presentation/cubit/plans_cubit.dart' as _i1034;
import '../../features/trade/presentation/cubit/trade_cubit.dart' as _i635;
import '../../features/wallet/data/wallet_repository.dart' as _i308;
import '../../features/wallet/presentation/cubit/wallet_cubit.dart' as _i101;
import '../cache/cache_service.dart' as _i981;
import '../networking/http_services.dart' as _i693;
import 'di.dart' as _i913;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  Future<_i174.GetIt> init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) async {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final registerModule = _$RegisterModule();
    gh.singleton<_i558.FlutterSecureStorage>(
      () => registerModule.secureStorage,
    );
    await gh.singletonAsync<_i460.SharedPreferences>(
      () => registerModule.sharedPreferences,
      preResolve: true,
    );
    gh.singleton<_i693.HttpServices>(() => _i693.HttpServices());
    gh.factory<_i186.LanguageRepository>(
      () => _i186.LanguageRepository(gh<_i558.FlutterSecureStorage>()),
    );
    gh.factory<_i403.ChatRepository>(
      () => _i403.ChatRepository(gh<_i693.HttpServices>()),
    );
    gh.factory<_i769.HistoryRepository>(
      () => _i769.HistoryRepository(gh<_i693.HttpServices>()),
    );
    gh.factory<_i8.NotificationRepository>(
      () => _i8.NotificationRepository(gh<_i693.HttpServices>()),
    );
    gh.factory<_i1067.PlanRepository>(
      () => _i1067.PlanRepository(gh<_i693.HttpServices>()),
    );
    gh.factory<_i308.WalletRepository>(
      () => _i308.WalletRepository(gh<_i693.HttpServices>()),
    );
    gh.factory<_i232.HistoryCubit>(
      () => _i232.HistoryCubit(gh<_i769.HistoryRepository>()),
    );
    gh.factory<_i981.CacheService>(
      () => _i981.CacheService(gh<_i460.SharedPreferences>()),
    );
    gh.factory<_i65.HomeRepository>(
      () => _i65.HomeRepository(
        gh<_i693.HttpServices>(),
        gh<_i981.CacheService>(),
      ),
    );
    gh.factory<_i1034.PlansCubit>(
      () => _i1034.PlansCubit(gh<_i1067.PlanRepository>()),
    );
    gh.factory<_i726.AuthRepository>(
      () => _i726.AuthRepository(httpServices: gh<_i693.HttpServices>()),
    );
    gh.factory<_i647.LanguageCubit>(
      () => _i647.LanguageCubit(gh<_i186.LanguageRepository>()),
    );
    gh.singleton<_i355.ChatsCubit>(
      () => _i355.ChatsCubit(gh<_i403.ChatRepository>()),
    );
    gh.factory<_i1024.ChatDetailCubit>(
      () => _i1024.ChatDetailCubit(gh<_i403.ChatRepository>()),
    );
    gh.factory<_i459.NotificationCubit>(
      () => _i459.NotificationCubit(gh<_i8.NotificationRepository>()),
    );
    gh.factory<_i117.AuthCubit>(
      () => _i117.AuthCubit(
        repository: gh<_i726.AuthRepository>(),
        chatRepository: gh<_i403.ChatRepository>(),
      ),
    );
    gh.factory<_i101.WalletCubit>(
      () => _i101.WalletCubit(
        gh<_i308.WalletRepository>(),
        gh<_i65.HomeRepository>(),
      ),
    );
    gh.factory<_i273.HomeCubit>(
      () => _i273.HomeCubit(gh<_i65.HomeRepository>()),
    );
    gh.factory<_i394.WithdrawCubit>(
      () => _i394.WithdrawCubit(gh<_i65.HomeRepository>()),
    );
    gh.lazySingleton<_i635.TradeCubit>(
      () => _i635.TradeCubit(
        gh<_i65.HomeRepository>(),
        gh<_i308.WalletRepository>(),
      ),
    );
    return this;
  }
}

class _$RegisterModule extends _i913.RegisterModule {}
