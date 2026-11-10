import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:otzaria/personal_notes/models/personal_note.dart';
import 'package:otzaria/personal_notes/widgets/note_tile.dart';
import 'package:otzaria/theme/theme_exports.dart';

import '../dd.dart';

/// m8: עורך הערה פתוח בחלונית ההערות, בין שני כרטיסי הערה.
void main() {
  PersonalNote note(String id, int line, String text) => PersonalNote(
    id: id,
    bookId: 'ספר',
    lineNumber: line,
    displayTitle: 'שורה $line',
    lastKnownLineNumber: line,
    status: PersonalNoteStatus.located,
    content: text,
    contentPlain: text,
    contentFormat: PersonalNoteContentFormat.plain,
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 1, 1),
  );
  final notes = [
    note('a', 3, 'הערה ראשונה על השורה'),
    note('b', 7, 'הערה שנייה, בעריכה'),
    note('c', 12, 'הערה שלישית'),
  ];
  ddScene(
    'M8__editor_between_cards',
    wide: const Size(400, 760),
    narrowHeight: 760,
    tweak: _desktop,
    build: (context) => Align(
      alignment: Alignment.topCenter,
      child: SizedBox(
        width: 360,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final n in notes)
              NoteTile(
                key: ValueKey(n.id),
                note: n,
                defaultExpanded: false,
                bookId: 'ספר',
                linkableNotes: const [],
                backgroundColor: AppSurfaces.tintedRow(
                  Theme.of(context).colorScheme,
                ),
                onSave: (_) {},
                onDelete: () {},
                onLinkTap: (_) {},
              ),
          ],
        ),
      ),
    ),
    afterPump: (tester, context) async {
      await tester.tap(find.byTooltip('עריכה').at(1));
      for (var i = 0; i < 6; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
      debugDefaultTargetPlatformOverride = null;
    },
  );
}

/// טיפוגרפיית מחשב (Segoe UI = Rubik בבדיקות) כמו באפליקציה ב-Windows.
ThemeData _desktop(ThemeData base) {
  debugDefaultTargetPlatformOverride = TargetPlatform.windows;
  return ddTheme(dark: base.brightness == Brightness.dark);
}
