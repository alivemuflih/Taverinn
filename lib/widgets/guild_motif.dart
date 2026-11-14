import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class TaverinnSeal extends StatelessWidget {
  const TaverinnSeal({super.key, this.size = 36});

  final double size;

  @override
  Widget build(BuildContext context) {
    final sealColor = Theme.of(context).colorScheme.primary;
    return ExcludeSemantics(
      child: SizedBox.square(
        dimension: size,
        child: CustomPaint(
          painter: _SealPainter(color: sealColor),
          child: Center(
            child: Text(
              'T',
              style: TextStyle(
                color: sealColor,
                fontFamily: 'serif',
                fontSize: size * 0.55,
                fontWeight: FontWeight.w600,
                height: 1,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class GuildRule extends StatelessWidget {
  const GuildRule({super.key, this.color});

  final Color? color;

  @override
  Widget build(BuildContext context) {
    final ruleColor = color ?? Theme.of(context).colorScheme.outline;
    return ExcludeSemantics(
      child: Row(
        children: [
          Expanded(child: Divider(color: ruleColor)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: TaverinnSpace.x2),
            child: Transform.rotate(
              angle: 0.785398,
              child: Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  border: Border.all(color: ruleColor, width: 1),
                ),
              ),
            ),
          ),
          Expanded(child: Divider(color: ruleColor)),
        ],
      ),
    );
  }
}

class _SealPainter extends CustomPainter {
  const _SealPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final cut = size.width * 0.18;
    final path = Path()
      ..moveTo(cut, 1)
      ..lineTo(size.width - cut, 1)
      ..lineTo(size.width - 1, cut)
      ..lineTo(size.width - 1, size.height - cut)
      ..lineTo(size.width - cut, size.height - 1)
      ..lineTo(cut, size.height - 1)
      ..lineTo(1, size.height - cut)
      ..lineTo(1, cut)
      ..close();
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4,
    );
  }

  @override
  bool shouldRepaint(covariant _SealPainter oldDelegate) =>
      oldDelegate.color != color;
}
