import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:taverinn/l10n/app_localizations.dart';
import 'package:taverinn/screens/settings_screen.dart';
import 'package:taverinn/theme/app_preferences.dart';
import 'package:taverinn/theme/app_theme.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('Settings stays composed in light and dark on a phone width',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final fontBytes = File('test/assets/roboto-regular.ttf').readAsBytesSync();
    final fontLoader = FontLoader('Roboto')
      ..addFont(Future.value(ByteData.sublistView(fontBytes)));
    await fontLoader.load();

    final preferences = await AppPreferences.load();
    addTearDown(preferences.dispose);
    await preferences.setLanguageCode('en');

    Future<void> pumpSettings() async {
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
            home: SettingsScreen(preferences: preferences),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    await preferences.setThemePreference(TaverinnThemePreference.light);
    await pumpSettings();
    await expectLater(
      find.byType(SettingsScreen),
      matchesGoldenFile('goldens/settings_light_en.png'),
    );

    await preferences.setThemePreference(TaverinnThemePreference.dark);
    await pumpSettings();
    await expectLater(
      find.byType(SettingsScreen),
      matchesGoldenFile('goldens/settings_dark_en.png'),
    );
  });
}
