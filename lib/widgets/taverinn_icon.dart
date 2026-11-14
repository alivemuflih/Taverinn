import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Shared sizing and semantics wrapper for the icon family currently in use.
/// Swap the renderer to official Taverinn assets once that icon kit is present.
class TaverinnIcon extends StatelessWidget {
  const TaverinnIcon({
    super.key,
    required this.icon,
    this.size = TaverinnIconSize.action,
    this.color,
    this.semanticLabel,
  });

  final IconData icon;
  final double size;
  final Color? color;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) => Icon(
        icon,
        size: size,
        color: color,
        semanticLabel: semanticLabel,
      );
}
