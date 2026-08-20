import 'package:mp_karaoke_ui/config.dart';

mixin Translate {
  static Function(String value, {String? prefix, String? suffix})? _translate;
  String translate(String value, {String? prefix, String? suffix}) {
    if (_translate == null) {
      final lang = AppConfig.instance.prefs.getString(AppConfig.spLanguage) ?? 'en';
      _translate = lang == 'en' ? _defaultTranslator : _defaultTranslator;
    }

    return _translate!(value, prefix: prefix, suffix: suffix);
  }

  String _defaultTranslator(String value, {String? prefix, String? suffix}) {
    String? translation = value as String?;
    return "${prefix ?? ''}${translation ?? ''}${suffix ?? ''}";
  }
}
