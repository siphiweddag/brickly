import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'arcade_ui.dart';
import 'game_screen.dart';

@immutable
class CampaignLevel {
  const CampaignLevel({
    required this.number,
    required this.targetLines,
    required this.parMoves,
    required this.prefillRows,
  });

  final int number;
  final int targetLines;
  final int parMoves;
  final int prefillRows;

  String get chapter => switch ((number - 1) ~/ 10) {
    0 => 'First Breaks',
    1 => 'Stack School',
    2 => 'Gravity Lab',
    3 => 'Combo Works',
    _ => 'Brickly Masters',
  };

  static List<CampaignLevel> get all => List.generate(50, (index) {
    final number = index + 1;
    // A Journey level should require a real run, not end after the player's
    // first successful row. The target increases every two levels so players
    // get one opportunity to consolidate each new difficulty step.
    final targetLines = 5 + index ~/ 2;
    final prefillRows = math.min(4, index ~/ 10);
    return CampaignLevel(
      number: number,
      targetLines: targetLines,
      parMoves: targetLines * 4 + 4 + prefillRows * 2,
      prefillRows: prefillRows,
    );
  });
}

class CampaignProgress {
  static const _unlockedKey = 'campaign_highest_unlocked_v1';

  static Future<int> highestUnlocked() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getInt(_unlockedKey) ?? 1).clamp(1, 50);
  }

  static Future<int> starsFor(int level) async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getInt('campaign_stars_$level') ?? 0).clamp(0, 3);
  }

  static Future<void> complete(CampaignLevel level, int stars) async {
    final prefs = await SharedPreferences.getInstance();
    final currentStars = prefs.getInt('campaign_stars_${level.number}') ?? 0;
    if (stars > currentStars) {
      await prefs.setInt('campaign_stars_${level.number}', stars);
    }
    final currentUnlocked = prefs.getInt(_unlockedKey) ?? 1;
    final next = math.min(50, level.number + 1);
    if (next > currentUnlocked) await prefs.setInt(_unlockedKey, next);
  }

  static Future<void> reset() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_unlockedKey);
    for (var level = 1; level <= 50; level++) {
      await prefs.remove('campaign_stars_$level');
    }
  }
}

class LevelSelectScreen extends StatefulWidget {
  const LevelSelectScreen({
    super.key,
    required this.backgroundStyle,
    required this.blockSkin,
  });

  final ArcadeBackgroundStyle backgroundStyle;
  final BlockSkinStyle blockSkin;

  @override
  State<LevelSelectScreen> createState() => _LevelSelectScreenState();
}

class _LevelSelectScreenState extends State<LevelSelectScreen> {
  int _highestUnlocked = 1;
  final Map<int, int> _stars = {};

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final unlocked = await CampaignProgress.highestUnlocked();
    final starValues = await Future.wait(
      CampaignLevel.all.map((level) => CampaignProgress.starsFor(level.number)),
    );
    if (!mounted) return;
    setState(() {
      _highestUnlocked = unlocked;
      for (var i = 0; i < starValues.length; i++) {
        _stars[i + 1] = starValues[i];
      }
    });
  }

  Future<void> _openLevel(CampaignLevel level) async {
    final nextLevel = await Navigator.of(context).push<int>(
      MaterialPageRoute<int>(
        builder: (_) => GameScreen(
          campaignLevel: level,
          backgroundStyle: widget.backgroundStyle,
          blockSkin: widget.blockSkin,
        ),
      ),
    );
    await _loadProgress();
    if (nextLevel != null && mounted) {
      final next = CampaignLevel.all[nextLevel - 1];
      await _openLevel(next);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ArcadeColors.navy,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: ArcadeFrame(
            child: ArcadeBackground(
              style: widget.backgroundStyle,
              child: Column(
                children: [
                  _header(context),
                  Expanded(
                    child: GridView.builder(
                      key: const ValueKey('level-grid'),
                      padding: const EdgeInsets.fromLTRB(18, 18, 18, 28),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 4,
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                            childAspectRatio: .82,
                          ),
                      itemCount: CampaignLevel.all.length,
                      itemBuilder: (context, index) {
                        final level = CampaignLevel.all[index];
                        final locked = level.number > _highestUnlocked;
                        final stars = _stars[level.number] ?? 0;
                        return _LevelTile(
                          level: level,
                          stars: stars,
                          locked: locked,
                          onTap: locked ? null : () => _openLevel(level),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _header(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.fromLTRB(8, 10, 16, 12),
    decoration: BoxDecoration(
      color: const Color(0xB3062B70),
      border: Border(
        bottom: BorderSide(
          color: ArcadeColors.cyan.withValues(alpha: .7),
          width: 2,
        ),
      ),
    ),
    child: Row(
      children: [
        IconButton(
          onPressed: () => Navigator.pop(context),
          tooltip: 'Back to lobby',
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'BRICKLY JOURNEY',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              Text(
                '50 levels · Clear rows · Earn stars',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: ArcadeColors.white),
              ),
            ],
          ),
        ),
        Text(
          '$_highestUnlocked/50',
          style: Theme.of(
            context,
          ).textTheme.labelLarge?.copyWith(color: ArcadeColors.yellow),
        ),
      ],
    ),
  );
}

class _LevelTile extends StatelessWidget {
  const _LevelTile({
    required this.level,
    required this.stars,
    required this.locked,
    required this.onTap,
  });

  final CampaignLevel level;
  final int stars;
  final bool locked;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: !locked,
      label: locked
          ? 'Level ${level.number}, locked'
          : 'Level ${level.number}, $stars stars, clear ${level.targetLines} rows',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Ink(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: locked
                    ? const [Color(0xFF263A66), Color(0xFF14264D)]
                    : const [Color(0xFF087FCA), Color(0xFF06458F)],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: locked
                    ? ArcadeColors.muted.withValues(alpha: .45)
                    : ArcadeColors.cyan,
                width: 2,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (locked)
                  const Icon(Icons.lock_rounded, color: ArcadeColors.muted)
                else
                  Text(
                    '${level.number}',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                const SizedBox(height: 5),
                if (!locked)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      3,
                      (index) => Icon(
                        index < stars
                            ? Icons.star_rounded
                            : Icons.star_border_rounded,
                        size: 15,
                        color: index < stars
                            ? ArcadeColors.yellow
                            : ArcadeColors.muted,
                      ),
                    ),
                  ),
                const SizedBox(height: 3),
                Text(
                  locked
                      ? 'LOCKED'
                      : '${level.targetLines} ROW${level.targetLines == 1 ? '' : 'S'}',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: locked ? ArcadeColors.muted : ArcadeColors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
