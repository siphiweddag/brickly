import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import 'arcade_ui.dart';
import 'campaign.dart';

abstract final class StratidaLinks {
  static final terms = Uri.parse('https://stratida.com/terms-of-service/');
  static final privacy = Uri.parse('https://stratida.com/privacy-policy/');
  static final website = Uri.parse('https://stratida.com/');
  static final contact = Uri.parse('mailto:hello@stratida.com');
  static String get copyright =>
      '© ${DateTime.now().year} Stratida. All rights reserved.';
}

Future<void> openExternalLink(BuildContext context, Uri uri) async {
  final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
  if (!opened && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Could not open this link. Check your connection and try again.',
        ),
      ),
    );
  }
}

class HowToPlayScreen extends StatefulWidget {
  const HowToPlayScreen({super.key, this.firstRun = false});

  final bool firstRun;

  @override
  State<HowToPlayScreen> createState() => _HowToPlayScreenState();
}

class _HowToPlayScreenState extends State<HowToPlayScreen> {
  final PageController _controller = PageController();
  int _page = 0;

  static const _steps = [
    (
      icon: Icons.touch_app_rounded,
      title: 'Drag to place',
      body:
          'Choose one of the three pieces and drag it to any open cells where the whole shape fits.',
      color: ArcadeColors.cyan,
    ),
    (
      icon: Icons.view_stream_rounded,
      title: 'Complete a row',
      body:
          'Fill every cell in a horizontal row. Vertical lines do not clear, so plan across the board.',
      color: ArcadeColors.green,
    ),
    (
      icon: Icons.auto_awesome_rounded,
      title: 'Break and settle',
      body:
          'Completed rows break for 10 points per block. After a break, every remaining block settles to the base.',
      color: ArcadeColors.yellow,
    ),
    (
      icon: Icons.stacked_bar_chart_rounded,
      title: 'Keep space open',
      body:
          'Blocks stay exactly where you drop them until a row breaks. Reaching the top—or having no valid move—ends the game.',
      color: Color(0xFFFF718B),
    ),
    (
      icon: Icons.emoji_events_rounded,
      title: 'Journey or Endless',
      body:
          'Clear each Journey goal to unlock the next of 50 levels and earn up to three stars, or chase a high score in Endless Classic.',
      color: ArcadeColors.orange,
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('tutorial_seen_v1', true);
    if (mounted) Navigator.pop(context, true);
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
              child: Column(
                children: [
                  _ScreenHeader(
                    title: widget.firstRun
                        ? 'WELCOME TO BRICKLY'
                        : 'HOW TO PLAY',
                    onBack: widget.firstRun
                        ? null
                        : () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: PageView.builder(
                      controller: _controller,
                      itemCount: _steps.length,
                      onPageChanged: (value) => setState(() => _page = value),
                      itemBuilder: (context, index) {
                        final step = _steps[index];
                        return Padding(
                          padding: const EdgeInsets.fromLTRB(28, 30, 28, 18),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 128,
                                height: 128,
                                decoration: BoxDecoration(
                                  color: const Color(0xE6052B68),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: step.color,
                                    width: 3,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: step.color.withValues(alpha: .28),
                                      blurRadius: 24,
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  step.icon,
                                  size: 64,
                                  color: step.color,
                                ),
                              ),
                              const SizedBox(height: 30),
                              Text(
                                step.title.toUpperCase(),
                                textAlign: TextAlign.center,
                                style: Theme.of(
                                  context,
                                ).textTheme.headlineSmall,
                              ),
                              const SizedBox(height: 14),
                              ConstrainedBox(
                                constraints: const BoxConstraints(
                                  maxWidth: 520,
                                ),
                                child: Text(
                                  step.body,
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(color: ArcadeColors.white),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(22, 8, 22, 24),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            _steps.length,
                            (index) => AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              width: index == _page ? 24 : 8,
                              height: 8,
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              decoration: BoxDecoration(
                                color: index == _page
                                    ? ArcadeColors.yellow
                                    : ArcadeColors.muted.withValues(alpha: .5),
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        ArcadeButton(
                          label: _page == _steps.length - 1
                              ? (widget.firstRun ? 'START PLAYING' : 'GOT IT')
                              : 'NEXT',
                          icon: _page == _steps.length - 1
                              ? Icons.play_arrow_rounded
                              : Icons.arrow_forward_rounded,
                          onPressed: () {
                            if (_page == _steps.length - 1) {
                              _finish();
                            } else {
                              _controller.nextPage(
                                duration: const Duration(milliseconds: 240),
                                curve: Curves.easeOut,
                              );
                            }
                          },
                        ),
                      ],
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
}

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _effects = true;
  bool _placementGuide = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _effects = prefs.getBool('effects') ?? true;
      _placementGuide = prefs.getBool('placement_guide') ?? true;
    });
  }

  Future<void> _setBool(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  Future<void> _resetProgress() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset all progress?'),
        content: const Text(
          'This clears your high score, unlocked levels, and stars. Visual themes and settings stay saved.',
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
    if (confirmed != true) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('best_score_v2');
    await CampaignProgress.reset();
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Game progress reset')));
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
              child: Column(
                children: [
                  _ScreenHeader(
                    title: 'SETTINGS',
                    onBack: () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(18, 16, 18, 28),
                      children: [
                        const _SectionLabel('GAME'),
                        _SettingsCard(
                          children: [
                            SwitchListTile(
                              key: const ValueKey('effects-switch'),
                              secondary: Icon(
                                _effects
                                    ? Icons.volume_up_rounded
                                    : Icons.volume_off_rounded,
                              ),
                              title: const Text('Sound & haptics'),
                              value: _effects,
                              onChanged: (value) {
                                setState(() => _effects = value);
                                _setBool('effects', value);
                              },
                            ),
                            SwitchListTile(
                              key: const ValueKey('placement-guide-switch'),
                              secondary: Icon(
                                _placementGuide
                                    ? Icons.visibility_rounded
                                    : Icons.visibility_off_rounded,
                              ),
                              title: const Text('Placement guide'),
                              subtitle: const Text(
                                'Preview a piece before it is dropped',
                              ),
                              value: _placementGuide,
                              onChanged: (value) {
                                setState(() => _placementGuide = value);
                                _setBool('placement_guide', value);
                              },
                            ),
                            ListTile(
                              leading: const Icon(
                                Icons.school_rounded,
                                color: ArcadeColors.cyan,
                              ),
                              title: const Text('How to play'),
                              subtitle: const Text(
                                'Replay the five-step tutorial',
                              ),
                              trailing: const Icon(Icons.chevron_right_rounded),
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute<void>(
                                  builder: (_) => const HowToPlayScreen(),
                                ),
                              ),
                            ),
                            ListTile(
                              leading: const Icon(
                                Icons.restart_alt_rounded,
                                color: ArcadeColors.yellow,
                              ),
                              title: const Text('Reset game progress'),
                              trailing: const Icon(Icons.chevron_right_rounded),
                              onTap: _resetProgress,
                            ),
                          ],
                        ),
                        const SizedBox(height: 22),
                        const _SectionLabel('HELP & LEGAL'),
                        _SettingsCard(
                          children: [
                            _LinkTile(
                              icon: Icons.privacy_tip_outlined,
                              title: 'Privacy Policy',
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute<void>(
                                  builder: (_) => const LegalScreen(
                                    kind: LegalKind.privacy,
                                  ),
                                ),
                              ),
                            ),
                            _LinkTile(
                              icon: Icons.gavel_rounded,
                              title: 'Terms & Conditions',
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute<void>(
                                  builder: (_) =>
                                      const LegalScreen(kind: LegalKind.terms),
                                ),
                              ),
                            ),
                            _LinkTile(
                              icon: Icons.language_rounded,
                              title: 'Stratida website',
                              onTap: () => openExternalLink(
                                context,
                                StratidaLinks.website,
                              ),
                            ),
                            _LinkTile(
                              icon: Icons.mail_outline_rounded,
                              title: 'Contact support',
                              subtitle: 'hello@stratida.com',
                              onTap: () => openExternalLink(
                                context,
                                StratidaLinks.contact,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 22),
                        Text(
                          'BRICKLY BREAK BY STRATIDA · v1.0.0',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.labelMedium
                              ?.copyWith(color: ArcadeColors.sky),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          StratidaLinks.copyright,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: ArcadeColors.white),
                        ),
                      ],
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
}

enum LegalKind { privacy, terms }

class LegalScreen extends StatelessWidget {
  const LegalScreen({super.key, required this.kind});
  final LegalKind kind;

  @override
  Widget build(BuildContext context) {
    final privacy = kind == LegalKind.privacy;
    final title = privacy ? 'PRIVACY POLICY' : 'TERMS & CONDITIONS';
    final uri = privacy ? StratidaLinks.privacy : StratidaLinks.terms;
    final description = privacy
        ? 'Brickly Break stores your score, level progress, and preferences only on this device. The current app does not create accounts, serve ads, or send gameplay data to Stratida.'
        : 'The official terms governing your use of Brickly Break are published by Stratida. Review the current terms before using or distributing the game.';
    return Scaffold(
      backgroundColor: ArcadeColors.navy,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: ArcadeFrame(
            child: ArcadeBackground(
              child: Column(
                children: [
                  _ScreenHeader(
                    title: title,
                    onBack: () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          Icon(
                            privacy
                                ? Icons.privacy_tip_rounded
                                : Icons.gavel_rounded,
                            size: 68,
                            color: ArcadeColors.cyan,
                          ),
                          const SizedBox(height: 22),
                          Text(
                            description,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: ArcadeColors.white),
                          ),
                          const SizedBox(height: 18),
                          Text(
                            'The full, current policy is maintained on stratida.com and requires an internet connection to open.',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          const SizedBox(height: 26),
                          ArcadeButton(
                            label: privacy
                                ? 'OPEN PRIVACY POLICY'
                                : 'OPEN FULL TERMS',
                            icon: Icons.open_in_new_rounded,
                            onPressed: () => openExternalLink(context, uri),
                          ),
                          const SizedBox(height: 22),
                          SelectableText(
                            uri.toString(),
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: ArcadeColors.sky),
                          ),
                        ],
                      ),
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
}

class _ScreenHeader extends StatelessWidget {
  const _ScreenHeader({required this.title, required this.onBack});
  final String title;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
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
        if (onBack != null)
          IconButton(
            onPressed: onBack,
            tooltip: 'Back',
            icon: const Icon(Icons.arrow_back_rounded),
          )
        else
          const SizedBox(width: 48),
        Expanded(
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        const SizedBox(width: 48),
      ],
    ),
  );
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(left: 6, bottom: 8),
    child: Text(
      text,
      style: Theme.of(context).textTheme.labelMedium?.copyWith(
        color: ArcadeColors.cyan,
        letterSpacing: 1.4,
      ),
    ),
  );
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: const Color(0xE605245F),
      borderRadius: BorderRadius.circular(18),
      border: Border.all(
        color: ArcadeColors.cyan.withValues(alpha: .75),
        width: 2,
      ),
    ),
    clipBehavior: Clip.antiAlias,
    child: Column(children: children),
  );
}

class _LinkTile extends StatelessWidget {
  const _LinkTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.subtitle,
  });
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => ListTile(
    leading: Icon(icon, color: ArcadeColors.cyan),
    title: Text(title),
    subtitle: subtitle == null ? null : Text(subtitle!),
    trailing: const Icon(Icons.chevron_right_rounded),
    onTap: onTap,
  );
}
