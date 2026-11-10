// Decision-page scenes (untracked). Like dd.dart's ddScene, plus: a target
// platform per scene (desktop vs touch), an optional wrapper AROUND the
// MaterialApp (providers of the real main window), any canvas size, and every
// font of the bundle (book fonts too).
//
// Output: <OUT>/<lw|ld>/<id>.png  (DARK=0|1).
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:otzaria/settings/engine/app_settings_store.dart';
import 'package:otzaria/theme/theme_exports.dart';

import '../helpers/memory_settings_cache.dart';
import 'dd.dart' show ddTheme, kDdDark, kDdOut, kDdOnly;
import 'shot.dart' show loadShotFonts, settleShot;

bool _allFonts = false;

Future<void> loadAllFonts() async {
  await loadShotFonts();
  if (_allFonts) return;
  _allFonts = true;
  final roboto = FontLoader('Roboto')
    ..addFont(rootBundle.load('fonts/Rubik-VariableFont_wght.ttf'));
  await roboto.load();
  final manifest =
      jsonDecode(await rootBundle.loadString('FontManifest.json')) as List;
  for (final entry in manifest.cast<Map<String, dynamic>>()) {
    final family = entry['family'] as String;
    final loader = FontLoader(family);
    for (final font in (entry['fonts'] as List).cast<Map<String, dynamic>>()) {
      loader.addFont(rootBundle.load(font['asset'] as String));
    }
    try {
      await loader.load();
    } catch (_) {}
  }
}

String get decideVariant => kDdDark ? 'ld' : 'lw';

void decideScene(
  String id, {
  required Size size,
  required Widget Function(BuildContext context) build,
  TargetPlatform platform = TargetPlatform.windows,
  Color? seedLight,
  Color? seedDark,
  bool compact = false,
  ThemeData Function(ThemeData base)? tweak,
  bool panel = true,
  double ratio = 2,
  Widget Function(Widget app)? Function(WidgetTester tester)? wrapApp,
  Future<void> Function(WidgetTester tester, BuildContext context)? afterPump,
  VoidCallback? before,
  VoidCallback? after,
  bool lightOnly = false,
}) {
  if (kDdOnly.isNotEmpty && !id.contains(kDdOnly)) return;
  if (lightOnly && kDdDark) return;
  testWidgets('decide: $id', (tester) async {
    debugDefaultTargetPlatformOverride = platform;
    before?.call();
    try {
      await loadAllFonts();
      await Settings.init(cacheProvider: MemorySettingsCache());
      final prevOnError = FlutterError.onError;
      FlutterError.onError = (details) {
        if (details.exceptionAsString().contains('overflowed by')) {
          // ignore: avoid_print
          print('SHOT-OVERFLOW $id ${details.exceptionAsString().split('\n').first}');
          return;
        }
        prevOnError?.call(details);
      };
      addTearDown(() => FlutterError.onError = prevOnError);

      tester.view.physicalSize = size * ratio;
      tester.view.devicePixelRatio = ratio;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      debugDisableShadows = false;
      addTearDown(() => debugDisableShadows = true);

      final boundaryKey = GlobalKey();
      final homeKey = GlobalKey();
      ThemeData theme(bool dark) => ddTheme(
        dark: dark,
        seedLight: seedLight,
        seedDark: seedDark,
        compact: compact,
        tweak: tweak,
      );
      final wrap = wrapApp?.call(tester);
      final app = MaterialApp(
        debugShowCheckedModeBanner: false,
        localizationsDelegates: const [
          GlobalCupertinoLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        supportedLocales: const [Locale('he', 'IL')],
        locale: const Locale('he', 'IL'),
        theme: theme(false),
        darkTheme: theme(true),
        themeMode: kDdDark ? ThemeMode.dark : ThemeMode.light,
        builder: (context, child) =>
            RepaintBoundary(key: boundaryKey, child: child),
        home: Builder(
          key: homeKey,
          builder: (context) {
            final content = build(context);
            final bg = panel ? AppSurfaces.panelBackground(context) : null;
            return Material(
              type: MaterialType.transparency,
              child: bg == null
                  ? content
                  : ColoredBox(color: bg, child: content),
            );
          },
        ),
      );
      await tester.pumpWidget(wrap == null ? app : wrap(app));
      await settleShot(tester);
      if (afterPump != null) {
        await afterPump(tester, homeKey.currentContext!);
        await settleShot(tester);
      }
      final boundary =
          boundaryKey.currentContext!.findRenderObject()
              as RenderRepaintBoundary;
      final bytes = await tester.runAsync<Uint8List>(() async {
        final image = await boundary.toImage(pixelRatio: ratio);
        final data = await image.toByteData(format: ui.ImageByteFormat.png);
        image.dispose();
        return data!.buffer.asUint8List();
      });
      final dir = Directory('$kDdOut/$decideVariant')
        ..createSync(recursive: true);
      final file = File('${dir.path}/$id.png')..writeAsBytesSync(bytes!);
      // ignore: avoid_print
      print('SHOT-OK ${file.path}');
    } finally {
      debugDisableShadows = true;
      after?.call();
      debugDefaultTargetPlatformOverride = null;
    }
  });
}

/// A dashed outline that marks a widget's real touch area (scene-only).
class HitOutline extends StatelessWidget {
  const HitOutline({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => CustomPaint(
    foregroundPainter: _DashPainter(Theme.of(context).colorScheme.error),
    child: child,
  );
}

class _DashPainter extends CustomPainter {
  _DashPainter(this.color);
  final Color color;
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = color
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    final r = Offset.zero & size;
    void dash(Offset a, Offset b) {
      final len = (b - a).distance;
      final d = (b - a) / len;
      for (double t = 0; t < len; t += 6) {
        canvas.drawLine(a + d * t, a + d * (t + 3 > len ? len : t + 3), p);
      }
    }

    dash(r.topLeft, r.topRight);
    dash(r.topRight, r.bottomRight);
    dash(r.bottomRight, r.bottomLeft);
    dash(r.bottomLeft, r.topLeft);
  }

  @override
  bool shouldRepaint(_DashPainter old) => old.color != color;
}
