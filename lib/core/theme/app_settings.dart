import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:lodbod_app/core/constants/app_constants.dart';

class AppSettings extends ChangeNotifier {
  static const _boxName = 'app_settings';

  ThemeMode themeMode = ThemeMode.system;
  Locale? locale;
  Box<dynamic>? _box;

  Future<void> load() async {
    _box = await Hive.openBox<dynamic>(_boxName);
    final savedTheme = _box!.get(AppConstants.keyThemeMode) as String?;
    themeMode = switch (savedTheme) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };

    final languageCode = _box!.get(AppConstants.keyLanguage) as String?;
    locale = languageCode == null || languageCode == 'system'
        ? null
        : Locale(languageCode);
  }

  Future<void> setThemeMode(ThemeMode value) async {
    themeMode = value;
    notifyListeners();
    await _box?.put(AppConstants.keyThemeMode, value.name);
  }

  Future<void> setLocale(Locale? value) async {
    locale = value;
    notifyListeners();
    await _box?.put(AppConstants.keyLanguage, value?.languageCode ?? 'system');
  }
}

final appSettings = AppSettings();
