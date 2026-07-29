import pathlib
import sys
import time

sys.path.insert(0, ".")
from kling_animate import STYLE, kling
from kontext_edit import kontext

# VAGUE TUTORIEL (arbitrage Sophie 07-13 : « on vise le tutoriel ») — cycles complets,
# retour propre en fin de boucle, tempo contrôlé (cible score vitesse 3-8).

B = pathlib.Path("ai-explo/batch")
M = pathlib.Path("ai-explo/muscu")
V4 = pathlib.Path("ai-explo/vague4")

TEMPO = " The movement is SLOW and controlled, tutorial pace, never fast or jerky."

WAVE = {
    "sun-salutation-a_v2": (B / "B_tadasana.png",
        "Sun salutation A flow, slow and continuous: from standing she sweeps her arms up "
        "overhead, then hinges into a deep standing forward fold, then lifts her chest to "
        "a flat-back half lift, then folds again and rises back up to standing with arms "
        "lowering. One smooth continuous flow." + TEMPO + STYLE),
    "sun-salutation-b_v2": (B / "B_tadasana.png",
        "Sun salutation B opening, slow and continuous: from standing she bends her knees "
        "into chair pose with arms sweeping up overhead, then folds forward into a deep "
        "standing forward fold, then rises back through chair pose to standing. One "
        "smooth continuous flow." + TEMPO + STYLE),
    "biceps-curl_v4": (M / "B_biceps-curl_fix2.png",
        "Even biceps curl repetitions: starting with arms extended down, he curls the "
        "dumbbells up to his shoulders, lowers them fully back down, and curls up again — "
        "the elbow angle changes EVENLY through the whole clip, ending with arms extended "
        "down as at the start." + TEMPO + STYLE),
    "rdl-dumbbell_v3": (M / "A_m_stand_db.png",
        "Two slow Romanian deadlift repetitions: from standing fully upright he hinges at "
        "the hips pushing them far back, back FLAT, the dumbbells sliding down to "
        "mid-shin, then stands ALL the way back up to fully upright with hips locked — "
        "then repeats once, ending fully upright as at the start." + TEMPO + STYLE),
    "back-squat_v2": (M / "B_back-squat_v2.png",
        "Two slow full back squat repetitions with the barbell staying racked on his "
        "shoulders behind his neck: he stands up completely straight, squats all the way "
        "back down, stands again, and ENDS in the exact same deep squat as the first "
        "frame so the loop closes seamlessly." + TEMPO + STYLE),
    "goblet-squat_v5": (M / "A_m_stand_goblet2.png",
        "One single slow goblet squat repetition: from standing he squats all the way "
        "down keeping the dumbbell vertical at his chest, pauses visibly at the bottom, "
        "then stands back up to exactly the starting upright position." + TEMPO + STYLE),
    "lunge-dumbbell_v8": (M / "A_m_stand_db.png",
        "One slow forward lunge repetition, torso staying VERTICAL: from standing with a "
        "dumbbell in EACH hand hanging at his sides, he steps forward into a deep lunge "
        "with both dumbbells staying at his sides, then pushes back to standing with "
        "feet together, ending exactly as he started. His arms never lift." + TEMPO + STYLE),
    "hands-under-feet_v2": (B / "B_hands-under-feet.png",
        "She holds the deep forward fold and slides her hands fully UNDER the soles of "
        "her feet, palms up, toes resting on her wrists, then holds the pose breathing "
        "calmly. Her hands stay under her feet, never on the floor in front." + TEMPO + STYLE),
}

if __name__ == "__main__":
    # image de depart box-jump au sol (kontext) puis animation du saut complet
    floor = V4 / "M_box-jump_floor.png"
    if not floor.exists():
        kontext(str(V4 / "M_box-jump_ath.png"), str(floor),
                "He now stands upright on the FLOOR facing the box, about one step away "
                "from it, arms relaxed at his sides, knees straight, ready to jump. The "
                "box stays exactly where it is, seen from the same side view.")
    fails = []
    for slug, (src, prompt) in WAVE.items():
        assert src.exists(), f"source manquante: {src}"
        if not kling(slug, src, prompt):
            fails.append(slug)
        time.sleep(3)
    if floor.exists():
        ok = kling("box-jump_v4", floor,
            "One complete box jump: from standing on the floor facing the box he bends "
            "his knees swinging his arms back, JUMPS with both feet onto the top of the "
            "box, lands with knees bent absorbing the impact, and stands up tall on the "
            "box. He ends standing on the box." + TEMPO + STYLE)
        if not ok:
            fails.append("box-jump_v4")
    print(f"VAGUE TUTORIEL TERMINÉE — fails: {fails}", flush=True)
