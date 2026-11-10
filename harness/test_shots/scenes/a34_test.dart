// Row 34: full-width notice banners in the search results.
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:otzaria/search/bloc/search_bloc.dart';
import 'package:otzaria/search/bloc/search_event.dart';
import 'package:otzaria/search/bloc/search_state.dart';
import 'package:otzaria/search/view/tantivy_search_results.dart';
import 'package:otzaria/settings/engine/app_settings_store.dart';
import 'package:otzaria/settings/engine/settings_bloc.dart';
import 'package:otzaria/settings/engine/settings_event.dart';
import 'package:otzaria/settings/engine/settings_repository.dart';
import 'package:otzaria/settings/engine/settings_state.dart';
import 'package:otzaria/settings/l10n/settings_l10n_exports.dart';
import 'package:otzaria/tabs/models/searching_tab.dart';
import 'package:otzaria/widgets/feedback/app_info_banner.dart';
import 'package:otzaria/theme/theme_exports.dart';
import 'package:otzaria_search_engine/otzaria_search_engine.dart';

import '../dd.dart';
import '../../support/golden_fonts.dart';

class _MockSettingsBloc extends MockBloc<SettingsEvent, SettingsState>
    implements SettingsBloc {}

class _SearchBloc extends SearchBloc {
  _SearchBloc(SearchState s) {
    emit(s);
  }

  @override
  void add(SearchEvent event) {
    if (event is! LoadMoreResults) super.add(event);
  }
}

SearchResult _result(int i) => SearchResult(
  id: BigInt.from(i),
  title: 'ספר $i',
  reference: 'סימן $i',
  text: 'טקסט לדוגמה $i',
  segment: BigInt.from(i),
  isPdf: false,
  filePath: 'book_$i.txt',
  mergedCount: 1,
  merged: const [],
  textStatus: TextStatus.ok,
  continuesToNextLine: false,
);

void _scene(String id, Widget Function(BuildContext) build) => ddScene(
  id,
  wide: const Size(800, 300),
  narrowHeight: 360,
  tweak: (t) => t.copyWith(
    textTheme: t.textTheme.apply(fontFamily: goldenUiFontFamily),
  ),
  build: (context) {
    Settings.setValue<String>(SettingsRepository.keySettingsLanguage, 'he');
    return SettingsTextScope(
      language: SettingsLanguage.hebrew,
      child: build(context),
    );
  },
);

void main() {
  _scene('a34__truncated_banner', (context) {
    final settings = _MockSettingsBloc();
    whenListen(
      settings,
      const Stream<SettingsState>.empty(),
      initialState: SettingsState.initial(),
    );
    return MultiBlocProvider(
      providers: [
        BlocProvider<SearchBloc>.value(
          value: _SearchBloc(
            SearchState(
              searchQuery: 'ספר',
              totalResults: 2,
              results: [_result(1), _result(2)],
              resultsTruncated: true,
            ),
          ),
        ),
        BlocProvider<SettingsBloc>.value(value: settings),
      ],
      child: SizedBox(
        height: 300,
        child: TantivySearchResults(tab: SearchingTab('חיפוש', 'ספר')),
      ),
    );
  });
  _scene('a34__semantic_banners', (context) => const _SemanticBanners());
}

/// The two private banners of semantic_search_results_screen.dart, mirrored.
class _SemanticBanners extends StatelessWidget {
  const _SemanticBanners();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    // AFTER: AppInfoBanner with an 8 inset, as in the screen.
    Widget banner(AppInfoBannerTone tone, String message) => Padding(
      padding: const EdgeInsets.fromLTRB(
        AppTokens.spaceSM,
        AppTokens.spaceSM,
        AppTokens.spaceSM,
        0,
      ),
      child: AppInfoBanner(tone: tone, message: message),
    );
    return Column(
      children: [
        banner(
          AppInfoBannerTone.error,
          'החיפוש החכם לא זמין כרגע, ומוצגות התאמות מילוליות בלבד.',
        ),
        banner(
          AppInfoBannerTone.info,
          'החיפוש מדויק יותר כשמצמצמים אותו לספרים או לקטגוריות מסוימות.',
        ),
        const Expanded(child: SizedBox()),
      ],
    );
  }
}

// keep the import used in both phases
// ignore: unused_element
const _keep = AppInfoBanner;
