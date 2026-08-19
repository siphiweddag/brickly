import 'dart:math' as math;

import 'package:flutter/material.dart';

abstract final class ArcadeColors {
  static const navy = Color(0xFF071A4A);
  static const deepBlue = Color(0xFF082B73);
  static const royalBlue = Color(0xFF064EB4);
  static const cyan = Color(0xFF27CFFF);
  static const sky = Color(0xFF7AE5FF);
  static const yellow = Color(0xFFFFC928);
  static const orange = Color(0xFFFF8A16);
  static const green = Color(0xFF2BDE72);
  static const white = Color(0xFFF6FAFF);
  static const muted = Color(0xFFA8C7F0);
}

enum ArcadeBackgroundStyle {
  classic('Classic Blue', Icons.auto_awesome_rounded),
  frost('Frost Field', Icons.ac_unit_rounded),
  sunset('Sunset Rush', Icons.wb_twilight_rounded),
  midnight('Neon Night', Icons.bolt_rounded);

  const ArcadeBackgroundStyle(this.label, this.icon);
  final String label;
  final IconData icon;
}

enum BlockSkinStyle {
  glossy('Glossy', Icons.square_rounded),
  candy('Candy Pop', Icons.bubble_chart_rounded),
  ice('Crystal Ice', Icons.diamond_rounded),
  neon('Neon Edge', Icons.grid_4x4_rounded);

  const BlockSkinStyle(this.label, this.icon);
  final String label;
  final IconData icon;
}

class ArcadeBackground extends StatelessWidget {
  const ArcadeBackground({
    super.key,
    required this.child,
    this.padding,
    this.style = ArcadeBackgroundStyle.classic,
  });

  final Widget child;
  final EdgeInsets? padding;
  final ArcadeBackgroundStyle style;

  List<Color> get _colors => switch (style) {
    ArcadeBackgroundStyle.classic => const [
      Color(0xFF071943),
      Color(0xFF06419A),
    ],
    ArcadeBackgroundStyle.frost => const [Color(0xFF063154), Color(0xFF087E9B)],
    ArcadeBackgroundStyle.sunset => const [
      Color(0xFF31145E),
      Color(0xFFB33B58),
    ],
    ArcadeBackgroundStyle.midnight => const [
      Color(0xFF070A24),
      Color(0xFF21135E),
    ],
  };

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: _colors,
        ),
      ),
      child: CustomPaint(
        painter: _ThemePainter(style),
        child: Padding(padding: padding ?? EdgeInsets.zero, child: child),
      ),
    );
  }
}

class _ThemePainter extends CustomPainter {
  const _ThemePainter(this.style);
  final ArcadeBackgroundStyle style;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    if (style == ArcadeBackgroundStyle.frost) {
      for (var i = 0; i < 30; i++) {
        final x = ((i * 83) % math.max(1, size.width.toInt())).toDouble();
        final y = ((i * 131) % math.max(1, size.height.toInt())).toDouble();
        paint.color = Colors.white.withValues(alpha: i.isEven ? .22 : .1);
        canvas.drawCircle(Offset(x, y), i % 3 + 1.2, paint);
      }
    }
    const cubeSize = 74.0;
    for (var i = 0; i < 12; i++) {
      final x = ((i * 97) % math.max(1, size.width.toInt())).toDouble() - 24;
      final y = 90.0 + i * 83;
      if (y > size.height) break;
      final accent = switch (style) {
        ArcadeBackgroundStyle.sunset =>
          i.isEven ? ArcadeColors.orange : const Color(0xFFFF4B8A),
        ArcadeBackgroundStyle.midnight =>
          i.isEven ? const Color(0xFFB64CFF) : ArcadeColors.cyan,
        _ => i.isEven ? ArcadeColors.cyan : ArcadeColors.royalBlue,
      };
      paint.color = accent.withValues(
        alpha: style == ArcadeBackgroundStyle.midnight ? .09 : .055,
      );
      final path = Path()
        ..moveTo(x, y)
        ..lineTo(x + cubeSize / 2, y - cubeSize / 4)
        ..lineTo(x + cubeSize, y)
        ..lineTo(x + cubeSize / 2, y + cubeSize / 4)
        ..close();
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ThemePainter oldDelegate) =>
      oldDelegate.style != style;
}

BoxDecoration blockDecoration(
  Color color,
  BlockSkinStyle skin, {
  double radius = 7,
  bool preview = false,
}) {
  final border = switch (skin) {
    BlockSkinStyle.candy => Border.all(
      color: Colors.white.withValues(alpha: .5),
      width: 1.5,
    ),
    BlockSkinStyle.ice => Border.all(
      color: const Color(0xFFDDFBFF).withValues(alpha: .8),
      width: 1.5,
    ),
    BlockSkinStyle.neon => Border.all(
      color: color.withValues(alpha: .95),
      width: 2,
    ),
    BlockSkinStyle.glossy => null,
  };
  final fill = skin == BlockSkinStyle.neon ? const Color(0xFF10153A) : color;
  return BoxDecoration(
    color: fill,
    gradient: skin == BlockSkinStyle.ice
        ? LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withValues(alpha: .72),
              color.withValues(alpha: .95),
            ],
          )
        : skin == BlockSkinStyle.candy
        ? LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color.lerp(color, Colors.white, .28)!, color],
          )
        : null,
    borderRadius: BorderRadius.circular(
      skin == BlockSkinStyle.candy ? radius * 1.55 : radius,
    ),
    border: border,
    boxShadow: [
      BoxShadow(
        color: skin == BlockSkinStyle.neon
            ? color.withValues(alpha: .75)
            : color.withValues(alpha: preview ? .22 : .38),
        blurRadius: skin == BlockSkinStyle.neon ? 9 : 5,
        offset: const Offset(0, 2),
      ),
      if (skin != BlockSkinStyle.neon)
        BoxShadow(
          color: Colors.white.withValues(
            alpha: skin == BlockSkinStyle.ice ? .5 : .22,
          ),
          offset: const Offset(0, -1),
        ),
    ],
  );
}

class PlayerBar extends StatelessWidget {
  const PlayerBar({super.key, required this.onSettings});
  final VoidCallback onSettings;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 76,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0x8A063D91),
        border: Border(
          bottom: BorderSide(
            color: ArcadeColors.cyan.withValues(alpha: .55),
            width: 2,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [ArcadeColors.cyan, ArcadeColors.green],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: ArcadeColors.white, width: 2),
            ),
            child: const Icon(
              Icons.grid_view_rounded,
              color: ArcadeColors.navy,
              size: 29,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'BRICKLY BREAK',
                  style: Theme.of(context).textTheme.titleMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  'BY STRATIDA',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: ArcadeColors.sky,
                    letterSpacing: 1.6,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          IconButton.filled(
            onPressed: onSettings,
            tooltip: 'Settings',
            style: IconButton.styleFrom(
              backgroundColor: const Color(0xFF078BDA),
              side: const BorderSide(color: ArcadeColors.cyan, width: 2),
            ),
            icon: const Icon(Icons.settings_rounded),
          ),
        ],
      ),
    );
  }
}

class ArcadeButton extends StatelessWidget {
  const ArcadeButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
    this.enabled = true,
  });

  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 68,
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: enabled ? onPressed : null,
        style: FilledButton.styleFrom(
          backgroundColor: ArcadeColors.yellow,
          disabledBackgroundColor: const Color(0xFF5B6C98),
          foregroundColor: ArcadeColors.navy,
          disabledForegroundColor: ArcadeColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: BorderSide(
              color: enabled ? ArcadeColors.orange : ArcadeColors.muted,
              width: 3,
            ),
          ),
          elevation: 8,
          shadowColor: Colors.black54,
        ),
        icon: Icon(icon, size: 32),
        label: Text(
          label,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: enabled ? ArcadeColors.navy : ArcadeColors.white,
          ),
        ),
      ),
    );
  }
}

class ArcadeBottomNav extends StatelessWidget {
  const ArcadeBottomNav({
    super.key,
    required this.index,
    required this.onChanged,
  });

  final int index;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0567A8), Color(0xFF064F8E)],
        ),
        border: Border(
          top: BorderSide(
            color: ArcadeColors.cyan.withValues(alpha: .7),
            width: 2,
          ),
        ),
      ),
      child: NavigationBar(
        height: MediaQuery.textScalerOf(
          context,
        ).scale(76).clamp(76, 92).toDouble(),
        selectedIndex: index,
        onDestinationSelected: onChanged,
        backgroundColor: Colors.transparent,
        indicatorColor: ArcadeColors.yellow.withValues(alpha: .22),
        labelTextStyle: WidgetStatePropertyAll(
          Theme.of(context).textTheme.labelLarge,
        ),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_rounded),
            selectedIcon: Icon(Icons.home_rounded, color: ArcadeColors.yellow),
            label: 'Lobby',
          ),
          NavigationDestination(
            icon: Icon(Icons.inventory_2_rounded),
            selectedIcon: Icon(
              Icons.inventory_2_rounded,
              color: ArcadeColors.yellow,
            ),
            label: 'Inventory',
          ),
        ],
      ),
    );
  }
}

class ArcadeFrame extends StatelessWidget {
  const ArcadeFrame({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: ArcadeColors.sky, width: 3),
        boxShadow: const [BoxShadow(color: Colors.black38, blurRadius: 20)],
      ),
      clipBehavior: Clip.antiAlias,
      child: child,
    );
  }
}
