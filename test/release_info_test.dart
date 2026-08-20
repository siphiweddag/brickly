import 'package:brickly/src/release_info.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('uses the exact Stratida release links and support address', () {
    expect(
      StratidaLinks.privacy.toString(),
      'https://stratida.com/privacy-policy/',
    );
    expect(
      StratidaLinks.terms.toString(),
      'https://stratida.com/terms-of-service/',
    );
    expect(StratidaLinks.website.toString(), 'https://stratida.com/');
    expect(StratidaLinks.contact.toString(), 'mailto:hello@stratida.com');
  });

  test('attributes the current release to Stratida', () {
    expect(StratidaLinks.copyright, contains('Stratida'));
    expect(StratidaLinks.copyright, contains('${DateTime.now().year}'));
    expect(StratidaLinks.copyright, endsWith('All rights reserved.'));
  });
}
