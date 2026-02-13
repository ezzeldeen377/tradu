import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../data/language_repository.dart';
import 'language_state.dart';

@injectable
class LanguageCubit extends Cubit<LanguageState> {
  final LanguageRepository repository;

  LanguageCubit(this.repository)
    : super(
        const LanguageState(
          locale: Locale('ar'),
          selectedLocale: Locale('ar'),
          status: LanguageStatus.initial,
          isFirstTime: true,
        ),
      );

  Future<void> loadSavedLanguage() async {
    emit(state.copyWith(status: LanguageStatus.loading));

    try {
      final isFirstTime = await repository.isFirstTime();
      final savedLanguage = await repository.getSavedLanguage();

      if (savedLanguage != null) {
        final locale = Locale(savedLanguage);
        emit(
          state.copyWith(
            locale: locale,
            selectedLocale: locale,
            status: LanguageStatus.loaded,
            isFirstTime: false,
          ),
        );
      } else {
        emit(
          state.copyWith(
            locale: const Locale('ar'),
            selectedLocale: const Locale('ar'),
            status: LanguageStatus.loaded,
            isFirstTime: isFirstTime,
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          status: LanguageStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  void selectLanguage(Locale locale) {
    emit(state.copyWith(selectedLocale: locale));
  }

  Future<void> confirmLanguageSelection() async {
    try {
      await repository.saveLanguage(state.selectedLocale.languageCode);
      await repository.setNotFirstTime();

      emit(
        state.copyWith(
          locale: state.selectedLocale,
          status: LanguageStatus.loaded,
          isFirstTime: false,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: LanguageStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> changeLanguage(Locale locale) async {
    try {
      await repository.saveLanguage(locale.languageCode);
      await repository.setNotFirstTime();

      emit(
        state.copyWith(
          locale: locale,
          selectedLocale: locale,
          status: LanguageStatus.loaded,
          isFirstTime: false,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: LanguageStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> clearLanguageData() async {
    try {
      await repository.clearLanguageData();
      emit(
        const LanguageState(
          locale: Locale('ar'),
          selectedLocale: Locale('ar'),
          status: LanguageStatus.loaded,
          isFirstTime: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: LanguageStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}
