import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum TaverinnThemePreference { system, light, dark }

class AppPreferences extends ChangeNotifier {
  AppPreferences._(this._store)
      : _themePreference = _readTheme(_store.getString(_themeKey)),
        _languageCode = _readLanguage(_store.getString(_languageKey));

  static const _themeKey = 'appearance.theme';
  static const _languageKey = 'appearance.language';

  final SharedPreferences _store;
  TaverinnThemePreference _themePreference;
  String _languageCode;
  Future<void> _writeQueue = Future<void>.value();

  static Future<AppPreferences> load() async =>
      AppPreferences._(await SharedPreferences.getInstance());

  TaverinnThemePreference get themePreference => _themePreference;
  String get languageCode => _languageCode;
  Locale get locale => Locale(_languageCode);

  ThemeMode get themeMode => switch (_themePreference) {
        TaverinnThemePreference.system => ThemeMode.system,
        TaverinnThemePreference.light => ThemeMode.light,
        TaverinnThemePreference.dark => ThemeMode.dark,
      };

  Future<void> setThemePreference(TaverinnThemePreference value) async {
    if (value == _themePreference) return;
    _themePreference = value;
    notifyListeners();
    await _enqueueWrite(() async {
      await _store.setString(_themeKey, value.name);
    });
  }

  Future<void> setLanguageCode(String value) async {
    if (value != 'id' && value != 'en' || value == _languageCode) return;
    _languageCode = value;
    notifyListeners();
    await _enqueueWrite(() async {
      await _store.setString(_languageKey, value);
    });
  }

  Future<void> _enqueueWrite(Future<void> Function() write) {
    _writeQueue = _writeQueue.then((_) async {
      await write();
    });
    return _writeQueue;
  }

  static TaverinnThemePreference _readTheme(String? value) =>
      TaverinnThemePreference.values.firstWhere(
        (item) => item.name == value,
        orElse: () => TaverinnThemePreference.system,
      );

  static String _readLanguage(String? value) =>
      value == 'en' || value == 'id' ? value! : 'id';
}

class AppPreferencesScope extends InheritedNotifier<AppPreferences> {
  const AppPreferencesScope({
    super.key,
    required AppPreferences preferences,
    required super.child,
  }) : super(notifier: preferences);

  static AppPreferences of(BuildContext context) {
    final scope =
        context.dependOnInheritedWidgetOfExactType<AppPreferencesScope>();
    assert(scope?.notifier != null, 'AppPreferencesScope is missing.');
    return scope!.notifier!;
  }
}
