#!/usr/bin/env bash
# persona_screenshots.sh — capture le rendu réel de la 1re séance adaptée pour
# chaque combo (sport × niveau), via le pipeline réel TemplateLoader → ProgramAdapter
# (scénario App/UIReviewScenarioContainer.swift : ui_review_persona_<sport>_<level>).
#
# C'est `xcrun simctl` (CLI) — PAS le MCP. Headless, scriptable, reproductible,
# aucun risque de hang (cf incident calibration 2026-07-05 : mcp app_build a
# pendu 5h). Bâti sur le pattern de real_render_screenshots.sh.
#
# Usage :
#   scripts/persona_screenshots.sh                       # tous les sports, 3 niveaux
#   SPORTS="running yoga" LEVELS="beginner competitive" scripts/persona_screenshots.sh
#
# Sortie : /tmp/persona-screens/<sport>_<level>.png (à relire visuellement / donner aux agents persona).
set -euo pipefail

BUNDLE_ID="com.sopddl.coachingsage.app"
SCHEME="CoachingSage"
PROJECT="CoachingSage.xcodeproj"
OUT_DIR="${OUT_DIR:-/tmp/persona-screens}"
UDID="${UDID:-$(xcrun simctl list devices available | grep -m1 -oE '[0-9A-F-]{36}' || true)}"

SPORTS="${SPORTS:-running cycling swimming triathlon strength_training yoga hiit hiking tennis football}"
# 3 personas : débutant / initié / expert → beginner / regular / competitive
# (skip "recreational" : hors scope des 3 personas demandés par Sophie)
LEVELS="${LEVELS:-beginner regular competitive}"

echo "▸ UDID=$UDID  SPORTS=[$SPORTS]  LEVELS=[$LEVELS]  OUT=$OUT_DIR"
mkdir -p "$OUT_DIR"

APP=$(find ~/Library/Developer/Xcode/DerivedData/${SCHEME}-*/Build/Products/Debug-iphonesimulator -maxdepth 1 -name "${SCHEME}.app" 2>/dev/null | head -1)
if [[ "${BUILD:-0}" == "1" || -z "$APP" ]]; then
  echo "▸ build…"
  xcodebuild build -project "$PROJECT" -scheme "$SCHEME" \
    -destination "platform=iOS Simulator,id=$UDID" >/dev/null 2>&1
  APP=$(find ~/Library/Developer/Xcode/DerivedData/${SCHEME}-*/Build/Products/Debug-iphonesimulator -maxdepth 1 -name "${SCHEME}.app" 2>/dev/null | head -1)
fi
echo "▸ app=$APP"

xcrun simctl bootstatus "$UDID" -b >/dev/null 2>&1 || true
xcrun simctl install "$UDID" "$APP" >/dev/null

for sport in $SPORTS; do
  for level in $LEVELS; do
    scn="ui_review_persona_${sport}_${level}"
    xcrun simctl terminate "$UDID" "$BUNDLE_ID" >/dev/null 2>&1 || true
    SIMCTL_CHILD_UI_TEST_SCENARIO="$scn" \
      xcrun simctl launch "$UDID" "$BUNDLE_ID" >/dev/null
    sleep 7
    out="$OUT_DIR/${sport}_${level}.png"
    xcrun simctl io "$UDID" screenshot "$out" >/dev/null 2>&1
    echo "  ✓ $out"
  done
done
xcrun simctl terminate "$UDID" "$BUNDLE_ID" >/dev/null 2>&1 || true
echo "▸ fini. $(ls "$OUT_DIR" | wc -l | tr -d ' ') captures dans $OUT_DIR"
