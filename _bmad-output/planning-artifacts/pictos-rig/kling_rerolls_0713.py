import pathlib
import sys
import time

sys.path.insert(0, ".")
from kling_animate import STYLE, kling

# Rerolls 07-13 — consignes issues du gate 1 + gate expert (anim_verdicts.json).
# Fichiers _v2, originaux gardés pour comparaison. Skip si mp4 existe.

M = pathlib.Path("ai-explo/muscu")
V4 = pathlib.Path("ai-explo/vague4")

REROLLS = {
    "triceps-overhead_v2": (M / "B_triceps-overhead_v2.png",
        "Only his FOREARMS move: holding ONE single dumbbell with both hands behind his "
        "head, he extends his forearms straight up overhead, then bends his elbows "
        "lowering the dumbbell back behind his head. His elbows stay FIXED pointing up, "
        "his body and upper arms never move. There is only ONE dumbbell in the whole "
        "animation." + STYLE),
    "box-jump_v2": (V4 / "M_box-jump_ath.png",
        "He stays ON TOP of the box for the entire animation, seen from the SAME side "
        "profile view: he absorbs the landing by bending his knees a little deeper, then "
        "slowly stands up tall and stable on the box. He NEVER steps off the box, NEVER "
        "turns toward the camera, the viewpoint never changes." + STYLE),
    "rdl-dumbbell_v2": (V4 / "M_rdl-dumbbell_pilote2.png",
        "The dumbbell STAYS FIRMLY IN HIS HANDS at all times, never floating or detached. "
        "He stands up FULLY upright, the dumbbell sliding up along his legs, his back "
        "staying FLAT, then hinges back down pushing his hips far back. Two slow full "
        "Romanian deadlift repetitions." + STYLE),
    "bulgarian-split-squat_v2": (M / "B_bulgarian-split-squat_v2.png",
        "His rear foot stays in PERMANENT CONTACT with the bench during the whole "
        "movement — it NEVER lifts off the bench. Only his knees bend and extend: he "
        "rises by straightening his front leg, then lowers slowly back into the deep "
        "split squat. Slow controlled repetitions." + STYLE),
    "facepull_v2": (V4 / "M_facepull_ath.png",
        "Clear back-and-forth face pull repetitions: his elbows flare OUT and BACK as his "
        "hands pull the rope attachment toward his face and ears, elbows high behind the "
        "plane of his torso, then his arms extend back toward the pulley. His torso stays "
        "upright and completely stable, never leaning. Two full repetitions." + STYLE),
}

if __name__ == "__main__":
    fails = []
    for slug, (src, prompt) in REROLLS.items():
        assert src.exists(), f"source manquante: {src}"
        if not kling(slug, src, prompt):
            fails.append(slug)
        time.sleep(3)
    print(f"REROLLS TERMINÉS — fails: {fails}", flush=True)
