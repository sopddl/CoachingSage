#!/usr/bin/env bash
# real_render_screenshots.sh — capture le RENDU RÉEL localisé de l'app (chrome inclus)
# via la vraie app dans le simulateur. Sert à attraper les fuites i18n / casses de
# layout qui n'apparaissent PAS dans les snapshot tests swift (limite : en logic-test
# mode, Bundle.main ne résout pas les Text(LocalizedStringKey) → le swizzle ne marche
# pas ; cf memory feedback_template_quality_swift_regression_net + dette_snapshot_en_bundle_swizzle).
#
# C'est `xcrun simctl` (CLI, autorisé) — PAS le MCP. Headless, scriptable, reproductible.
#
# Usage :
#   scripts/real_render_screenshots.sh                      # langues es+en, écrans chrome-lourds par défaut
#   scripts/real_render_screenshots.sh "es" "ui_review_dashboard_active_mixed ui_review_progress_with_hk_history"
#   LANGS="es en" SCENARIOS="ui_review_session_hub_real_strength_training" scripts/real_render_screenshots.sh
#
# Sortie : /tmp/render-screens/<scenario>__<lang>.png  (à relire visuellement).
set -euo pipefail

BUNDLE_ID="com.sopddl.coachingsage.app"
SCHEME="CoachingSage"
PROJECT="CoachingSage.xcodeproj"
OUT_DIR="${OUT_DIR:-/tmp/render-screens}"
# iPhone 15 Pro par défaut (override via UDID=...)
UDID="${UDID:-$(xcrun simctl list devices available | grep -m1 -oE '[0-9A-F-]{36}' || true)}"

LANGS="${1:-${LANGS:-es en}}"
# IMPORTANT pour l'i18n : n'utiliser que des scénarios qui reflètent la VRAIE
# localisation. Les scénarios `_real_*` sont adossés à TemplateLoader → contenu réel
# localisé. Les scénarios FIXTURE (dashboard_active_*, session_focus_strength, …) ont
# des noms de séance/warmup HARDCODÉS EN FR (pour tester le layout) → faux positifs i18n.
# Le questionnaire passe par les vraies strings → fiable aussi.
SCENARIOS="${2:-${SCENARIOS:-ui_review_session_hub_real_running ui_review_session_hub_real_strength_training ui_review_session_hub_real_cycling ui_review_session_hub_real_yoga ui_review_session_hub_real_hiit ui_review_questionnaire_thread_edit}}"

echo "▸ UDID=$UDID  LANGS=[$LANGS]  OUT=$OUT_DIR"
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

for lang in $LANGS; do
  for scn in $SCENARIOS; do
    xcrun simctl terminate "$UDID" "$BUNDLE_ID" >/dev/null 2>&1 || true
    SIMCTL_CHILD_UI_TEST_LANG="$lang" SIMCTL_CHILD_UI_TEST_SCENARIO="$scn" \
      xcrun simctl launch "$UDID" "$BUNDLE_ID" >/dev/null
    sleep 4
    out="$OUT_DIR/${scn}__${lang}.png"
    xcrun simctl io "$UDID" screenshot "$out" >/dev/null 2>&1
    echo "  ✓ $out"
  done
done
xcrun simctl terminate "$UDID" "$BUNDLE_ID" >/dev/null 2>&1 || true
echo "▸ fini. Relire les PNG dans $OUT_DIR"
