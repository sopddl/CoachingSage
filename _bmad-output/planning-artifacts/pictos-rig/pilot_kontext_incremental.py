import pathlib
import sys
import time

from kontext_edit import kontext

# PILOTE kontext-incrémental (rebond 07-16 soir) — au lieu de générer la pose
# cible en 1 coup (0/24 texte-seul, 1/24 canny-depuis-Canvas), on part d'un
# personnage DÉJÀ VALIDÉ en prod proche de la cible et on le fait glisser en
# 3 petits pas kontext successifs. Seule mécanique qui a marché aujourd'hui
# quand le delta était petit (cf mémoire chantier_animations_etat_2026_07_16).
#
# 2 poses tests : bateau <- staff-pose, guerrier III <- warrior1.
# Chaque étape part de la sortie de l'étape précédente (chaînage).

ROOT = pathlib.Path(__file__).parent
PROD = ROOT.parent.parent.parent / "Resources" / "Illustrations"
OUT = ROOT / "pilot_incremental"
OUT.mkdir(exist_ok=True)

RUNS = {
    "boat": {
        "src": PROD / "staff-pose.png",
        "steps": [
            "Keep her seated on the mat exactly as she is, sit bones "
            "staying on the floor. Only change: bend her knees and lift "
            "her feet a little off the floor, leaning her torso back "
            "slightly for balance, hands still lightly touching the floor "
            "beside her hips for support. Do not make her stand up.",
            "Raise her legs higher forming roughly a 90 degree angle at the "
            "hips, straightening the legs more, torso leaning back further, "
            "arms starting to lift off the floor and reaching forward.",
            "Full boat pose: balancing only on her sit bones, both legs "
            "fully straight and raised forming a V-shape with her torso, "
            "arms fully extended straight forward parallel to the floor, "
            "back straight, chest open.",
        ],
    },
    "warrior3": {
        "src": PROD / "warrior1.png",
        "steps": [
            "Begin shifting her weight forward onto the bent front leg, "
            "torso starting to tilt forward from the hips, back leg "
            "starting to lift slightly off the floor behind her, arms "
            "lowering from overhead to reach forward.",
            "Continue tilting the torso toward horizontal, back leg "
            "lifting further off the floor and extending straight behind "
            "her, front standing leg straightening, arms extending fully "
            "forward.",
            "Full warrior III pose: standing balanced on one straight leg, "
            "torso and extended back leg forming one straight horizontal "
            "line parallel to the floor, arms extended straight forward "
            "alongside the head, back leg fully straight and lifted behind "
            "at hip height.",
        ],
    },
}


def run(name, spec):
    src = spec["src"]
    assert src.exists(), f"source manquante: {src}"
    cur = src
    for i, prompt in enumerate(spec["steps"], start=1):
        dest = OUT / f"{name}_step{i}.png"
        if dest.exists():
            print(f"SKIP (déjà fait) — {dest}")
            cur = dest
            continue
        ok = kontext(str(cur), str(dest), prompt)
        if not ok:
            print(f"ARRÊT {name} à l'étape {i} (échec kontext)")
            return
        cur = dest
        time.sleep(2)
    print(f"{name}: {len(spec['steps'])} étapes OK, final = {cur}")


if __name__ == "__main__":
    targets = sys.argv[1:] or list(RUNS)
    for t in targets:
        run(t, RUNS[t])
