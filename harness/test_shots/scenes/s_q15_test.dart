// s-q15: small-screen features on a phone in portrait (touch): the real main
// window with a book open. "rest" = as opened; "scrolled" = after scrolling
// the text down; "tabs" = three open books (one chrome row).
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:otzaria/navigation/view/main_window_screen.dart';

import '../decide.dart';
import 'ss_fixture.dart';

void _phone(
  String id,
  Size size, {
  bool scroll = false,
  List<String> tabs = const [],
}) {
  decideScene(
    id,
    size: size,
    platform: TargetPlatform.android,
    panel: false,
    wrapApp: (tester) => smallScreenProviders(
      tester,
      screen: SmallScreen.reader,
      size: size,
      desktop: false,
      extraTabs: tabs,
    ),
    build: (context) => const MainWindowScreen(),
    afterPump: !scroll
        ? null
        : (tester, context) async {
            final center = tester.getCenter(find.byType(MainWindowScreen));
            final gesture = await tester.startGesture(center);
            for (var i = 0; i < 8; i++) {
              await gesture.moveBy(const Offset(0, -30));
              await tester.pump(const Duration(milliseconds: 16));
            }
            await gesture.up();
            for (var i = 0; i < 10; i++) {
              await tester.pump(const Duration(milliseconds: 60));
            }
          },
  );
}

void main() {
  for (final size in const [Size(360, 800), Size(412, 915)]) {
    final w = size.width.toInt();
    _phone('${w}_rest', size);
    _phone('${w}_scrolled', size, scroll: true);
    _phone('${w}_tabs', size, tabs: const ['שמות', 'ברכות']);
  }
}
