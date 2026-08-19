import 'package:brickly/src/arcade_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

double contrastRatio(Color foreground, Color background) {
  final first = foreground.computeLuminance();
  final second = background.computeLuminance();
  final lighter = first > second ? first : second;
  final darker = first > second ? second : first;
  return (lighter + .05) / (darker + .05);
}

void main() {
  test('core text and action color pairs meet WCAG AA contrast', () {
    expect(
      contrastRatio(ArcadeColors.navy, ArcadeColors.yellow),
      greaterThanOrEqualTo(4.5),
    );
    expect(
      contrastRatio(ArcadeColors.white, ArcadeColors.navy),
      greaterThanOrEqualTo(4.5),
    );
    expect(
      contrastRatio(ArcadeColors.muted, ArcadeColors.navy),
      greaterThanOrEqualTo(4.5),
    );
    expect(
      contrastRatio(ArcadeColors.white, const Color(0xFF0567A8)),
      greaterThanOrEqualTo(4.5),
    );
  });
}
