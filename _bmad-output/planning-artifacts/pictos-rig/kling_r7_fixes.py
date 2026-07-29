import pathlib
import sys
import time

sys.path.insert(0, ".")
from kling_animate import STYLE, kling

# Fixes round 7 Sophie (07-13 18h18) — wall-sit genou gauche plié pareil,
# rdl superposition haltère arrière, lunge PIED DROIT avance (Kling faisait
# une fente arrière : vérifié frames denses, le pied gauche partait en arrière).

M = pathlib.Path("ai-explo/muscu")
V4 = pathlib.Path("ai-explo/vague4")

TEMPO = " The movement is SLOW and controlled, tutorial pace, never fast or jerky."

FIXES = {
    "wall-sit_v6": (V4 / "M_wall-sit_kneefix.png",
        "He HOLDS the wall sit completely still for the entire animation: back flat "
        "against the wall, BOTH knees bent at the same angle, both thighs horizontal, "
        "both feet flat side by side on the mat exactly as in the first frame — "
        "nothing about his legs ever moves or straightens. Only his chest rises and "
        "falls as he breathes calmly." + STYLE),
    "rdl-dumbbell_v7": (M / "A_m_stand_db_2db.png",
        "Two slow Romanian deadlift repetitions: from standing fully upright he hinges "
        "at the hips pushing them far back, back FLAT, and BOTH dumbbells — one in "
        "each hand — slide down along his legs to mid-shin, then he stands ALL the "
        "way back up to fully upright, then repeats once, ending fully upright. "
        "LAYERING RULE: the far dumbbell (far hand) always stays slightly BEHIND the "
        "near leg, partially hidden by it — it NEVER crosses or passes in front of "
        "the near leg. Both dumbbells stay countable the whole time." + TEMPO + STYLE),
    "lunge-dumbbell_v11": (M / "A_m_lunge_start.png",
        "One slow forward lunge, torso staying vertical: standing at the back end of "
        "the mat, his NEAR foot (the right foot, closer to the camera) STEPS FORWARD "
        "along the mat into a deep lunge — front knee above the ankle, rear knee "
        "bending down, rear heel lifting. CRITICAL: his FAR (left) foot stays PLANTED "
        "on its spot the entire time, it NEVER slides or steps backward — only the "
        "near foot travels forward. The dumbbells stay in his hands at his sides."
        + TEMPO + STYLE),
}

if __name__ == "__main__":
    fails = []
    for slug, (src, prompt) in FIXES.items():
        assert src.exists(), f"source manquante: {src}"
        if not kling(slug, src, prompt):
            fails.append(slug)
        time.sleep(3)
    print(f"FIXES R7 TERMINÉS — fails: {fails}", flush=True)
