import 'package:brickly/main.dart';
import 'package:brickly/src/arcade_ui.dart';
import 'package:brickly/src/game_engine.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('renders the Brickly Break lobby and navigation', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const BricklyApp());
    await tester.pumpAndSettle();

    expect(find.text('BRICKLY'), findsOneWidget);
    expect(find.text('BREAK'), findsOneWidget);
    expect(find.text('BRICKLY JOURNEY'), findsOneWidget);
    expect(find.text('ENDLESS CLASSIC'), findsOneWidget);
    final playLabel = tester.widget<Text>(find.text('BRICKLY JOURNEY'));
    expect(playLabel.style?.color, ArcadeColors.navy);
    expect(find.text('Inventory'), findsOneWidget);
    expect(find.text('Shop'), findsNothing);
    expect(find.textContaining('REWARD'), findsNothing);
    expect(find.textContaining('COIN'), findsNothing);
  });

  testWidgets('places a piece by freely dragging it onto the board', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({'tutorial_seen_v1': true});
    await tester.pumpWidget(const BricklyApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('ENDLESS CLASSIC'));
    await tester.pumpAndSettle();

    final pieces = find.byType(Draggable<BlockPiece>);
    expect(pieces, findsNWidgets(3));

    final start = tester.getCenter(pieces.first);
    final destination =
        tester.getCenter(find.byType(GridView)) + const Offset(0, 45);
    final gesture = await tester.startGesture(start);
    await tester.pump();
    await gesture.moveTo(Offset.lerp(start, destination, .5)!);
    await tester.pump(const Duration(milliseconds: 100));
    await gesture.moveTo(destination);
    await tester.pump();
    await gesture.up();
    await tester.pumpAndSettle();

    expect(find.byType(Draggable<BlockPiece>), findsNWidgets(2));
  });

  testWidgets('uses only scores from the current scoring model', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      'best_score': 9999,
      'best_score_v2': 160,
      'tutorial_seen_v1': true,
    });
    await tester.pumpWidget(const BricklyApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('ENDLESS CLASSIC'));
    await tester.pumpAndSettle();

    expect(find.text('160'), findsOneWidget);
    expect(find.text('9999'), findsNothing);
  });

  testWidgets('settings changes persist for the gameplay session', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({'effects': true});
    await tester.pumpWidget(const BricklyApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Settings'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('effects-switch')));
    await tester.pumpAndSettle();

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool('effects'), isFalse);
  });

  testWidgets('inventory saves background and block skin choices', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({'tutorial_seen_v1': true});
    await tester.pumpWidget(const BricklyApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Inventory'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('FROST FIELD'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('FROST FIELD'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('BLOCK SKIN'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('CANDY POP'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('CANDY POP'));
    await tester.pumpAndSettle();

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getInt('background_style'), ArcadeBackgroundStyle.frost.index);
    expect(prefs.getInt('block_skin'), BlockSkinStyle.candy.index);
  });

  testWidgets('primary journey enters Classic and returns to the lobby', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({'tutorial_seen_v1': true});
    await tester.pumpWidget(const BricklyApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('ENDLESS CLASSIC'));
    await tester.pumpAndSettle();
    expect(find.text('SCORE'), findsOneWidget);

    await tester.tap(find.byTooltip('Back to lobby'));
    await tester.pumpAndSettle();
    expect(find.text('BRICKLY JOURNEY'), findsOneWidget);
  });

  testWidgets('small screen and increased text size do not overflow', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 1.5;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    SharedPreferences.setMockInitialValues({'tutorial_seen_v1': true});

    await tester.pumpWidget(const BricklyApp());
    await tester.pumpAndSettle();

    expect(find.text('BRICKLY JOURNEY'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('first game opens the tutorial before gameplay', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const BricklyApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('ENDLESS CLASSIC'));
    await tester.pumpAndSettle();

    expect(find.text('WELCOME TO BRICKLY'), findsOneWidget);
    expect(find.text('DRAG TO PLACE'), findsOneWidget);
    expect(find.text('NEXT'), findsOneWidget);
  });

  testWidgets('settings exposes help and Stratida legal links', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const BricklyApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Settings'));
    await tester.pumpAndSettle();

    expect(find.text('HELP & LEGAL'), findsOneWidget);
    expect(find.text('Privacy Policy'), findsOneWidget);
    expect(find.text('Terms & Conditions'), findsOneWidget);
    expect(find.text('hello@stratida.com'), findsOneWidget);
    await tester.drag(find.byType(ListView), const Offset(0, -500));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Stratida. All rights reserved.'),
      findsOneWidget,
    );
  });

  testWidgets('journey displays fifty sequential levels', (tester) async {
    SharedPreferences.setMockInitialValues({'tutorial_seen_v1': true});
    await tester.pumpWidget(const BricklyApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('BRICKLY JOURNEY'));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('level-grid')), findsOneWidget);
    expect(find.text('1/50'), findsOneWidget);
    expect(find.text('LOCKED'), findsWidgets);
  });
}
