import 'dart:math';

import 'package:flutter/material.dart';

@immutable
class GridPoint {
  const GridPoint(this.row, this.col);
  final int row;
  final int col;
}

@immutable
class BlockPiece {
  const BlockPiece({
    required this.id,
    required this.cells,
    required this.color,
  });

  final int id;
  final List<GridPoint> cells;
  final Color color;

  int get rows => cells.map((e) => e.row).reduce(max) + 1;
  int get cols => cells.map((e) => e.col).reduce(max) + 1;
}

class MoveResult {
  const MoveResult({
    required this.placed,
    this.linesCleared = 0,
    this.blocksCleared = 0,
    this.points = 0,
  });
  final bool placed;
  final int linesCleared;
  final int blocksCleared;
  final int points;
}

class GameSnapshot {
  GameSnapshot(this.board, this.pieces, this.score, this.combo);
  final List<List<Color?>> board;
  final List<BlockPiece?> pieces;
  final int score;
  final int combo;
}

class GameEngine {
  GameEngine({Random? random}) : _random = random ?? Random() {
    reset();
  }

  static const boardSize = 8;
  final Random _random;
  late List<List<Color?>> board;
  late List<BlockPiece?> pieces;
  int score = 0;
  int combo = 0;
  bool isGameOver = false;
  GameSnapshot? undoSnapshot;
  int _nextId = 0;

  static const _colors = <Color>[
    Color(0xFFFFB648),
    Color(0xFF5DD6C0),
    Color(0xFF8D7CFF),
    Color(0xFFFF718B),
    Color(0xFF58A9FF),
  ];

  static const _shapeData = <List<List<int>>>[
    [
      [0, 0],
    ],
    [
      [0, 0],
      [0, 1],
    ],
    [
      [0, 0],
      [1, 0],
    ],
    [
      [0, 0],
      [0, 1],
      [0, 2],
    ],
    [
      [0, 0],
      [1, 0],
      [2, 0],
    ],
    [
      [0, 0],
      [0, 1],
      [1, 0],
      [1, 1],
    ],
    [
      [0, 0],
      [1, 0],
      [1, 1],
    ],
    [
      [0, 1],
      [1, 0],
      [1, 1],
    ],
    [
      [0, 0],
      [0, 1],
      [1, 1],
    ],
    [
      [0, 0],
      [0, 1],
      [0, 2],
      [0, 3],
    ],
    [
      [0, 0],
      [1, 0],
      [2, 0],
      [3, 0],
    ],
    [
      [0, 0],
      [1, 0],
      [2, 0],
      [2, 1],
    ],
    [
      [0, 0],
      [0, 1],
      [0, 2],
      [1, 1],
    ],
    [
      [0, 0],
      [0, 1],
      [1, 0],
      [1, 1],
      [2, 0],
      [2, 1],
    ],
    [
      [0, 0],
      [0, 1],
      [0, 2],
      [1, 0],
      [1, 1],
      [1, 2],
    ],
    [
      [0, 0],
      [0, 1],
      [0, 2],
      [1, 0],
      [1, 1],
      [1, 2],
      [2, 0],
      [2, 1],
      [2, 2],
    ],
  ];

  void reset() {
    board = List.generate(
      boardSize,
      (_) => List<Color?>.filled(boardSize, null),
    );
    score = 0;
    combo = 0;
    isGameOver = false;
    undoSnapshot = null;
    pieces = _makeSet();
  }

  List<BlockPiece?> _makeSet() => List.generate(3, (_) => _randomPiece());

  BlockPiece _randomPiece() {
    final shape = _shapeData[_random.nextInt(_shapeData.length)];
    return BlockPiece(
      id: _nextId++,
      cells: shape.map((p) => GridPoint(p[0], p[1])).toList(growable: false),
      color: _colors[_random.nextInt(_colors.length)],
    );
  }

  bool canPlace(BlockPiece piece, int row, int col) {
    for (final cell in piece.cells) {
      final r = row + cell.row;
      final c = col + cell.col;
      if (r < 0 ||
          c < 0 ||
          r >= boardSize ||
          c >= boardSize ||
          board[r][c] != null) {
        return false;
      }
    }
    return true;
  }

  bool pieceCanFit(BlockPiece piece) {
    for (var row = 0; row < boardSize; row++) {
      for (var col = 0; col < boardSize; col++) {
        if (canPlace(piece, row, col)) return true;
      }
    }
    return false;
  }

  MoveResult place(BlockPiece piece, int row, int col) {
    final pieceIndex = pieces.indexWhere((p) => p?.id == piece.id);
    if (pieceIndex == -1 || !canPlace(piece, row, col)) {
      return const MoveResult(placed: false);
    }

    undoSnapshot = GameSnapshot(
      board.map((r) => List<Color?>.from(r)).toList(),
      List<BlockPiece?>.from(pieces),
      score,
      combo,
    );
    for (final cell in piece.cells) {
      board[row + cell.row][col + cell.col] = piece.color;
    }
    pieces[pieceIndex] = null;

    var lines = 0;
    var totalClearedBlocks = 0;
    var points = 0;
    combo = 0;

    while (true) {
      final fullRows = <int>[];
      for (var row = 0; row < boardSize; row++) {
        if (board[row].every((cell) => cell != null)) fullRows.add(row);
      }
      if (fullRows.isEmpty) break;

      combo++;
      lines += fullRows.length;
      final clearedBlocks = fullRows.length * boardSize;
      totalClearedBlocks += clearedBlocks;
      points += clearedBlocks * 10;

      for (final row in fullRows) {
        board[row] = List<Color?>.filled(boardSize, null);
      }
      _applyGravity();
    }

    score += points;

    if (pieces.every((p) => p == null)) pieces = _makeSet();
    final stackReachedTop = board.first.any((cell) => cell != null);
    final noPieceCanFit = pieces.whereType<BlockPiece>().every(
      (p) => !pieceCanFit(p),
    );
    isGameOver = stackReachedTop || noPieceCanFit;
    return MoveResult(
      placed: true,
      linesCleared: lines,
      blocksCleared: totalClearedBlocks,
      points: points,
    );
  }

  void _applyGravity() {
    for (var col = 0; col < boardSize; col++) {
      final settled = <Color>[];
      for (var row = boardSize - 1; row >= 0; row--) {
        final block = board[row][col];
        if (block != null) settled.add(block);
      }

      for (var row = 0; row < boardSize; row++) {
        board[row][col] = null;
      }
      for (var index = 0; index < settled.length; index++) {
        board[boardSize - 1 - index][col] = settled[index];
      }
    }
  }

  bool undo() {
    final snapshot = undoSnapshot;
    if (snapshot == null) return false;
    board = snapshot.board.map((r) => List<Color?>.from(r)).toList();
    pieces = List<BlockPiece?>.from(snapshot.pieces);
    score = snapshot.score;
    combo = snapshot.combo;
    isGameOver = false;
    undoSnapshot = null;
    return true;
  }
}
