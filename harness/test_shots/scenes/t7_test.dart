import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:otzaria/settings/widgets/settings_card.dart';
import 'package:otzaria/widgets/controls/action_buttons.dart';
import 'package:otzaria/widgets/misc/app_menu_exports.dart';

import '../dd.dart';

void main() {
  ddScene(
    'T7__settings_card',
    wide: const Size(640, 520),
    narrowHeight: 600,
    build: (context) => DdBox(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SettingsCard(
            title: 'גיבוי ושחזור',
            subtitle: 'שמירת ההגדרות והסימניות לקובץ',
            children: [
              SettingsActionTile.text(
                icon: FluentIcons.save_24_regular,
                title: 'גיבוי ההגדרות',
                subtitle: 'שמירת כל ההגדרות לקובץ במחשב',
                stacked: true,
                actions: [
                  ActionButton.neutral(text: 'גבה עכשיו', onPressed: () {}),
                ],
              ),
            ],
          ),
          SettingsCard(
            title: 'שפה',
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: AppDropdownField<int>(
                  value: 0,
                  decoration: const InputDecoration(labelText: 'שפת הממשק'),
                  entries: const [
                    AppMenuEntry(value: 0, label: 'עברית'),
                    AppMenuEntry(value: 1, label: 'English'),
                  ],
                  onSelected: (_) {},
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
