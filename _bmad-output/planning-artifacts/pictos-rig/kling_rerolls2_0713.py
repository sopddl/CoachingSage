import pathlib
import sys
import time

sys.path.insert(0, ".")
from kling_animate import STYLE, kling

# Rerolls vague 2 (07-13) — KO gate 1 yoga : triangle (sort de la pose),
# plank-f (genoux au sol). Skip si mp4 existe.

B = pathlib.Path("ai-explo/batch")

REROLLS2 = {
    "marichyasana-a_v2": (B / "B_marichyasana-a.png",
        "She holds the seated pose completely still, breathing calmly. Her FACE stays "
        "EXACTLY as in the first frame for the entire animation: plain neutral lips in "
        "skin tone, NO lipstick, NO makeup appearing, the same minimalist flat face "
        "throughout." + STYLE),
    "plank-f_v2": (B / "B_plank.png",
        "She HOLDS a high plank on her hands and TOES for the entire animation: legs "
        "straight, knees OFF the mat at all times, body in one rigid straight line from "
        "head to heels, breathing calmly — only her chest rises. Her knees NEVER touch "
        "the mat, she NEVER lowers into a kneeling position." + STYLE),
}

if __name__ == "__main__":
    fails = []
    for slug, (src, prompt) in REROLLS2.items():
        assert src.exists(), f"source manquante: {src}"
        if not kling(slug, src, prompt):
            fails.append(slug)
        time.sleep(3)
    print(f"REROLLS2 TERMINÉS — fails: {fails}", flush=True)
