// q5 (DD-27): ExpandableSection -> ExpandableCard. Real screens only, so the
// same scene compiles before and after: the library list view and three
// settings tabs with an expandable section opened.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:otzaria/navigation/view/main_window_screen.dart';

import '../decide.dart';
import 'ss_fixture.dart';

Future<void> _frames(WidgetTester tester) async {
  for (var i = 0; i < 8; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

void _library() {
  const size = Size(820, 600);
  decideScene(
    'TQ5__library',
    size: size,
    panel: false,
    wrapApp: (tester) => smallScreenProviders(
      tester,
      screen: SmallScreen.home,
      size: size,
      compactMenuMode: false,
      settingsTweak: (s) => s.copyWith(libraryViewMode: 'list'),
    ),
    build: (context) => const MainWindowScreen(),
    afterPump: (tester, context) async {
      final f = find.text('תנ"ך');
      if (f.evaluate().isNotEmpty) {
        await tester.tap(f.first);
        await _frames(tester);
      }
    },
  );
}

void _settings(String id, String tab, String section) {
  const size = Size(1000, 760);
  decideScene(
    id,
    size: size,
    panel: false,
    wrapApp: (tester) => smallScreenProviders(
      tester,
      screen: SmallScreen.settings,
      size: size,
      compactMenuMode: false,
    ),
    build: (context) => const MainWindowScreen(),
    afterPump: (tester, context) async {
      final t = find.text(tab);
      if (t.evaluate().isNotEmpty) {
        await tester.tap(t.first);
        await _frames(tester);
      }
      final s = find.text(section);
      if (s.evaluate().isNotEmpty) {
        await tester.ensureVisible(s.first);
        await _frames(tester);
        await tester.tap(s.first);
        await _frames(tester);
        await tester.ensureVisible(s.first);
        await _frames(tester);
      } else {
        // ignore: avoid_print
        print('SHOT-MISSING $id $section');
      }
    },
  );
}

void main() {
  _library();
  _settings('TQ5__settings_text', 'כתב', 'התאמות נוספות');
  _settings('TQ5__settings_system', 'מערכת', 'גיבוי אוטומטי');
  _settings('TQ5__settings_tools', 'כלים', 'רשימת הכלים');
}
