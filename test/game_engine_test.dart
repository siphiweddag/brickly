import 'dart:math';

import 'package:brickly/src/game_engine.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('GameEngine', () {
    test('placing without a match does not award points', () {
      final game = GameEngine(random: Random(1));
      final piece = game.pieces.first!;
      final result = game.place(piece, 0, 0);

      expect(result.placed, isTrue);
      expect(game.score, 0);
      expect(game.pieces.first, isNull);
    });

    test('rejects overlap and out of bounds placements', () {
      final game = GameEngine(random: Random(2));
      const single = BlockPiece(
        id: 999,
        cells: [GridPoint(0, 0)],
        color: Colors.red,
      );
      game.pieces = [single, null, null];
      expect(game.place(single, 0, 0).placed, isTrue);

      const another = BlockPiece(
        id: 1000,
        cells: [GridPoint(0, 0)],
        color: Colors.blue,
      );
      game.pieces = [another, null, null];
      expect(game.canPlace(another, 0, 0), isFalse);
      expect(game.canPlace(another, 8, 0), isFalse);
    });

    test('scores cleared blocks and drops remaining blocks to the base', () {
      final game = GameEngine(random: Random(3));
      for (var col = 0; col < 7; col++) {
        game.board[7][col] = Colors.orange;
      }
      game.board[2][0] = Colors.purple;
      const single = BlockPiece(
        id: 42,
        cells: [GridPoint(0, 0)],
        color: Colors.teal,
      );
      game.pieces = [single, null, null];

      final result = game.place(single, 7, 7);

      expect(result.linesCleared, 1);
      expect(result.blocksCleared, 8);
      expect(result.points, 80);
      expect(game.score, 80);
      expect(game.board[2][0], isNull);
      expect(game.board[7][0], Colors.purple);
    });

    test('clears horizontal rows repeatedly until no match remains', () {
      final game = GameEngine(random: Random(5));
      for (var col = 0; col < 7; col++) {
        game.board[7][col] = Colors.orange;
        game.board[6][col] = Colors.blue;
      }
      game.board[5][7] = Colors.blue;
      const single = BlockPiece(
        id: 77,
        cells: [GridPoint(0, 0)],
        color: Colors.orange,
      );
      game.pieces = [single, null, null];

      final result = game.place(single, 7, 7);

      expect(result.linesCleared, 2);
      expect(result.blocksCleared, 16);
      expect(result.points, 160);
      expect(game.score, 160);
      expect(
        game.board.expand((row) => row).every((cell) => cell == null),
        isTrue,
      );
    });

    test('does not clear vertical lines', () {
      final game = GameEngine(random: Random(6));
      for (var row = 1; row < 8; row++) {
        game.board[row][0] = Colors.teal;
      }
      const single = BlockPiece(
        id: 88,
        cells: [GridPoint(0, 0)],
        color: Colors.teal,
      );
      game.pieces = [single, null, null];

      final result = game.place(single, 0, 0);

      expect(result.linesCleared, 0);
      expect(result.points, 0);
      expect(game.board.every((row) => row[0] != null), isTrue);
      expect(game.isGameOver, isTrue);
    });

    test('undo restores board, pieces, and score', () {
      final game = GameEngine(random: Random(4));
      final piece = game.pieces.first!;
      game.place(piece, 0, 0);
      expect(game.undo(), isTrue);
      expect(game.score, 0);
      expect(
        game.board.expand((row) => row).every((cell) => cell == null),
        isTrue,
      );
      expect(game.pieces.first?.id, piece.id);
      expect(game.undo(), isFalse);
    });
  });
}
