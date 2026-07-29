import pathlib
import sys
import time

sys.path.insert(0, ".")
from kling_animate import STYLE, kling

# Fixes round 6 Sophie (07-13 17h41) — wall-sit jambes au même angle (2 pieds
# alignés), rdl DEUX haltères lisibles. (lunge_v10 = palindrome ffmpeg, pas de Kling.)

M = pathlib.Path("ai-explo/muscu")
V4 = pathlib.Path("ai-explo/vague4")

TEMPO = " The movement is SLOW and controlled, tutorial pace, never fast or jerky."

FIXES = {
    "wall-sit_v5": (V4 / "M_wall-sit_legsfix.png",
        "He HOLDS the wall sit completely still for the entire animation: back flat "
        "against the wall, both thighs at the same angle, both feet flat side by side "
        "on the mat exactly as in the first frame — the feet NEVER move, slide or "
        "separate, no leg ever reaches further forward than the other. Only his chest "
        "rises and falls as he breathes calmly." + STYLE),
    "rdl-dumbbell_v6": (M / "A_m_stand_db_2db.png",
        "Two slow Romanian deadlift repetitions: from standing fully upright he hinges "
        "at the hips pushing them far back, back FLAT, and BOTH dumbbells — one in "
        "each hand, exactly as drawn in the first frame — slide down along his legs "
        "to mid-shin, then he stands ALL the way back up to fully upright, then "
        "repeats once, ending fully upright. The TWO dumbbells stay clearly visible "
        "and separate the whole time, one per hand, never merging, never disappearing."
        + TEMPO + STYLE),
}

if __name__ == "__main__":
    fails = []
    for slug, (src, prompt) in FIXES.items():
        assert src.exists(), f"source manquante: {src}"
        if not kling(slug, src, prompt):
            fails.append(slug)
        time.sleep(3)
    print(f"FIXES R6 TERMINÉS — fails: {fails}", flush=True)
