import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'arcade_ui.dart';
import 'campaign.dart';
import 'game_screen.dart';
import 'release_info.dart';

class BricklyHome extends StatefulWidget {
  const BricklyHome({super.key});

  @override
  State<BricklyHome> createState() => _BricklyHomeState();
}

class _BricklyHomeState extends State<BricklyHome> {
  int _tab = 0;
  ArcadeBackgroundStyle _background = ArcadeBackgroundStyle.classic;
  BlockSkinStyle _blockSkin = BlockSkinStyle.glossy;

  @override
  void initState() {
    super.initState();
    _loadStyle();
  }

  Future<void> _loadStyle() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _background =
          ArcadeBackgroundStyle.values[prefs
                  .getInt('background_style')
                  ?.clamp(0, ArcadeBackgroundStyle.values.length - 1) ??
              0];
      _blockSkin =
          BlockSkinStyle.values[prefs
                  .getInt('block_skin')
                  ?.clamp(0, BlockSkinStyle.values.length - 1) ??
              0];
    });
  }

  Future<void> _setBackground(ArcadeBackgroundStyle value) async {
    setState(() => _background = value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('background_style', value.index);
  }

  Future<void> _setBlockSkin(BlockSkinStyle value) async {
    setState(() => _blockSkin = value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('block_skin', value.index);
  }

  void _openSettings() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const SettingsScreen()));
  }

  Future<bool> _ensureTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool('tutorial_seen_v1') == true) return true;
    if (!mounted) return false;
    return await Navigator.of(context).push<bool>(
          MaterialPageRoute<bool>(
            builder: (_) => const HowToPlayScreen(firstRun: true),
          ),
        ) ??
        false;
  }

  Future<void> _startClassic() async {
    if (!await _ensureTutorial() || !mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => GameScreen(
          backgroundStyle: _background,
          blockSkin: _blockSkin,
          onExit: () => Navigator.of(context).pop(),
        ),
      ),
    );
  }

  Future<void> _startJourney() async {
    if (!await _ensureTutorial() || !mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => LevelSelectScreen(
          backgroundStyle: _background,
          blockSkin: _blockSkin,
        ),
      ),
    );
  }

  void _openHowToPlay() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const HowToPlayScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ArcadeColors.navy,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: ArcadeFrame(
            child: Column(
              children: [
                PlayerBar(onSettings: _openSettings),
                Expanded(
                  child: IndexedStack(
                    index: _tab,
                    children: [
                      _LobbyPage(
                        onJourney: _startJourney,
                        onClassic: _startClassic,
                        onHowToPlay: _openHowToPlay,
                        background: _background,
                      ),
                      _InventoryPage(
                        background: _background,
                        blockSkin: _blockSkin,
                        onBackgroundChanged: _setBackground,
                        onBlockSkinChanged: _setBlockSkin,
                      ),
                    ],
                  ),
                ),
                ArcadeBottomNav(
                  index: _tab,
                  onChanged: (value) => setState(() => _tab = value),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LobbyPage extends StatelessWidget {
  const _LobbyPage({
    required this.onJourney,
    required this.onClassic,
    required this.onHowToPlay,
    required this.background,
  });
  final VoidCallback onJourney;
  final VoidCallback onClassic;
  final VoidCallback onHowToPlay;
  final ArcadeBackgroundStyle background;

  @override
  Widget build(BuildContext context) {
    return ArcadeBackground(
      style: background,
      child: LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight - 52),
            child: Column(
              children: [
                const SizedBox(height: 6),
                const _BricklyLogo(),
                const SizedBox(height: 14),
                Text(
                  'BUILD THE ROW. BREAK THE LINE.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: ArcadeColors.white,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 32),
                ArcadeButton(
                  label: 'BRICKLY JOURNEY',
                  icon: Icons.emoji_events_rounded,
                  onPressed: onJourney,
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: OutlinedButton.icon(
                    onPressed: onClassic,
                    icon: const Icon(Icons.all_inclusive_rounded),
                    label: const Text('ENDLESS CLASSIC'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: ArcadeColors.white,
                      side: const BorderSide(
                        color: ArcadeColors.cyan,
                        width: 2,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                _HowToPlay(onOpen: onHowToPlay),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BricklyLogo extends StatelessWidget {
  const _BricklyLogo();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      header: true,
      label: 'Brickly Break by Stratida',
      child: Column(
        children: [
          Container(
            width: 82,
            height: 42,
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: const Color(0xFF031B4B),
              borderRadius: BorderRadius.circular(13),
              border: Border.all(color: ArcadeColors.cyan, width: 2),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black38,
                  blurRadius: 10,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              children: const [
                Expanded(child: _LogoBrick(color: ArcadeColors.cyan)),
                SizedBox(width: 4),
                Expanded(child: _LogoBrick(color: ArcadeColors.yellow)),
                SizedBox(width: 4),
                Expanded(child: _LogoBrick(color: Color(0xFFFF4B73))),
              ],
            ),
          ),
          const SizedBox(height: 5),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [
                  ArcadeColors.cyan,
                  ArcadeColors.green,
                  ArcadeColors.yellow,
                ],
              ).createShader(bounds),
              child: Text(
                'BRICKLY',
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  color: Colors.white,
                  letterSpacing: -1,
                  shadows: const [
                    Shadow(
                      color: Color(0xFF001744),
                      blurRadius: 0,
                      offset: Offset(0, 6),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Container(
            transform: Matrix4.translationValues(0, -2, 0),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFF9D16), Color(0xFFFFC928)],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFFFE589), width: 2),
              boxShadow: const [
                BoxShadow(color: Color(0xFFA33000), offset: Offset(0, 5)),
              ],
            ),
            child: Text(
              'BREAK',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: ArcadeColors.navy,
                letterSpacing: 5,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'BY STRATIDA',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: ArcadeColors.sky,
              letterSpacing: 2.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _LogoBrick extends StatelessWidget {
  const _LogoBrick({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) => SizedBox.expand(
    child: DecoratedBox(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
        boxShadow: [
          BoxShadow(color: color.withValues(alpha: .45), blurRadius: 5),
        ],
      ),
    ),
  );
}

class _HowToPlay extends StatelessWidget {
  const _HowToPlay({required this.onOpen});
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xF005245F),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: ArcadeColors.cyan, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('HOW TO PLAY', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 14),
          const _RuleRow(number: '1', text: 'Drag a piece anywhere it fits.'),
          const SizedBox(height: 10),
          const _RuleRow(
            number: '2',
            text: 'Fill a horizontal row with no gaps.',
          ),
          const SizedBox(height: 10),
          const _RuleRow(
            number: '3',
            text: 'Earn 10 points for every block that breaks.',
          ),
          const SizedBox(height: 10),
          const _RuleRow(
            number: '4',
            text: 'Break rows before the stack reaches the top.',
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: TextButton.icon(
              onPressed: onOpen,
              icon: const Icon(Icons.school_rounded),
              label: const Text('OPEN FULL TUTORIAL'),
            ),
          ),
        ],
      ),
    );
  }
}

class _RuleRow extends StatelessWidget {
  const _RuleRow({required this.number, required this.text});
  final String number;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 30,
          height: 30,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: ArcadeColors.yellow,
          ),
          child: Text(
            number,
            style: Theme.of(
              context,
            ).textTheme.labelLarge?.copyWith(color: ArcadeColors.navy),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: ArcadeColors.white),
          ),
        ),
      ],
    );
  }
}

class _InventoryPage extends StatefulWidget {
  const _InventoryPage({
    required this.background,
    required this.blockSkin,
    required this.onBackgroundChanged,
    required this.onBlockSkinChanged,
  });

  final ArcadeBackgroundStyle background;
  final BlockSkinStyle blockSkin;
  final ValueChanged<ArcadeBackgroundStyle> onBackgroundChanged;
  final ValueChanged<BlockSkinStyle> onBlockSkinChanged;

  @override
  State<_InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<_InventoryPage> {
  int _section = 0;

  @override
  Widget build(BuildContext context) {
    final items = _section == 0
        ? ArcadeBackgroundStyle.values
        : BlockSkinStyle.values;
    final active = _section == 0
        ? widget.background.index
        : widget.blockSkin.index;
    return ArcadeBackground(
      style: widget.background,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 26, 20, 18),
            child: SegmentedButton<int>(
              segments: const [
                ButtonSegment(
                  value: 0,
                  label: Text('BACKGROUND'),
                  icon: Icon(Icons.wallpaper_rounded),
                ),
                ButtonSegment(
                  value: 1,
                  label: Text('BLOCK SKIN'),
                  icon: Icon(Icons.view_in_ar_rounded),
                ),
              ],
              selected: {_section},
              onSelectionChanged: (value) => setState(() {
                _section = value.first;
              }),
              style: ButtonStyle(
                foregroundColor: const WidgetStatePropertyAll(
                  ArcadeColors.white,
                ),
                backgroundColor: WidgetStateProperty.resolveWith(
                  (states) => states.contains(WidgetState.selected)
                      ? const Color(0xFF065F9E)
                      : const Color(0xB0061D59),
                ),
                side: const WidgetStatePropertyAll(
                  BorderSide(color: ArcadeColors.cyan),
                ),
                textStyle: WidgetStatePropertyAll(
                  Theme.of(context).textTheme.labelLarge,
                ),
              ),
            ),
          ),
          Text(
            _section == 0
                ? 'Choose the atmosphere for every screen.'
                : 'Choose how every placed brick looks.',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: ArcadeColors.white),
          ),
          const SizedBox(height: 14),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.fromLTRB(18, 6, 18, 24),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: .92,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
              ),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                final title = switch (item) {
                  ArcadeBackgroundStyle value => value.label,
                  BlockSkinStyle value => value.label,
                  _ => '',
                };
                final icon = switch (item) {
                  ArcadeBackgroundStyle value => value.icon,
                  BlockSkinStyle value => value.icon,
                  _ => Icons.square_rounded,
                };
                return _InventoryCard(
                  title: title,
                  icon: icon,
                  active: active == index,
                  previewBackground: _section == 0
                      ? item as ArcadeBackgroundStyle
                      : null,
                  previewSkin: _section == 1 ? item as BlockSkinStyle : null,
                  onTap: () {
                    if (_section == 0) {
                      widget.onBackgroundChanged(item as ArcadeBackgroundStyle);
                    } else {
                      widget.onBlockSkinChanged(item as BlockSkinStyle);
                    }
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _InventoryCard extends StatelessWidget {
  const _InventoryCard({
    required this.title,
    required this.icon,
    required this.active,
    required this.previewBackground,
    required this.previewSkin,
    required this.onTap,
  });
  final String title;
  final IconData icon;
  final bool active;
  final ArcadeBackgroundStyle? previewBackground;
  final BlockSkinStyle? previewSkin;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF087FCA), Color(0xFF06275F)],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: active ? ArcadeColors.green : ArcadeColors.cyan,
            width: active ? 3 : 2,
          ),
          boxShadow: const [
            BoxShadow(
              color: Colors.black38,
              blurRadius: 8,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: previewBackground != null
                    ? ArcadeBackground(
                        style: previewBackground!,
                        child: Center(
                          child: Icon(
                            icon,
                            size: 58,
                            color: ArcadeColors.white,
                          ),
                        ),
                      )
                    : Center(
                        child: Wrap(
                          spacing: 5,
                          runSpacing: 5,
                          children: [
                            for (final color in const [
                              ArcadeColors.cyan,
                              ArcadeColors.yellow,
                              ArcadeColors.green,
                              Color(0xFFFF4B73),
                            ])
                              Container(
                                width: 31,
                                height: 31,
                                decoration: blockDecoration(
                                  color,
                                  previewSkin!,
                                  radius: 7,
                                ),
                              ),
                          ],
                        ),
                      ),
              ),
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.center,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Color(0xE6031640)],
                  ),
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
            ),
            Positioned(
              left: 10,
              right: 10,
              bottom: 12,
              child: Text(
                title.toUpperCase(),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.labelLarge,
              ),
            ),
            if (active)
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: ArcadeColors.green,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'ACTIVE',
                    style: Theme.of(
                      context,
                    ).textTheme.labelSmall?.copyWith(color: ArcadeColors.navy),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _SettingsDialog extends StatefulWidget {
  const _SettingsDialog();

  @override
  State<_SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends State<_SettingsDialog> {
  bool _effects = true;
  bool _placementGuide = true;

  @override
  void initState() {
    super.initState();
    _loadEffects();
  }

  Future<void> _loadEffects() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _effects = prefs.getBool('effects') ?? true;
        _placementGuide = prefs.getBool('placement_guide') ?? true;
      });
    }
  }

  Future<void> _setEffects(bool value) async {
    setState(() => _effects = value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('effects', value);
  }

  Future<void> _setPlacementGuide(bool value) async {
    setState(() => _placementGuide = value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('placement_guide', value);
  }

  Future<void> _resetBestScore() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset best score?'),
        content: const Text(
          'This clears your saved high score. This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('CANCEL'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('RESET'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('best_score_v2');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF063478),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: const BorderSide(color: ArcadeColors.cyan, width: 2),
      ),
      title: Text(
        'SETTINGS',
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.headlineSmall,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: Icon(
              _effects ? Icons.volume_up_rounded : Icons.volume_off_rounded,
            ),
            title: const Text('Sound & haptics'),
            trailing: Switch(
              key: const ValueKey('effects-switch'),
              value: _effects,
              onChanged: _setEffects,
            ),
          ),
          ListTile(
            leading: Icon(
              _placementGuide
                  ? Icons.visibility_rounded
                  : Icons.visibility_off_rounded,
            ),
            title: const Text('Placement guide'),
            subtitle: const Text('Show a preview before you drop a piece'),
            trailing: Switch(
              key: const ValueKey('placement-guide-switch'),
              value: _placementGuide,
              onChanged: _setPlacementGuide,
            ),
          ),
          ListTile(
            onTap: _resetBestScore,
            leading: const Icon(
              Icons.restart_alt_rounded,
              color: ArcadeColors.yellow,
            ),
            title: const Text('Reset best score'),
            trailing: const Icon(Icons.chevron_right_rounded),
          ),
          const ListTile(
            leading: Icon(Icons.info_outline_rounded),
            title: Text('Brickly Break'),
            subtitle: Text('by Stratida · v1.0.0'),
          ),
        ],
      ),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        FilledButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('DONE'),
        ),
      ],
    );
  }
}
