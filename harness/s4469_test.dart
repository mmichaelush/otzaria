import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:otzaria/personal_notes/models/personal_note.dart';
import 'package:otzaria/personal_notes/widgets/personal_note_content_view.dart';

import '../dd.dart';

PersonalNote _note() => PersonalNote(
  id: 'n',
  bookId: 'b',
  lineNumber: 1,
  displayTitle: 't',
  lastKnownLineNumber: 1,
  status: PersonalNoteStatus.located,
  content: jsonEncode([
    {
      'insert':
          'השורה הזאת ארוכה מספיק כדי שהתוכנה תרד שורה כי נגמר המקום בלי שהמשתמש לחץ אנטר ובלי שהתחיל נושא חדש\n',
    },
    {'insert': 'פסקה חדשה אחרי אנטר כאן מתחיל נושא אחר\n'},
    {'insert': 'עוד פסקה קצרה\n'},
  ]),
  contentPlain: '',
  contentFormat: PersonalNoteContentFormat.quillDelta,
  createdAt: DateTime(2026),
  updatedAt: DateTime(2026),
);

Widget _box(BuildContext context, Widget child) => DecoratedBox(
  decoration: BoxDecoration(
    border: Border.all(color: Theme.of(context).dividerColor),
    borderRadius: BorderRadius.circular(8),
  ),
  child: Padding(padding: const EdgeInsets.all(12), child: child),
);

void main() {
  ddScene(
    'S4469__note_paragraphs',
    wide: const Size(560, 470),
    narrowHeight: 520,
    build: (context) => DdBox(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _box(context, PersonalNoteContentView(note: _note())),
          const SizedBox(height: 16),
          _box(
            context,
            PersonalNoteContentView(note: _note(), interactive: false),
          ),
        ],
      ),
    ),
  );
}
