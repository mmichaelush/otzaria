import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:otzaria/core/windowing/app_window_controller.dart';
import 'package:otzaria/core/windowing/app_window_scope.dart';
import 'package:otzaria/core/windowing/window_fullscreen_cubit.dart';
import 'package:otzaria/core/windowing/window_manager_app_window_controller.dart';
import 'package:otzaria/navigation/bloc/navigation_bloc.dart';
import 'package:otzaria/navigation/bloc/navigation_event.dart';
import 'package:otzaria/navigation/bloc/navigation_state.dart';
import 'package:otzaria/navigation/view/custom_title_bar.dart';
import 'package:otzaria/settings/engine/settings_bloc.dart';
import 'package:otzaria/settings/engine/settings_event.dart';
import 'package:otzaria/settings/engine/settings_state.dart';
import 'package:otzaria/tabs/bloc/tabs_bloc.dart';
import 'package:otzaria/tabs/bloc/tabs_event.dart';
import 'package:otzaria/tabs/bloc/tabs_state.dart';

import '../dd.dart';

/// m7: שורת הכותרת בהגדלת טקסט ×2.0 (כותרת מסך רגיל, ו"עיון" בלי כרטיסיות).
void main() {
  for (final (id, screen, scale) in [
    ('M7__settings_x1', Screen.settings, 1.0),
    ('M7__settings_x2', Screen.settings, 2.0),
    ('M7__settings_x2_5', Screen.settings, 2.5),
    ('M7__reading_empty_x2_5', Screen.reading, 2.5),
  ]) {
    ddScene(
      id,
      wide: const Size(900, 140),
      narrowHeight: 140,
      tweak: _desktop,
      afterPump: (tester, context) async =>
          debugDefaultTargetPlatformOverride = null,
      build: (context) => MediaQuery(
        data: MediaQuery.of(context).copyWith(
          textScaler: TextScaler.linear(scale),
        ),
        child: AppWindowScope(
          controller: _Window(),
          geometry: const WindowManagerAppWindowController(),
          child: MultiBlocProvider(
            providers: [
              BlocProvider<TabsBloc>(
                create: (_) =>
                    _Tabs(TabsState(tabs: const [], currentTabIndex: 0)),
              ),
              BlocProvider<NavigationBloc>(
                create: (_) => _Nav(NavigationState(currentScreen: screen)),
              ),
              BlocProvider<SettingsBloc>(
                create: (_) => _Settings(SettingsState.initial()),
              ),
              BlocProvider<WindowFullscreenCubit>(
                create: (_) => WindowFullscreenCubit(
                  initial: false,
                  persist: (_) async {},
                ),
              ),
            ],
            child: Padding(
              padding: EdgeInsets.zero,
              child: Align(
                alignment: Alignment.topCenter,
                child: CustomTitleBar(onReadingSettingsPressed: () {}),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Window extends Fake implements AppWindowController {
  final changes = ChangeNotifier();
  @override
  Listenable get stateChanges => changes;
  @override
  Future<bool> isMaximized() async => false;
  @override
  Future<bool> isFullScreen() async => false;
}

class _Tabs extends Cubit<TabsState> implements TabsBloc {
  _Tabs(super.initialState);
  @override
  void add(TabsEvent event) {}
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Nav extends Cubit<NavigationState> implements NavigationBloc {
  _Nav(super.initialState);
  @override
  void add(NavigationEvent event) {}
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Settings extends Bloc<SettingsEvent, SettingsState>
    implements SettingsBloc {
  _Settings(super.initialState) {
    on<SettingsEvent>((event, emit) {});
  }
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// טיפוגרפיית מחשב (Segoe UI = Rubik בבדיקות) כמו באפליקציה ב-Windows.
ThemeData _desktop(ThemeData base) {
  debugDefaultTargetPlatformOverride = TargetPlatform.windows;
  return ddTheme(dark: base.brightness == Brightness.dark);
}
