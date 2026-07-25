import 'package:flutter/material.dart';

enum AppLanguage {
  english('en', 'English'),
  hindi('hi', 'हिन्दी');

  const AppLanguage(this.code, this.label);

  final String code;
  final String label;

  Locale get locale => Locale(code);

  static AppLanguage fromCode(String? code) {
    return AppLanguage.values.firstWhere(
      (language) => language.code == code,
      orElse: () => AppLanguage.english,
    );
  }

  static const supportedLocales = [
    Locale('en'),
    Locale('hi'),
  ];
}
