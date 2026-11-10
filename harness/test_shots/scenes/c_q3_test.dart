// c-q3: touch targets (48 in touch, desktop unchanged). The dashed line is the
// widget's real size (scene-only).
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:otzaria/library/bloc/library_bloc.dart';
import 'package:otzaria/library/bloc/library_event.dart';
import 'package:otzaria/library/bloc/library_state.dart';
import 'package:otzaria/library/models/library.dart';
import 'package:otzaria/navigation/view/main_window_screen.dart';
import 'package:otzaria/personal_notes/bloc/personal_notes_bloc.dart';
import 'package:otzaria/personal_notes/models/personal_note.dart';
import 'package:otzaria/personal_notes/repository/personal_notes_repository.dart';
import 'package:otzaria/personal_notes/storage/personal_notes_database.dart';
import 'package:otzaria/personal_notes/view/personal_notes_screen.dart';
import 'package:otzaria/settings/engine/settings_bloc.dart';
import 'package:otzaria/settings/engine/settings_repository.dart';
import 'package:otzaria/theme/theme_exports.dart';
import 'package:otzaria/widgets/controls/status_chip.dart';
import 'package:otzaria/widgets/controls/toggle_pill.dart';
import 'package:otzaria/widgets/text/otzaria_search_field.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';

import '../decide.dart';
import 'ss_fixture.dart';

// ── open question 1: touch targets under 48 ─────────────────────────────────

Widget _target(Widget child, {required bool grow, bool square = true}) =>
    HitOutline(child: child);

Widget _touchPanel(BuildContext context, {required bool grow}) {
  final controller = TextEditingController(text: 'בראשית ברא');
  void noop() {}
  return Padding(
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        OtzariaSearchField(
          controller: controller,
          hintText: 'חיפוש',
          onClear: noop,
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            _target(
              AppTogglePill(label: 'חלופות שמורות', value: true, onChanged: (_) {}),
              grow: grow,
              square: false,
            ),
            _target(
              AppTogglePill(label: 'זהה לכל המילים', value: false, onChanged: (_) {}),
              grow: grow,
              square: false,
            ),
            _target(
              StatusChip(
                icon: const Icon(FluentIcons.arrow_download_24_regular),
                label: 'עדכון זמין',
                onPressed: noop,
                tooltip: 'עדכון',
              ),
              grow: grow,
              square: false,
            ),
          ],
        ),
      ],
    ),
  );
}

void _touch(String id, {required bool grow, TargetPlatform platform = TargetPlatform.android}) {
  decideScene(
    id,
    size: const Size(400, 210),
    platform: platform,
    build: (context) => _touchPanel(context, grow: grow),
  );
}

/// The real reader on a phone (touch): its AppTopBar of BarButton.icon.
void _touchReader(String id, {required bool grow, bool desktop = false}) {
  const size = Size(400, 560);
  decideScene(
    id,
    size: size,
    platform: desktop ? TargetPlatform.windows : TargetPlatform.android,
    panel: false,
    wrapApp: (tester) => smallScreenProviders(
      tester,
      screen: SmallScreen.reader,
      size: size,
      compactMenuMode: false,
      desktop: desktop,
    ),
    build: (context) => const MainWindowScreen(),
  );
}

void main() {
  _touch('touch_fields', grow: false);
  _touch('desktop_fields', grow: false, platform: TargetPlatform.windows);
  _touchReader('touch_topbar', grow: false);
  _touchReader('desktop_topbar', grow: false, desktop: true);
}
