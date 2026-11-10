// Dark-mode default seed: the real main window in a few screens.
import 'package:flutter/material.dart';
import 'package:otzaria/navigation/view/main_window_screen.dart';

import '../decide.dart';
import 'ss_fixture.dart';

void _shell(String id, Size size, SmallScreen screen) {
  decideScene(
    id,
    size: size,
    panel: false,
    wrapApp: (tester) => smallScreenProviders(
      tester,
      screen: screen,
      size: size,
      compactMenuMode: false,
    ),
    build: (context) => const MainWindowScreen(),
  );
}

void main() {
  const wide = Size(1100, 700);
  _shell('DARK__reader', wide, SmallScreen.reader);
  _shell('DARK__library', wide, SmallScreen.home);
  _shell('DARK__search', wide, SmallScreen.search);
  _shell('DARK__settings', wide, SmallScreen.settings);
}
