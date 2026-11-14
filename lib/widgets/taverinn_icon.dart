import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../theme/app_theme.dart';

/// Displays an original Taverinn SVG with its source colors and proportions.
class TaverinnIcon extends StatelessWidget {
  const TaverinnIcon({
    super.key,
    required this.assetPath,
    this.size = TaverinnIconSize.action,
    this.width,
    this.height,
    this.semanticLabel,
    this.opacity = 1,
  });

  final String assetPath;
  final double size;
  final double? width;
  final double? height;
  final String? semanticLabel;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: opacity,
      child: SvgPicture.asset(
        assetPath,
        width: width ?? size,
        height: height ?? size,
        fit: BoxFit.contain,
        semanticsLabel: semanticLabel,
        excludeFromSemantics: semanticLabel == null,
      ),
    );
  }
}

class TaverinnBackButton extends StatelessWidget {
  const TaverinnBackButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => IconButton(
        tooltip: label,
        onPressed: onPressed,
        icon: TaverinnIcon(
          assetPath: 'assets/icons/back.svg',
          semanticLabel: label,
        ),
      );
}
