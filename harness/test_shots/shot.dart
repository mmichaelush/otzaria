// Local screenshot harness (untracked). Fonts come from the repo's golden loader.
import 'package:flutter_test/flutter_test.dart';

import '../support/golden_fonts.dart';

Future<void> loadShotFonts() => loadGoldenFonts();

Future<void> settleShot(WidgetTester tester) async {
  for (var i = 0; i < 8; i++) {
    await tester.pump(const Duration(milliseconds: 120));
  }
}
