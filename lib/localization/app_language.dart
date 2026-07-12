import 'package:flutter/material.dart';

import 'app_strings.dart';
import 'language_strings.dart';
import 'language_service.dart';

class AppLanguage extends ChangeNotifier {
  static final AppLanguage instance = AppLanguage._();

  AppLanguage._();

  Future<void> init() async {
    await LanguageService.loadLanguage();
    notifyListeners();
  }

  Future<void> changeLanguage(String language) async {
    await LanguageService.setLanguage(language);
    notifyListeners();
  }

  LanguageStrings get strings => AppStrings.current;
}