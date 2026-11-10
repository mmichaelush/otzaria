// Decision-catalog playground (untracked, stage B of the design-system task).
//
// Renders the CURRENT look and each ALTERNATIVE of a design decision (DD-xx)
// with the real Otzaria theme, real components, Hebrew content and the real
// icon/book fonts. One PNG per (scene, variant).
//
// Run (always through the lock):
//   bash /c/qa10/flt.sh <worktree> test --no-pub test/_shots/dd/<file>_test.dart \
//     --dart-define=DARK=0|1 --dart-define=NARROW=0|1 --dart-define=OUT=C:/qa10/dd/shots
// Output: <OUT>/<variant>/<id>.png  with variant = lw | ld | nw | nd
//   (l/n = light/dark, w/n = wide/narrow(phone)).
//
// Scene ids: `DD-02__current`, `DD-02__A`, `DD-02__B` ... (double underscore
// separates the decision id from the option key). Optional extra suffix for a
// second example of the same option: `DD-02__C__long`.
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:otzaria/settings/engine/app_settings_store.dart';
import 'package:otzaria/theme/theme_exports.dart';

import '../helpers/memory_settings_cache.dart';
import 'shot.dart' show loadShotFonts, settleShot;

const kDdDark = String.fromEnvironment('DARK', defaultValue: '0') == '1';
const kDdNarrow = String.fromEnvironment('NARROW', defaultValue: '0') == '1';
const kDdOut = String.fromEnvironment('OUT', defaultValue: 'C:/qa10/dd/shots');
const kDdOnly = String.fromEnvironment('ONLY');

/// Pixel ratio of every PNG: 2 keeps 12px captions readable when zoomed.
const double kDdRatio = 2;

/// Phone width used for every narrow variant.
const double kPhoneWidth = 360;

/// lw = light wide, ld = dark wide, nw = light narrow, nd = dark narrow.
String get ddVariantName =>
    (kDdNarrow ? 'n' : 'l') + (kDdDark ? 'd' : 'w');

/// The real app theme for a seed. [tweak] lets an alternative change the
/// theme the way the proposal would (e.g. a new textTheme).
ThemeData ddTheme({
  required bool dark,
  Color? seedLight,
  Color? seedDark,
  bool compact = false,
  ThemeData Function(ThemeData base)? tweak,
}) {
  final seed = dark
      ? (seedDark ?? AppSeedColors.defaultDark)
      : (seedLight ?? AppSeedColors.defaultLight);
  final cs = AppThemeData.createColorScheme(
    seed,
    dark ? Brightness.dark : Brightness.light,
  );
  final variant = AppThemeVariant.ofSeed(seed);
  final base = dark
      ? AppThemeData.dark(cs, compactMenuMode: compact, variant: variant)
      : AppThemeData.light(cs, compactMenuMode: compact, variant: variant);
  return tweak == null ? base : tweak(base);
}

/// Registers one decision scene.
///
/// [wide] is the logical canvas for wide variants; [narrowHeight] the canvas
/// height at phone width (null = the scene has no phone variant and is
/// skipped there). [build] gets a context below the Navigator, already
/// themed. [panel] paints `AppSurfaces.panelBackground` behind the content.
/// [afterPump] may open a dialog / hover / focus before the PNG is written.
void ddScene(
  String id, {
  required Size wide,
  double? narrowHeight,
  required Widget Function(BuildContext context) build,
  ThemeData Function(ThemeData base)? tweak,
  Color? seedLight,
  Color? seedDark,
  bool compact = false,
  bool panel = true,
  Color Function(BuildContext context)? background,
  Future<void> Function(WidgetTester tester, BuildContext context)? afterPump,
}) {
  if (kDdOnly.isNotEmpty && !id.contains(kDdOnly)) return;
  if (kDdNarrow && narrowHeight == null) return;
  testWidgets('dd: $id', (tester) async {
    await loadShotFonts();
    await Settings.init(cacheProvider: MemorySettingsCache());
    final prevOnError = FlutterError.onError;
    FlutterError.onError = (details) {
      if (details.exceptionAsString().contains('overflowed by')) {
        // ignore: avoid_print
        print('SHOT-OVERFLOW $id');
        return;
      }
      prevOnError?.call(details);
    };
    addTearDown(() => FlutterError.onError = prevOnError);

    final size = kDdNarrow ? Size(kPhoneWidth, narrowHeight!) : wide;
    tester.view.physicalSize = size * kDdRatio;
    tester.view.devicePixelRatio = kDdRatio;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    // flutter_test turns shadows into hard black outlines; real elevation
    // matters for these comparisons. Restored before the test ends (the
    // binding checks the flag is back to true).
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
    await tester.pumpWidget(MaterialApp(
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
          final bg = background?.call(context) ??
              (panel ? AppSurfaces.panelBackground(context) : null);
          return Material(
            type: MaterialType.transparency,
            child: bg == null ? content : ColoredBox(color: bg, child: content),
          );
        },
      ),
    ));
    await settleShot(tester);
    if (afterPump != null) {
      await afterPump(tester, homeKey.currentContext!);
      await settleShot(tester);
    }

    final boundary =
        boundaryKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    final bytes = await tester.runAsync<Uint8List>(() async {
      final image = await boundary.toImage(pixelRatio: kDdRatio);
      final data = await image.toByteData(format: ui.ImageByteFormat.png);
      image.dispose();
      return data!.buffer.asUint8List();
    });
    final dir = Directory('$kDdOut/$ddVariantName')..createSync(recursive: true);
    final file = File('${dir.path}/$id.png')..writeAsBytesSync(bytes!);
    debugDisableShadows = true;
    // ignore: avoid_print
    print('SHOT-OK ${file.path}');
  });
}

/// Uniform outer padding for a scene. Scenes never label themselves: the HTML
/// page shows the option name next to the image.
class DdBox extends StatelessWidget {
  const DdBox({super.key, required this.child, this.padding = 24});
  final Widget child;
  final double padding;

  @override
  Widget build(BuildContext context) =>
      Padding(padding: EdgeInsets.all(padding), child: child);
}
