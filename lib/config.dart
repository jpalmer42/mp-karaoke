import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppConfig {
  static const String spInitialized = 'Initialized';
  static const String spLanguage = 'language';

  late final SharedPreferences _preferences;
  SharedPreferences get prefs => _preferences;

  late final Directory _appSupportDir;
  Directory get appSupportDir => _appSupportDir;

  AppConfig._();
  static AppConfig? _instance;

  static AppConfig get instance {
    assert(_instance != null, 'AppConfig must be initialized using AppConfig.init() before accessing instance.');
    return _instance!;
  }

  static Future<void> init() async {
    if (_instance != null) return;

    final config = AppConfig._();
    config._preferences = await SharedPreferences.getInstance();
    config._appSupportDir = await getApplicationSupportDirectory();

    _instance = config;
  }
}
