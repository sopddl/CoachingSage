import pathlib
import sys
import time

sys.path.insert(0, ".")
from kling_animate import STYLE, kling

# Fixes round 4 Sophie (07-13) — wall-sit pieds parallèles (image feetfix),
# rdl haltère gauche illisible (convention 1 haltère visible), sun-a pivot bras.

M = pathlib.Path("ai-explo/muscu")
B = pathlib.Path("ai-explo/batch")
V4 = pathlib.Path("ai-explo/vague4")

TEMPO = " The movement is SLOW and controlled, tutorial pace, never fast or jerky."

FIXES = {
    "wall-sit_v3": (V4 / "M_wall-sit_feetfix.png",
        "He HOLDS the wall sit completely still for the entire animation: back flat "
        "against the wall, thighs horizontal, knees at 90 degrees, both feet flat on "
        "the mat and parallel, NEVER moving. Only his chest rises and falls as he "
        "breathes calmly. He never stands up, his feet never slide." + STYLE),
    "rdl-dumbbell_v4": (M / "A_m_stand_db.png",
        "Two slow Romanian deadlift repetitions: from standing fully upright he hinges "
        "at the hips pushing them far back, back FLAT, the dumbbell sliding down along "
        "his legs to mid-shin, then stands ALL the way back up to fully upright — then "
        "repeats once, ending fully upright. IMPORTANT: in this side view exactly ONE "
        "dumbbell is visible, held in his near hand; his far arm mirrors the movement "
        "but stays hidden behind his body — no second dumbbell or partial dumbbell "
        "ever appears." + TEMPO + STYLE),
    "sun-salutation-a_v3": (B / "B_tadasana.png",
        "Sun salutation A flow, slow and continuous: her arms rise FORWARD and UP in "
        "front of her body in one smooth vertical arc until overhead — the arms stay "
        "in the side-view plane, they NEVER swing out sideways, never rotate, never "
        "pass behind her back. Then she hinges into a deep standing forward fold, "
        "lifts her chest to a flat-back half lift, and rises back up to standing, "
        "arms lowering in front of her the same way." + TEMPO + STYLE),
}

if __name__ == "__main__":
    fails = []
    for slug, (src, prompt) in FIXES.items():
        assert src.exists(), f"source manquante: {src}"
        if not kling(slug, src, prompt):
            fails.append(slug)
        time.sleep(3)
    print(f"FIXES R4 TERMINÉS — fails: {fails}", flush=True)
