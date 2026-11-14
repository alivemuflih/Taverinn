import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'l10n/app_localizations.dart';
import 'screens/auth_screen.dart';
import 'screens/main_screen.dart';
import 'theme/app_theme.dart';
import 'theme/app_preferences.dart';

const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final preferences = await AppPreferences.load();

  if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
    runApp(MissingConfigApp(preferences: preferences));
    return;
  }

  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );

  runApp(TaverinnApp(preferences: preferences));
}

class TaverinnApp extends StatelessWidget {
  const TaverinnApp({super.key, required this.preferences});

  final AppPreferences preferences;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: preferences,
      builder: (context, _) => MaterialApp(
        title: 'Taverinn',
        debugShowCheckedModeBanner: false,
        theme: TaverinnTheme.light,
        darkTheme: TaverinnTheme.dark,
        themeMode: preferences.themeMode,
        locale: preferences.locale,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        localeResolutionCallback: (locale, supported) {
          if (locale == null) return const Locale('id');
          return supported.firstWhere(
            (item) => item.languageCode == locale.languageCode,
            orElse: () => const Locale('en'),
          );
        },
        builder: (context, child) => AppPreferencesScope(
          preferences: preferences,
          child: child ?? const SizedBox.shrink(),
        ),
        home: const AuthGate(),
      ),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final session = Supabase.instance.client.auth.currentSession;
    return session == null ? const AuthScreen() : const MainScreen();
  }
}

class MissingConfigApp extends StatelessWidget {
  const MissingConfigApp({super.key, required this.preferences});

  final AppPreferences preferences;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: preferences,
      builder: (context, _) => MaterialApp(
        theme: TaverinnTheme.light,
        darkTheme: TaverinnTheme.dark,
        themeMode: preferences.themeMode,
        locale: preferences.locale,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                AppLocalizations.of(context).missingSupabase,
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
        builder: (context, child) => AppPreferencesScope(
          preferences: preferences,
          child: child ?? const SizedBox.shrink(),
        ),
      ),
    );
  }
}
