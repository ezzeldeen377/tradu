import 'package:flutter/material.dart';

enum LanguageStatus { initial, loading, loaded, error }

class LanguageState {
  final Locale locale;
  final Locale selectedLocale;
  final LanguageStatus status;
  final String? errorMessage;
  final bool isFirstTime;

  const LanguageState({
    required this.locale,
    required this.selectedLocale,
    this.status = LanguageStatus.initial,
    this.errorMessage,
    this.isFirstTime = true,
  });

  LanguageState copyWith({
    Locale? locale,
    Locale? selectedLocale,
    LanguageStatus? status,
    String? errorMessage,
    bool? isFirstTime,
  }) {
    return LanguageState(
      locale: locale ?? this.locale,
      selectedLocale: selectedLocale ?? this.selectedLocale,
      status: status ?? this.status,
      errorMessage: errorMessage,
      isFirstTime: isFirstTime ?? this.isFirstTime,
    );
  }
}
