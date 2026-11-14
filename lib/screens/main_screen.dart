import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../theme/app_theme.dart';
import '../widgets/guild_motif.dart';
import '../widgets/taverinn_icon.dart';
import 'home_screen.dart';
import 'create_lfg_screen.dart';
import 'party_screen.dart';
import 'profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int index = 0;

  final pages = const [
    HomeScreen(),
    CreateLfgScreen(),
    PartyScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final pageStack = IndexedStack(index: index, children: pages);
        if (constraints.maxWidth >= 840) {
          return Scaffold(
            body: Row(
              children: [
                NavigationRail(
                  key: const ValueKey('main_navigation_rail'),
                  selectedIndex: index,
                  onDestinationSelected: (value) =>
                      setState(() => index = value),
                  labelType: NavigationRailLabelType.all,
                  minWidth: 76,
                  backgroundColor: Theme.of(context).colorScheme.surface,
                  indicatorColor: Colors.transparent,
                  selectedIconTheme: IconThemeData(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  unselectedIconTheme: IconThemeData(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  selectedLabelTextStyle: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                  unselectedLabelTextStyle: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  leading: const Padding(
                    padding: EdgeInsets.symmetric(vertical: TaverinnSpace.x4),
                    child: TaverinnSeal(size: 30),
                  ),
                  destinations: [
                    NavigationRailDestination(
                      icon: _NavIcon(Icons.home_outlined),
                      selectedIcon: _NavIcon(Icons.home, selected: true),
                      label: Text(strings.home),
                    ),
                    NavigationRailDestination(
                      icon: _NavIcon(Icons.add_circle_outline),
                      selectedIcon: _NavIcon(Icons.add_circle, selected: true),
                      label: Text(strings.create),
                    ),
                    NavigationRailDestination(
                      icon: _NavIcon(Icons.groups_outlined),
                      selectedIcon: _NavIcon(Icons.groups, selected: true),
                      label: Text(strings.party),
                    ),
                    NavigationRailDestination(
                      icon: _NavIcon(Icons.person_outline),
                      selectedIcon: _NavIcon(Icons.person, selected: true),
                      label: Text(strings.profile),
                    ),
                  ],
                ),
                const VerticalDivider(width: 1),
                Expanded(child: pageStack),
              ],
            ),
          );
        }

        return Scaffold(
          body: pageStack,
          bottomNavigationBar: NavigationBar(
            key: const ValueKey('main_navigation'),
            selectedIndex: index,
            onDestinationSelected: (value) => setState(() => index = value),
            destinations: [
              NavigationDestination(
                key: ValueKey('main_navigation_home'),
                icon: _NavIcon(Icons.home_outlined),
                selectedIcon: _NavIcon(Icons.home, selected: true),
                label: strings.home,
              ),
              NavigationDestination(
                key: ValueKey('main_navigation_create'),
                icon: _NavIcon(Icons.add_circle_outline),
                selectedIcon: _NavIcon(Icons.add_circle, selected: true),
                label: strings.create,
              ),
              NavigationDestination(
                key: ValueKey('main_navigation_party'),
                icon: _NavIcon(Icons.groups_outlined),
                selectedIcon: _NavIcon(Icons.groups, selected: true),
                label: strings.party,
              ),
              NavigationDestination(
                key: ValueKey('main_navigation_profile'),
                icon: _NavIcon(Icons.person_outline),
                selectedIcon: _NavIcon(Icons.person, selected: true),
                label: strings.profile,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _NavIcon extends StatelessWidget {
  const _NavIcon(this.icon, {this.selected = false});

  final IconData icon;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final color = selected ? colors.onSurface : colors.onSurfaceVariant;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TaverinnIcon(
          icon: icon,
          size: TaverinnIconSize.navigation,
          color: color,
        ),
        const SizedBox(height: 3),
        Container(
          width: 18,
          height: 2,
          color: selected ? colors.primary : Colors.transparent,
        ),
      ],
    );
  }
}
