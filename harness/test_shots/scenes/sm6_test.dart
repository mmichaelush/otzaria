import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:otzaria/tabs/models/tool_tab.dart';
import 'package:otzaria/tabs/view/pane_drag_handle.dart';
import 'package:otzaria/theme/theme_exports.dart';

import '../dd.dart';

/// m6: ידית הגרירה הצפה במחשב, באמצע גרירה כשהעכבר כבר יצא מהחלונית.
void main() {
  final pane = ToolTab(toolId: 'x.plugin', title: 'מקבילות');
  ddScene(
    'M6__dragging_pointer_outside',
    wide: const Size(640, 360),
    narrowHeight: 360,
    tweak: (t) => t.copyWith(platform: TargetPlatform.windows),
    build: (context) => Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 120),
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
        ),
        child: PaneDragHandleScope(
          pane: pane,
          enabled: true,
          child: FloatingPaneDragHandle(
            child: ColoredBox(
              color: AppSurfaces.readerBackground(context),
              child: const Center(child: Text('תוכן התוסף')),
            ),
          ),
        ),
      ),
    ),
    afterPump: (tester, context) async {
      final handle = find.byType(PaneDragHandleButton);
      final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
      final page = tester.getRect(find.byType(FloatingPaneDragHandle));
      await mouse.addPointer(location: page.center);
      await mouse.moveTo(page.topLeft + const Offset(20, 20));
      await tester.pump(const Duration(milliseconds: 300));
      await mouse.moveTo(tester.getCenter(handle));
      await tester.pump(const Duration(milliseconds: 300));
      await mouse.down(tester.getCenter(handle));
      await tester.pump();
      await mouse.moveBy(const Offset(-30, 40));
      await tester.pump();
      await mouse.moveTo(Offset(page.center.dx, page.bottom + 50));
      await tester.pump(const Duration(milliseconds: 400));
    },
  );
}
