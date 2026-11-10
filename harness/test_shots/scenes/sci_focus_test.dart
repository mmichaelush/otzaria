import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:otzaria/widgets/layout/tool_result_card_shell.dart';

import '../dd.dart';

void main() {
  ddScene(
    'Sci_focus__tool_result_card_keyboard_focus',
    wide: const Size(600, 260),
    narrowHeight: 300,
    build: (context) => DdBox(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 8,
        children: [
          ToolResultCardShell(
            onTap: () {},
            child: const Text('רבי עקיבא בן יוסף תנא דור שלישי'),
          ),
          ToolResultCardShell(
            onTap: () {},
            child: const Text('רבי מאיר תנא דור רביעי'),
          ),
        ],
      ),
    ),
    afterPump: (tester, context) async {
      FocusManager.instance.highlightStrategy =
          FocusHighlightStrategy.alwaysTraditional;
      // הטאב הראשון נעצר ב־SelectableRegion של אזור הבחירה, השני בכרטיס.
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump(const Duration(milliseconds: 400));
    },
  );
}
