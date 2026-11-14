import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../theme/app_preferences.dart';
import '../theme/app_theme.dart';
import '../widgets/guild_motif.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key, required this.preferences});

  final AppPreferences preferences;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(strings.settings)),
      body: SafeArea(
        top: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: ListView(
              padding: const EdgeInsets.all(TaverinnSpace.x4),
              children: [
                Text(strings.settingsSubtitle,
                    style: theme.textTheme.bodyLarge),
                const SizedBox(height: TaverinnSpace.x6),
                Text(
                  strings.appearance,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: TaverinnSpace.x2),
                const GuildRule(),
                const SizedBox(height: TaverinnSpace.x3),
                _PreferenceGroup(
                  key: const ValueKey('settings_theme'),
                  title: strings.theme,
                  description: strings.themeDescription,
                  children: [
                    RadioGroup<TaverinnThemePreference>(
                      groupValue: preferences.themePreference,
                      onChanged: (value) {
                        if (value != null) {
                          preferences.setThemePreference(value);
                        }
                      },
                      child: Column(
                        children: [
                          _ThemeOption(
                            key: const ValueKey('settings_system_theme'),
                            value: TaverinnThemePreference.system,
                            groupValue: preferences.themePreference,
                            label: strings.systemTheme,
                            onChanged: preferences.setThemePreference,
                          ),
                          _ThemeOption(
                            key: const ValueKey('settings_light_theme'),
                            value: TaverinnThemePreference.light,
                            groupValue: preferences.themePreference,
                            label: strings.lightTheme,
                            onChanged: preferences.setThemePreference,
                          ),
                          _ThemeOption(
                            key: const ValueKey('settings_dark_theme'),
                            value: TaverinnThemePreference.dark,
                            groupValue: preferences.themePreference,
                            label: strings.darkTheme,
                            onChanged: preferences.setThemePreference,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: TaverinnSpace.x6),
                _PreferenceGroup(
                  key: const ValueKey('settings_language'),
                  title: strings.language,
                  description: strings.languageDescription,
                  children: [
                    RadioGroup<String>(
                      groupValue: preferences.languageCode,
                      onChanged: (value) {
                        if (value != null) preferences.setLanguageCode(value);
                      },
                      child: Column(
                        children: [
                          _LanguageOption(
                            key: const ValueKey('settings_indonesian'),
                            value: 'id',
                            groupValue: preferences.languageCode,
                            label: strings.indonesian,
                            onChanged: preferences.setLanguageCode,
                          ),
                          _LanguageOption(
                            key: const ValueKey('settings_english'),
                            value: 'en',
                            groupValue: preferences.languageCode,
                            label: strings.english,
                            onChanged: preferences.setLanguageCode,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PreferenceGroup extends StatelessWidget {
  const _PreferenceGroup(
      {super.key,
      required this.title,
      required this.description,
      required this.children});

  final String title;
  final String description;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: theme.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: TaverinnSpace.x1),
        Text(description,
            style: theme.textTheme.bodyMedium
                ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
        const SizedBox(height: TaverinnSpace.x2),
        ...children,
      ],
    );
  }
}

class _ThemeOption extends StatelessWidget {
  const _ThemeOption({
    super.key,
    required this.value,
    required this.groupValue,
    required this.label,
    required this.onChanged,
  });

  final TaverinnThemePreference value;
  final TaverinnThemePreference groupValue;
  final String label;
  final ValueChanged<TaverinnThemePreference> onChanged;

  @override
  Widget build(BuildContext context) {
    final selected = value == groupValue;
    return MergeSemantics(
      child: Semantics(
        selected: selected,
        child: InkWell(
          onTap: () => onChanged(value),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: TaverinnSpace.x2),
            child: Row(
              children: [
                Expanded(
                    child: Text(label,
                        style: Theme.of(context).textTheme.bodyLarge)),
                Radio<TaverinnThemePreference>(value: value),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LanguageOption extends StatelessWidget {
  const _LanguageOption({
    super.key,
    required this.value,
    required this.groupValue,
    required this.label,
    required this.onChanged,
  });

  final String value;
  final String groupValue;
  final String label;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final selected = value == groupValue;
    return MergeSemantics(
      child: Semantics(
        selected: selected,
        child: InkWell(
          onTap: () => onChanged(value),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: TaverinnSpace.x2),
            child: Row(
              children: [
                Expanded(
                    child: Text(label,
                        style: Theme.of(context).textTheme.bodyLarge)),
                Radio<String>(value: value),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
