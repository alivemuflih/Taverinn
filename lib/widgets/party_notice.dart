import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../theme/app_theme.dart';
import 'guild_motif.dart';

class PartyNotice extends StatelessWidget {
  const PartyNotice({
    super.key,
    required this.gameName,
    required this.rank,
    required this.mode,
    required this.language,
    required this.currentPlayers,
    required this.maxPlayers,
    required this.isOpen,
    required this.description,
    required this.onTap,
    this.host,
    this.playTime,
  });

  final String gameName;
  final String rank;
  final String mode;
  final String language;
  final int currentPlayers;
  final int maxPlayers;
  final String? host;
  final bool isOpen;
  final String description;
  final String? playTime;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final strings = AppLocalizations.of(context);
    final metadata = [
      mode,
      rank,
      language,
      if (playTime?.isNotEmpty == true) playTime!
    ].where((value) => value.trim().isNotEmpty && value != '-').toList();

    return Material(
      color: colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(TaverinnRadius.compact),
        side: BorderSide(color: colors.outline),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(TaverinnRadius.compact),
        child: Padding(
          padding: const EdgeInsets.all(TaverinnSpace.x4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const TaverinnSeal(size: 28),
                  const SizedBox(width: TaverinnSpace.x3),
                  Expanded(
                    child: Text(
                      gameName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontFamily: 'serif',
                            fontSize: 21,
                          ),
                    ),
                  ),
                  const SizedBox(width: TaverinnSpace.x2),
                  _OpenLabel(isOpen: isOpen),
                ],
              ),
              const SizedBox(height: TaverinnSpace.x3),
              Wrap(
                spacing: TaverinnSpace.x2,
                runSpacing: TaverinnSpace.x1,
                children: [
                  for (var index = 0; index < metadata.length; index++) ...[
                    if (index > 0)
                      Text(
                        '·',
                        style: TextStyle(color: colors.primary),
                      ),
                    Text(metadata[index]),
                  ],
                ],
              ),
              if (description.trim().isNotEmpty) ...[
                const SizedBox(height: TaverinnSpace.x3),
                Text(
                  description,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
              const Padding(
                padding: EdgeInsets.symmetric(vertical: TaverinnSpace.x3),
                child: GuildRule(),
              ),
              Wrap(
                spacing: TaverinnSpace.x4,
                runSpacing: TaverinnSpace.x1,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    strings.playerCount(currentPlayers, maxPlayers),
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  if (host?.isNotEmpty == true)
                    Text(
                      strings.hostName(host!),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OpenLabel extends StatelessWidget {
  const _OpenLabel({required this.isOpen});

  final bool isOpen;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    final color = isOpen ? colors.tertiary : colors.error;
    final label = isOpen ? strings.open : strings.full;
    return Semantics(
      label: isOpen ? strings.open : strings.partyFull,
      child: ExcludeSemantics(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isOpen ? Icons.circle_outlined : Icons.circle,
              size: 10,
              color: color,
            ),
            const SizedBox(width: TaverinnSpace.x1),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
