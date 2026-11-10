import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:otzaria/library/view/grid_items.dart';
import 'package:otzaria/tools/tikkun_korim/settings/tikkun_settings.dart';
import 'package:otzaria/tools/tikkun_korim/view/widgets/tikkun_settings_panel.dart';

import '../dd.dart';

const _long =
    'שולחן ערוך אורח חיים עם נושאי כלים מגן אברהם טורי זהב באר היטב '
    'ושערי תשובה';

void main() {
  ddScene(
    'T40__tikkun_slider',
    wide: const Size(440, 420),
    narrowHeight: 420,
    build: (context) => const SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: TikkunSettingsPanel(
        settings: TikkunSettings(lineSpacing: 1.4),
        onChanged: _noop,
      ),
    ),
  );

  ddScene(
    'T40__library_tooltip',
    wide: const Size(420, 300),
    narrowHeight: 300,
    build: (context) => const Align(
      alignment: AlignmentDirectional.bottomStart,
      child: Padding(
        padding: EdgeInsets.all(24),
        child: SizedBox(
          width: 160,
          child: LibraryOverflowTooltipText(text: _long),
        ),
      ),
    ),
    afterPump: (tester, context) async {
      final g = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await g.addPointer(location: Offset.zero);
      await g.moveTo(tester.getCenter(find.byType(LibraryOverflowTooltipText)));
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pump(const Duration(milliseconds: 400));
    },
  );
}

void _noop(TikkunSettings _) {}
