#!/bin/bash
# usage: shoot.sh <worktree> <slug> <before|after> <scene test file>...
#   env VARIANTS (default "lw ld nw nd"), ONLY=<scene id substring>
# Scenes use test/_shots/dd.dart (ddScene). One flutter run per variant.
# Output: C:/qa11/uifix/changes/<slug>/<phase>/<variant>/<scene id>.png
wt="$1"; slug="$2"; phase="$3"; shift 3
base=C:/qa11/uifix/changes/$slug/$phase
variants=${VARIANTS:-lw ld nw nd}
mkdir -p "$base"
for f in "$@"; do
  for v in $variants; do
    dark=0; [ "${v:1:1}" = d ] && dark=1
    narrow=0; [ "${v:0:1}" = n ] && narrow=1
    log="$base/log-$v-$(basename $f .dart).txt"
    timeout 1200 bash /c/qa10/flt.sh "$wt" test --no-pub --timeout 180s "$f" \
      --dart-define=DARK=$dark --dart-define=NARROW=$narrow --dart-define=OUT=$base \
      ${ONLY:+--dart-define=ONLY=$ONLY} > "$log" 2>&1
    echo "$phase $v $(basename $f): $(grep -c 'SHOT-OK' "$log") ok, $(grep -c 'Some tests failed\|SHOT-FAIL' "$log") fail"
  done
done
