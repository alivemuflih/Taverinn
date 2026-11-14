import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:taverinn/l10n/app_localizations.dart';
import 'package:taverinn/screens/settings_screen.dart';
import 'package:taverinn/theme/app_preferences.dart';
import 'package:taverinn/theme/app_theme.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('defaults to system theme and Indonesian without a startup override',
      () async {
    final preferences = await AppPreferences.load();

    expect(preferences.themePreference, TaverinnThemePreference.system);
    expect(preferences.themeMode, ThemeMode.system);
    expect(preferences.languageCode, 'id');
    preferences.dispose();
  });

  test('theme and language choices apply immediately and persist', () async {
    final preferences = await AppPreferences.load();
    var notifications = 0;
    preferences.addListener(() => notifications++);

    await preferences.setThemePreference(TaverinnThemePreference.dark);
    expect(preferences.themeMode, ThemeMode.dark);
    await preferences.setLanguageCode('en');
    expect(preferences.locale, const Locale('en'));
    expect(notifications, 2);

    final reopened = await AppPreferences.load();
    expect(reopened.themePreference, TaverinnThemePreference.dark);
    expect(reopened.themeMode, ThemeMode.dark);
    expect(reopened.languageCode, 'en');

    await reopened.setThemePreference(TaverinnThemePreference.light);
    expect(reopened.themeMode, ThemeMode.light);
    expect((await AppPreferences.load()).themePreference,
        TaverinnThemePreference.light);

    preferences.dispose();
    reopened.dispose();
  });

  testWidgets('settings apply theme and locale changes to the app immediately',
      (tester) async {
    tester.view.physicalSize = const Size(900, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    tester.platformDispatcher.platformBrightnessTestValue = Brightness.light;
    addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
    final preferences = await AppPreferences.load();
    addTearDown(preferences.dispose);

    await tester.pumpWidget(
      AnimatedBuilder(
        animation: preferences,
        builder: (context, _) => MaterialApp(
          theme: TaverinnTheme.light,
          darkTheme: TaverinnTheme.dark,
          themeMode: preferences.themeMode,
          locale: preferences.locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (context) => Scaffold(
              body: Column(
                children: [
                  Text(
                    '${Theme.of(context).brightness.name} / '
                    '${AppLocalizations.of(context).localeName}',
                    key: const ValueKey('active_appearance'),
                  ),
                  Expanded(child: SettingsScreen(preferences: preferences)),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.text('light / id'), findsOneWidget);
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    await expectLater(tester, meetsGuideline(textContrastGuideline));
    await tester.tap(find.byKey(const ValueKey('settings_dark_theme')));
    await tester.pumpAndSettle();
    expect(find.text('dark / id'), findsOneWidget);
    await expectLater(tester, meetsGuideline(textContrastGuideline));

    final englishOption = find.byKey(const ValueKey('settings_english'));
    await tester.ensureVisible(englishOption);
    await tester.tap(englishOption);
    await tester.pumpAndSettle();
    expect(find.text('dark / en'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);

    tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
    final systemTheme = find.byKey(const ValueKey('settings_system_theme'));
    await tester.ensureVisible(systemTheme);
    await tester.tap(systemTheme);
    await tester.pumpAndSettle();
    expect(find.text('dark / en'), findsOneWidget);

    tester.platformDispatcher.platformBrightnessTestValue = Brightness.light;
    await tester.pumpAndSettle();
    expect(find.text('light / en'), findsOneWidget);
  });
}
