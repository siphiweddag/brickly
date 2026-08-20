import 'package:brickly/src/campaign.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('campaign contains fifty progressively harder levels', () {
    final levels = CampaignLevel.all;

    expect(levels, hasLength(50));
    expect(levels.first.number, 1);
    expect(levels.last.number, 50);
    expect(levels.first.targetLines, lessThan(levels.last.targetLines));
    expect(levels.first.prefillRows, 0);
    expect(levels.last.prefillRows, 4);
  });

  test(
    'completing a level saves stars and unlocks only the next level',
    () async {
      final level = CampaignLevel.all.first;

      await CampaignProgress.complete(level, 2);

      expect(await CampaignProgress.highestUnlocked(), 2);
      expect(await CampaignProgress.starsFor(1), 2);
      expect(await CampaignProgress.starsFor(2), 0);
    },
  );

  test('replaying a level never replaces a better star score', () async {
    final level = CampaignLevel.all.first;

    await CampaignProgress.complete(level, 3);
    await CampaignProgress.complete(level, 1);

    expect(await CampaignProgress.starsFor(1), 3);
  });

  test('reset clears unlocked levels and stars', () async {
    await CampaignProgress.complete(CampaignLevel.all.first, 3);

    await CampaignProgress.reset();

    expect(await CampaignProgress.highestUnlocked(), 1);
    expect(await CampaignProgress.starsFor(1), 0);
  });
}
