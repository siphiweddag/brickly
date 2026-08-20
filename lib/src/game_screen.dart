import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'arcade_ui.dart';
import 'campaign.dart';
import 'game_engine.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({
    super.key,
    this.onExit,
    this.backgroundStyle = ArcadeBackgroundStyle.classic,
    this.blockSkin = BlockSkinStyle.glossy,
    this.campaignLevel,
  });

  final VoidCallback? onExit;
  final ArcadeBackgroundStyle backgroundStyle;
  final BlockSkinStyle blockSkin;
  final CampaignLevel? campaignLevel;

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final GameEngine _game = GameEngine();
  final GlobalKey _boardKey = GlobalKey();
  BlockPiece? _selected;
  GridPoint? _previewOrigin;
  int _best = 0;
  bool _effects = true;
  bool _placementGuide = true;
  int _campaignLines = 0;
  int _moves = 0;
  int _lastLinesCleared = 0;
  bool _levelResolved = false;
  String? _toast;
  Timer? _toastTimer;

  static const double _boardPadding = 8;
  static const double _fingerLift = 34;

  @override
  void initState() {
    super.initState();
    _applyCampaignLayout();
    _loadPreferences();
  }

  void _applyCampaignLayout() {
    final level = widget.campaignLevel;
    if (level == null || level.prefillRows == 0) return;
    const colors = [
      Color(0xFFFFB648),
      Color(0xFF5DD6C0),
      Color(0xFF8D7CFF),
      Color(0xFFFF718B),
      Color(0xFF58A9FF),
    ];
    for (var offset = 0; offset < level.prefillRows; offset++) {
      final row = GameEngine.boardSize - 1 - offset;
      for (var col = 0; col < GameEngine.boardSize; col++) {
        final isGap = (col + offset * 2 + level.number) % 3 == 0;
        if (!isGap) {
          _game.board[row][col] =
              colors[(col + offset + level.number) % colors.length];
        }
      }
    }
  }

  void _resetGame() {
    _game.reset();
    _campaignLines = 0;
    _moves = 0;
    _lastLinesCleared = 0;
    _levelResolved = false;
    _selected = null;
    _previewOrigin = null;
    _applyCampaignLayout();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _best = prefs.getInt('best_score_v2') ?? 0;
      _effects = prefs.getBool('effects') ?? true;
      _placementGuide = prefs.getBool('placement_guide') ?? true;
    });
  }

  Future<void> _saveBest() async {
    if (_game.score <= _best) return;
    _best = _game.score;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('best_score_v2', _best);
  }

  void _place(BlockPiece piece, int row, int col) {
    final result = _game.place(piece, row, col);
    if (!result.placed) {
      if (_effects) HapticFeedback.lightImpact();
      _showToast('That spot won’t fit');
      setState(() => _previewOrigin = null);
      return;
    }
    if (_effects) {
      result.linesCleared > 0
          ? HapticFeedback.heavyImpact()
          : HapticFeedback.selectionClick();
      SystemSound.play(SystemSoundType.click);
    }
    _selected = null;
    _previewOrigin = null;
    _moves++;
    _lastLinesCleared = result.linesCleared;
    _campaignLines += result.linesCleared;
    _saveBest();
    if (result.linesCleared > 0) {
      _showToast('${result.blocksCleared} BLOCKS BROKEN  +${result.points}');
    }
    setState(() {});
    final target = widget.campaignLevel?.targetLines;
    if (target != null && _campaignLines >= target && !_levelResolved) {
      _levelResolved = true;
      WidgetsBinding.instance.addPostFrameCallback((_) => _showLevelComplete());
    } else if (_game.isGameOver) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _showGameOver());
    }
  }

  Future<void> _showLevelComplete() async {
    final level = widget.campaignLevel;
    if (level == null) return;
    final stars = _moves <= level.parMoves
        ? 3
        : _moves <= level.parMoves + 6
        ? 2
        : 1;
    await CampaignProgress.complete(level, stars);
    if (!mounted) return;
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF06427F),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
          side: const BorderSide(color: ArcadeColors.yellow, width: 3),
        ),
        title: Text(
          level.number == 50
              ? 'JOURNEY COMPLETE!'
              : 'LEVEL ${level.number} COMPLETE',
          textAlign: TextAlign.center,
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(color: ArcadeColors.yellow),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                3,
                (index) => Icon(
                  index < stars
                      ? Icons.star_rounded
                      : Icons.star_border_rounded,
                  size: 42,
                  color: index < stars
                      ? ArcadeColors.yellow
                      : ArcadeColors.muted,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '$_campaignLines rows cleared in $_moves moves',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: ArcadeColors.white),
            ),
          ],
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          if (level.number < 50)
            FilledButton.icon(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(this.context, level.number + 1);
              },
              icon: const Icon(Icons.arrow_forward_rounded),
              label: const Text('NEXT LEVEL'),
            ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(this.context);
            },
            child: Text(level.number == 50 ? 'BACK TO LEVELS' : 'LEVELS'),
          ),
        ],
      ),
    );
  }

  double get _boardCellSize {
    final box = _boardKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return 38;
    return (box.size.width - _boardPadding * 2) / GameEngine.boardSize;
  }

  void _updateDrag(BlockPiece piece, Offset globalPosition) {
    final box = _boardKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return;

    final local = box.globalToLocal(globalPosition);
    final cellSize = _boardCellSize;
    final pieceLeft = local.dx - piece.cols * cellSize / 2;
    final pieceTop = local.dy - _fingerLift - piece.rows * cellSize;
    final col = ((pieceLeft - _boardPadding) / cellSize).round();
    final row = ((pieceTop - _boardPadding) / cellSize).round();

    if (_previewOrigin?.row == row &&
        _previewOrigin?.col == col &&
        _selected?.id == piece.id) {
      return;
    }
    setState(() {
      _selected = piece;
      _previewOrigin = GridPoint(row, col);
    });
  }

  void _finishDrag(BlockPiece piece) {
    final origin = _previewOrigin;
    if (origin != null && _game.canPlace(piece, origin.row, origin.col)) {
      _place(piece, origin.row, origin.col);
      return;
    }

    if (_effects) HapticFeedback.lightImpact();
    setState(() {
      _selected = null;
      _previewOrigin = null;
    });
    _showToast('That spot won’t fit');
  }

  void _showToast(String text) {
    _toastTimer?.cancel();
    setState(() => _toast = text);
    _toastTimer = Timer(const Duration(milliseconds: 1200), () {
      if (mounted) setState(() => _toast = null);
    });
  }

  Future<void> _showGameOver() async {
    await _saveBest();
    if (!mounted) return;
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF06427F),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
          side: const BorderSide(color: ArcadeColors.cyan, width: 3),
        ),
        title: Text(
          widget.campaignLevel == null ? 'GAME OVER' : 'LEVEL FAILED',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
            color: ArcadeColors.yellow,
            shadows: const [
              Shadow(color: Color(0xFFA43A00), offset: Offset(0, 4)),
            ],
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.grid_view_rounded,
              size: 54,
              color: ArcadeColors.cyan,
            ),
            const SizedBox(height: 14),
            Text(
              widget.campaignLevel == null
                  ? '${_game.score}'
                  : '$_campaignLines / ${widget.campaignLevel!.targetLines}',
              style: const TextStyle(fontSize: 38, fontWeight: FontWeight.w900),
            ),
            Text(
              widget.campaignLevel == null ? 'FINAL SCORE' : 'ROWS CLEARED',
              style: const TextStyle(
                color: ArcadeColors.cyan,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.campaignLevel == null
                  ? 'Best  $_best'
                  : 'Try a different placement plan',
              style: const TextStyle(
                color: ArcadeColors.yellow,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          FilledButton.icon(
            onPressed: () {
              Navigator.pop(context);
              setState(_resetGame);
            },
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('PLAY AGAIN'),
          ),
          if (widget.onExit != null)
            TextButton.icon(
              onPressed: () {
                Navigator.pop(context);
                widget.onExit!();
              },
              icon: const Icon(Icons.home_rounded),
              label: const Text('LOBBY'),
            ),
        ],
      ),
    );
  }

  void _confirmRestart() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF06427F),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: ArcadeColors.cyan, width: 2),
        ),
        title: const Text('Start a new board?'),
        content: Text(
          widget.campaignLevel == null
              ? 'Your current score will be saved as your best.'
              : 'Your progress in this attempt will restart.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('KEEP PLAYING'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              _saveBest();
              setState(_resetGame);
            },
            child: const Text('NEW GAME'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _toastTimer?.cancel();
    super.dispose();
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
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
                child: Column(
                  children: [
                    _buildTopBar(),
                    const SizedBox(height: 4),
                    _buildScoreBar(),
                    const SizedBox(height: 10),
                    Expanded(
                      child: Align(
                        alignment: const Alignment(0, -0.28),
                        child: _buildBoard(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildTray(),
                    const SizedBox(height: 4),
                    Text(
                      _selected == null
                          ? 'DRAG A PIECE ANYWHERE IT FITS'
                          : 'RELEASE TO PLACE',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: ArcadeColors.sky,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() => Row(
    children: [
      _roundButton(
        Icons.home_rounded,
        widget.onExit ?? () => Navigator.maybePop(context),
        tooltip: 'Back to lobby',
      ),
      const SizedBox(width: 9),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.campaignLevel == null ? 'HIGH SCORE' : 'MOVES',
            style: Theme.of(
              context,
            ).textTheme.labelSmall?.copyWith(color: ArcadeColors.muted),
          ),
          Text(
            widget.campaignLevel == null ? '$_best' : '$_moves',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ],
      ),
      const Spacer(),
      Text(
        widget.campaignLevel == null
            ? 'ENDLESS'
            : 'LEVEL ${widget.campaignLevel!.number}',
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: ArcadeColors.white,
          letterSpacing: 1.2,
        ),
      ),
      const SizedBox(width: 8),
      _roundButton(
        _effects ? Icons.volume_up_rounded : Icons.volume_off_rounded,
        () async {
          setState(() => _effects = !_effects);
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('effects', _effects);
        },
        tooltip: 'Toggle effects',
      ),
    ],
  );

  Widget _roundButton(
    IconData icon,
    VoidCallback? onPressed, {
    required String tooltip,
  }) => IconButton(
    onPressed: onPressed,
    tooltip: tooltip,
    style: IconButton.styleFrom(
      backgroundColor: const Color(0xFF087EC5),
      disabledBackgroundColor: const Color(0xFF09356E),
      side: BorderSide(
        color: ArcadeColors.cyan.withValues(alpha: .7),
        width: 2,
      ),
    ),
    icon: Icon(icon, size: 21),
  );

  Widget _buildScoreBar() => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      _roundButton(
        Icons.undo_rounded,
        _game.undoSnapshot == null
            ? null
            : () {
                setState(() {
                  _game.undo();
                  _campaignLines = (_campaignLines - _lastLinesCleared).clamp(
                    0,
                    999,
                  );
                  _moves = (_moves - 1).clamp(0, 999);
                  _lastLinesCleared = 0;
                  _selected = null;
                });
              },
        tooltip: 'Undo last move',
      ),
      const Spacer(),
      Column(
        children: [
          Text(
            widget.campaignLevel == null ? 'SCORE' : 'ROWS',
            style: Theme.of(
              context,
            ).textTheme.labelLarge?.copyWith(color: ArcadeColors.cyan),
          ),
          Text(
            widget.campaignLevel == null
                ? '${_game.score}'
                : '$_campaignLines / ${widget.campaignLevel!.targetLines}',
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
              shadows: const [
                Shadow(color: Color(0xFF001744), offset: Offset(0, 3)),
              ],
            ),
          ),
        ],
      ),
      const Spacer(),
      _roundButton(Icons.refresh_rounded, _confirmRestart, tooltip: 'New game'),
    ],
  );

  Widget _buildBoard() => AspectRatio(
    aspectRatio: 1,
    child: Stack(
      key: _boardKey,
      alignment: Alignment.center,
      children: [
        Container(
          decoration: BoxDecoration(
            color: const Color(0xCC031A45),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: ArcadeColors.cyan, width: 3),
            boxShadow: const [
              BoxShadow(
                color: Colors.black38,
                blurRadius: 24,
                offset: Offset(0, 12),
              ),
            ],
          ),
          padding: const EdgeInsets.all(8),
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 64,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 8,
            ),
            itemBuilder: (context, index) => _buildCell(index ~/ 8, index % 8),
          ),
        ),
        IgnorePointer(
          child: AnimatedOpacity(
            opacity: _toast == null ? 0 : 1,
            duration: const Duration(milliseconds: 160),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xE62E3545),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Text(
                _toast ?? '',
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  color: Color(0xFFFFD28A),
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  );

  Widget _buildCell(int row, int col) {
    final color = _game.board[row][col];
    final preview = _placementGuide && _isPreviewCell(row, col);
    final previewValid =
        _selected != null &&
        _previewOrigin != null &&
        _game.canPlace(_selected!, _previewOrigin!.row, _previewOrigin!.col);
    final displayColor = preview
        ? previewValid
              ? _selected!.color.withValues(alpha: .72)
              : const Color(0xFFEA526F).withValues(alpha: .82)
        : color ?? const Color(0xFF042352);
    final decoration = color == null && !preview
        ? BoxDecoration(
            color: const Color(0xFF042352),
            borderRadius: BorderRadius.circular(7),
          )
        : preview && !previewValid
        ? BoxDecoration(
            color: displayColor,
            borderRadius: BorderRadius.circular(7),
            border: Border.all(color: const Color(0xFFFFB0BD)),
          )
        : blockDecoration(
            displayColor,
            widget.blockSkin,
            radius: 7,
            preview: preview,
          );
    return AnimatedContainer(
      duration: const Duration(milliseconds: 80),
      margin: const EdgeInsets.all(2),
      decoration: decoration,
    );
  }

  bool _isPreviewCell(int row, int col) {
    final origin = _previewOrigin;
    final piece = _selected;
    if (origin == null || piece == null) {
      return false;
    }
    return piece.cells.any(
      (cell) => origin.row + cell.row == row && origin.col + cell.col == col,
    );
  }

  Widget _buildTray() => SizedBox(
    height: 112,
    child: Row(
      children: List.generate(3, (index) {
        final piece = _game.pieces[index];
        return Expanded(
          child: AnimatedOpacity(
            opacity: piece == null
                ? 0
                : _game.pieceCanFit(piece)
                ? 1
                : .28,
            duration: const Duration(milliseconds: 200),
            child: piece == null ? const SizedBox() : _pieceDraggable(piece),
          ),
        );
      }),
    ),
  );

  Widget _pieceDraggable(BlockPiece piece) {
    final visual = PieceWidget(
      piece: piece,
      cellSize: 22,
      skin: widget.blockSkin,
    );
    final feedbackCellSize = _boardCellSize;
    return Draggable<BlockPiece>(
      data: piece,
      dragAnchorStrategy: pointerDragAnchorStrategy,
      feedback: Material(
        color: Colors.transparent,
        child: Transform.translate(
          offset: Offset(
            -piece.cols * feedbackCellSize / 2,
            -piece.rows * feedbackCellSize - _fingerLift,
          ),
          child: Opacity(
            opacity: .92,
            child: PieceWidget(
              piece: piece,
              cellSize: feedbackCellSize,
              skin: widget.blockSkin,
            ),
          ),
        ),
      ),
      childWhenDragging: Opacity(opacity: .15, child: visual),
      onDragStarted: () {
        if (_effects) HapticFeedback.selectionClick();
        setState(() => _selected = piece);
      },
      onDragUpdate: (details) => _updateDrag(piece, details.globalPosition),
      onDragEnd: (_) => _finishDrag(piece),
      child: Semantics(
        button: true,
        label: 'Drag block piece with ${piece.cells.length} squares',
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          margin: const EdgeInsets.symmetric(horizontal: 5),
          decoration: BoxDecoration(
            color: const Color(0x66052C68),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white.withValues(alpha: .04)),
          ),
          alignment: Alignment.center,
          child: visual,
        ),
      ),
    );
  }
}

class PieceWidget extends StatelessWidget {
  const PieceWidget({
    super.key,
    required this.piece,
    required this.cellSize,
    this.skin = BlockSkinStyle.glossy,
  });

  final BlockPiece piece;
  final double cellSize;
  final BlockSkinStyle skin;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: piece.cols * cellSize,
      height: piece.rows * cellSize,
      child: Stack(
        children: [
          for (final cell in piece.cells)
            Positioned(
              left: cell.col * cellSize,
              top: cell.row * cellSize,
              child: Container(
                width: cellSize - 3,
                height: cellSize - 3,
                decoration: blockDecoration(
                  piece.color,
                  skin,
                  radius: cellSize * .22,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
