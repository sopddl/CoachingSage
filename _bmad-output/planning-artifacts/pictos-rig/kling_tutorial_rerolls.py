import pathlib
import sys
import time

sys.path.insert(0, ".")
from kling_animate import STYLE, kling

# Rerolls vague tutoriel (07-13) — sun-b_v2 sans chaise (genoux jamais pliés),
# biceps _v4 = collision avec l'ancien KO (kling skip) → v5.

B = pathlib.Path("ai-explo/batch")
M = pathlib.Path("ai-explo/muscu")

TEMPO = " The movement is SLOW and controlled, tutorial pace, never fast or jerky."

REROLLS = {
    "sun-salutation-b_v3": (B / "B_tadasana.png",
        "Sun salutation B opening: she BENDS HER KNEES DEEPLY sinking her hips back and "
        "down into chair pose (utkatasana), thighs clearly angled, knees clearly bent, "
        "while her arms sweep up overhead — she holds the chair pose a moment — then she "
        "straightens her legs and folds forward into a standing forward fold, then rises "
        "back up to standing. Her knees MUST visibly bend during the chair pose."
        + TEMPO + STYLE),
    "biceps-curl_v5": (M / "B_biceps-curl_fix2.png",
        "Strict biceps curl repetitions with his visible arm: his ELBOW STAYS PINNED to "
        "his side at all times, only the forearm rotates — the dumbbell rises exactly to "
        "shoulder height, NEVER above the shoulder, NEVER overhead, then lowers fully "
        "until the arm hangs straight down. Two even repetitions ending with the arm "
        "extended down." + TEMPO + STYLE),
}

if __name__ == "__main__":
    fails = []
    for slug, (src, prompt) in REROLLS.items():
        assert src.exists(), f"source manquante: {src}"
        if not kling(slug, src, prompt):
            fails.append(slug)
        time.sleep(3)
    print(f"REROLLS TUTORIEL TERMINÉS — fails: {fails}", flush=True)
