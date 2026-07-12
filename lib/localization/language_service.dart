import 'package:shared_preferences/shared_preferences.dart';

import 'app_strings.dart';
import 'de.dart';
import 'en.dart';
import 'pl.dart';

class LanguageService {
  static const _key = "language";

  static Future<void> setLanguage(String language) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(_key, language);

    switch (language) {
      case "Deutsch":
        AppStrings.current = GermanStrings();
        break;

      case "English":
        AppStrings.current = EnglishStrings();
        break;

      case "Polski":
        AppStrings.current = PolishStrings();
        break;
    }
  }

  static Future<void> loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();

    final language =
        prefs.getString(_key) ?? "Deutsch";

    await setLanguage(language);
  }
}