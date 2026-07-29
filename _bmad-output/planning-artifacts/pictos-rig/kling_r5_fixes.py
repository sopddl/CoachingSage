import pathlib
import sys
import time

sys.path.insert(0, ".")
from kling_animate import STYLE, kling

# Fixes round 5 Sophie (07-13 17h) — wall-sit 1 chaussure, rdl haltère lisible
# 2 mains, sun-a bras vers le sol pendant le fold, lunge départ bout du tapis.

M = pathlib.Path("ai-explo/muscu")
B = pathlib.Path("ai-explo/batch")
V4 = pathlib.Path("ai-explo/vague4")

TEMPO = " The movement is SLOW and controlled, tutorial pace, never fast or jerky."

FIXES = {
    "wall-sit_v4": (V4 / "M_wall-sit_feetfix3.png",
        "He HOLDS the wall sit completely still for the entire animation: back flat "
        "against the wall, thighs horizontal, knees at 90 degrees, his feet flat on "
        "the mat and NEVER moving — only ONE shoe stays visible in this profile view, "
        "exactly as in the first frame. Only his chest rises and falls as he breathes "
        "calmly. He never stands up, his feet never slide or separate." + STYLE),
    "rdl-dumbbell_v5": (M / "A_m_stand_db_2hands2.png",
        "Two slow Romanian deadlift repetitions: from standing fully upright he hinges "
        "at the hips pushing them far back, back FLAT, the single dumbbell staying "
        "CLEARLY VISIBLE in front of his legs as it slides down to mid-shin, then he "
        "stands ALL the way back up to fully upright — then repeats once, ending fully "
        "upright. The dumbbell stays firmly in his hands in front of his body the whole "
        "time, always visible, never hidden behind his legs." + TEMPO + STYLE),
    "sun-salutation-a_v4": (B / "B_tadasana.png",
        "Sun salutation A flow, slow and continuous: her arms rise FORWARD and UP in "
        "front of her body until overhead, then as she hinges into the deep standing "
        "forward fold her arms LOWER WITH the torso, hands sliding down toward the "
        "floor in front of her legs — the arms are NEVER held stretched out "
        "horizontally, they always hang or follow the torso naturally. Then she rises "
        "back up to standing, arms coming up in front of her and lowering to her "
        "sides." + TEMPO + STYLE),
    "lunge-dumbbell_v9": (M / "A_m_stand_db_matend.png",
        "One slow forward lunge repetition, torso staying VERTICAL: from standing at "
        "the back end of the mat with a dumbbell in each hand hanging at his sides, he "
        "steps forward along the mat into a deep lunge — front knee above the ankle, "
        "rear knee bending toward the mat, heel lifted — with the dumbbells staying at "
        "his sides. His arms never lift." + TEMPO + STYLE),
}

if __name__ == "__main__":
    fails = []
    for slug, (src, prompt) in FIXES.items():
        assert src.exists(), f"source manquante: {src}"
        if not kling(slug, src, prompt):
            fails.append(slug)
        time.sleep(3)
    print(f"FIXES R5 TERMINÉS — fails: {fails}", flush=True)
