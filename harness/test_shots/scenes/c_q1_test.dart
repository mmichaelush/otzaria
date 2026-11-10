// c-q1 (#4787): the real main window, compact vs normal density.
import 'package:flutter/material.dart';
import 'package:otzaria/navigation/view/main_window_screen.dart';

import '../decide.dart';
import 'ss_fixture.dart';

const _tabs = ['שמות', 'ברכות', 'שולחן ערוך'];

void _shell(String id, Size size, {required bool compact}) {
  decideScene(
    id,
    size: size,
    compact: compact,
    panel: false,
    wrapApp: (tester) => smallScreenProviders(
      tester,
      screen: SmallScreen.reader,
      size: size,
      compactMenuMode: compact,
      extraTabs: _tabs,
    ),
    build: (context) => const MainWindowScreen(),
  );
}

void main() {
  for (final w in [1100.0, 560.0, 480.0]) {
    final size = Size(w, w > 600 ? 700 : 900);
    final s = w.toInt();
    _shell('${s}_compact', size, compact: true);
    _shell('${s}_normal', size, compact: false);
  }
}
