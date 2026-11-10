import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:otzaria/printing/view/widgets/printing_widgets.dart';
import 'package:otzaria/settings/widgets/settings_card.dart';
import 'package:otzaria/settings/widgets/settings_slider_tile.dart';
import 'package:otzaria/theme/theme_exports.dart';
import 'package:otzaria/widgets/controls/toggle_pill.dart';

import '../dd.dart';

void _noop(bool _) {}

/// מתגים בכל המקומות שהיו על CustomSwitch, ושני SwitchListTile של צורת הדף.
Widget _switches(BuildContext context) => SingleChildScrollView(
  padding: const EdgeInsets.all(16),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      const SettingsCard(
        title: 'הגדרות',
        children: [
          SettingsSwitchTile(
            icon: FluentIcons.eye_24_regular,
            title: 'דלוק',
            value: true,
            onChanged: _noop,
          ),
          SettingsSwitchTile(
            icon: FluentIcons.eye_24_regular,
            title: 'כבוי',
            value: false,
            onChanged: _noop,
          ),
          SettingsSwitchTile(
            icon: FluentIcons.eye_24_regular,
            title: 'דלוק, מושבת',
            value: true,
            enabled: false,
            onChanged: _noop,
          ),
          SettingsSwitchTile(
            icon: FluentIcons.eye_24_regular,
            title: 'כבוי, מושבת',
            value: false,
            enabled: false,
            onChanged: _noop,
          ),
        ],
      ),
      const SizedBox(height: 12),
      const Wrap(
        spacing: 8,
        children: [
          AppTogglePill(label: 'מילים שלמות', value: true, onChanged: _noop),
          AppTogglePill(label: 'ניקוד', value: false, onChanged: _noop),
        ],
      ),
      const SizedBox(height: 12),
      const PrintingSwitchRow(label: 'הדפס כותרות', value: true, onChanged: _noop),
      const PrintingSwitchRow(label: 'הדפס מפרשים', value: false, onChanged: _noop),
      const SizedBox(height: 12),
      const SwitchListTile(
        key: ValueKey('slt'),
        title: Text('SwitchListTile דלוק (צורת הדף)'),
        value: true,
        onChanged: _noop,
      ),
      const SwitchListTile(
        title: Text('SwitchListTile כבוי'),
        value: false,
        onChanged: _noop,
      ),
      const SwitchListTile(
        title: Text('SwitchListTile מושבת'),
        value: true,
        onChanged: null,
      ),
      const SwitchListTile(
        title: Text('SwitchListTile כבוי ומושבת'),
        value: false,
        onChanged: null,
      ),
    ],
  ),
);

/// מחוון ההדפסה (SliderTheme מקומי) לצד SettingsSliderTile.
Widget _sliders(BuildContext context) => Padding(
  padding: const EdgeInsets.all(16),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      PrintingSliderRow(
        label: 'גודל גופן (הדפסה)',
        value: 14,
        min: 8,
        max: 30,
        displayValue: '14',
        onChanged: (_) {},
      ),
      const SizedBox(height: 16),
      SettingsSliderTile(
        icon: FluentIcons.text_font_size_24_regular,
        title: 'גודל גופן (הגדרות)',
        valueLabel: '25',
        value: 25,
        min: 10,
        max: 40,
        onChanged: (_) {},
      ),
    ],
  ),
);

Future<void> _hoverFirstListTileSwitch(WidgetTester t, BuildContext c) async {
  final g = await t.createGesture(kind: PointerDeviceKind.mouse);
  await g.addPointer(location: Offset.zero);
  await g.moveTo(
    t.getCenter(
      find.descendant(
        of: find.byKey(const ValueKey('slt')),
        matching: find.byType(Switch),
      ),
    ),
  );
  await t.pump(const Duration(milliseconds: 300));
}

void main() {
  for (final white in [false, true]) {
    final suffix = white ? '__white' : '';
    final seed = white ? AppSeedColors.white : null;
    ddScene(
      'T12__switches$suffix',
      wide: const Size(560, 1000),
      narrowHeight: 1000,
      seedLight: seed,
      build: _switches,
    );
    ddScene(
      'T12__switch_hover$suffix',
      wide: const Size(560, 1000),
      seedLight: seed,
      build: _switches,
      afterPump: _hoverFirstListTileSwitch,
    );
    ddScene(
      'T12__sliders$suffix',
      wide: const Size(560, 300),
      seedLight: seed,
      build: _sliders,
    );
    // חלופה B לסליידר: כל הסליידרים באגודל 8 של ההדפסה (לא מומש).
    ddScene(
      'T12__sliders__optB_thumb8$suffix',
      wide: const Size(560, 300),
      seedLight: seed,
      tweak: (base) => base.copyWith(
        sliderTheme: base.sliderTheme.copyWith(
          trackHeight: 4,
          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
        ),
      ),
      build: _sliders,
    );
  }
}
