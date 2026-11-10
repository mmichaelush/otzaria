// c-q4: note cards in the notes manager (touch 188 / 48 buttons, desktop 170 / 32).
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

// ── open question 5: note cards in the notes manager ────────────────────────

class _LibraryBloc extends MockBloc<LibraryEvent, LibraryState>
    implements LibraryBloc {}

PersonalNote _note(String id, String book, int? line, String text, int day) =>
    PersonalNote(
      id: id,
      bookId: book,
      lineNumber: line,
      lastKnownLineNumber: line == null ? 12 : null,
      status: line == null
          ? PersonalNoteStatus.missing
          : PersonalNoteStatus.located,
      content: text,
      contentPlain: text,
      contentFormat: PersonalNoteContentFormat.plain,
      createdAt: DateTime(2026, 11, day, 9, 30),
      updatedAt: DateTime(2026, 11, day, 9, 30),
    );

final _notes = [
  _note('n1', 'בראשית', 3, 'יהי אור: עיין ברש"י, שהאור נגנז לצדיקים לעתיד לבוא.', 2),
  _note('n2', 'בראשית', 7, 'הרקיע מבדיל בין מים למים. לבדוק במדרש רבה פרשה ד.', 3),
  _note('n3', 'בראשית', null, 'הערה שמיקומה אבד אחרי עדכון הספר.', 4),
  _note('n4', 'בראשית', 10, 'ויקרא אלהים ליבשה ארץ.', 5),
];

class _Repo extends PersonalNotesRepository {
  @override
  Future<List<BookNotesInfo>> listBooksWithNotes() async => [
    BookNotesInfo(
      bookId: 'בראשית',
      noteCount: _notes.length,
      lastUpdated: DateTime(2026, 11, 5),
    ),
  ];

  @override
  Future<List<PersonalNote>> loadNotes(String bookId, {int? categoryId}) async =>
      _notes.where((n) => n.bookId == bookId).toList();
}

void _notesScene(String id, Size size, {TargetPlatform platform = TargetPlatform.android}) {
  decideScene(
    id,
    size: size,
    platform: platform,
    wrapApp: (tester) {
      final repo = _Repo();
      final notesBloc = PersonalNotesBloc(repository: repo);
      final settingsBloc = SettingsBloc(repository: SettingsRepository());
      final libraryBloc = _LibraryBloc();
      whenListen(
        libraryBloc,
        const Stream<LibraryState>.empty(),
        initialState: LibraryState(
          library: Library(categories: []),
          isLoading: false,
        ),
      );
      addTearDown(() async {
        await tester.pumpWidget(const SizedBox.shrink());
        await notesBloc.close();
        await settingsBloc.close();
        await libraryBloc.close();
      });
      return (app) => MultiBlocProvider(
        providers: [
          BlocProvider<SettingsBloc>.value(value: settingsBloc),
          BlocProvider<LibraryBloc>.value(value: libraryBloc),
          BlocProvider<PersonalNotesBloc>.value(value: notesBloc),
        ],
        child: app,
      );
    },
    build: (context) => Scaffold(body: PersonalNotesManagerScreen(repository: _Repo())),
    afterPump: (tester, context) async {
      // At phone width the navigation pane opens as an overlay: close it.
      if (size.width < 600) await tester.tapAt(const Offset(6, 700));
      for (var i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
    },
  );
}

void main() {
  for (final (w, label) in [(400.0, 'phone'), (820.0, 'tablet')]) {
    _notesScene('touch_$label', Size(w, 760));
  }
  _notesScene('desktop_tablet', const Size(820, 760), platform: TargetPlatform.windows);
}
