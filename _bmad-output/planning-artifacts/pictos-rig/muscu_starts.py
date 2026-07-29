import pathlib
import shutil
import sys
import time

sys.path.insert(0, ".")
from kontext_edit import kontext

# VAGUE MUSCU — phase A : images de départ, personnage homme CANONIQUE.
# Canon = la paire squat gobelet validée par Sophie (planche v2) : homme cheveux
# bruns courts, t-shirt blanc, pantalon bleu marine, baskets, fond mauve-gris,
# tapis bleu marine. Toutes les A dérivent de cette image par kontext →
# personnage/décor cohérents par construction sur tout le catalogue muscu.

PLANCHE = pathlib.Path("ai-explo/planche")
OUT = pathlib.Path("ai-explo/muscu")
OUT.mkdir(exist_ok=True)

CANON = PLANCHE / "start_goblet_kontext2.png"  # homme t-shirt blanc + haltère vertical poitrine

# (dest, source, prompt) — dérivations kontext depuis le canon (ou une autre A déjà faite)
STARTS = [
    ("A_m_stand_db.png", CANON,
     "He now holds one dumbbell in each hand, both arms hanging straight down relaxed "
     "at his sides, standing fully upright in profile, feet together flat on the mat."),
    ("A_m_stand.png", "A_m_stand_db.png",
     "Remove the dumbbells: both hands empty, arms hanging straight down relaxed at his "
     "sides, standing fully upright in profile, feet flat on the mat."),
    ("A_m_stand_bb.png", "A_m_stand.png",
     "He now holds a barbell with round weight plates at both ends, gripping it with both "
     "hands, arms hanging straight down so the bar rests in front of his thighs, standing "
     "fully upright in profile."),
    ("A_m_plank.png", "A_m_stand.png",
     "He is now in a high plank position on the mat: both palms flat on the mat directly "
     "under his shoulders, arms straight, body in one straight horizontal line from head "
     "to heels, toes tucked on the mat, side view."),
    ("A_m_supine.png", "A_m_stand.png",
     "In this fitness exercise illustration, the figure now lies flat on his back on the "
     "mat, legs extended straight, arms resting along his sides, face up, side view."),
    ("A_m_tabletop.png", "A_m_stand.png",
     "He is now on all fours on the mat: hands flat under his shoulders, arms straight, "
     "knees on the mat under his hips, back flat horizontal, side view."),
]


if __name__ == "__main__":
    for dest, src, prompt in STARTS:
        dest_p = OUT / dest
        if dest_p.exists():
            continue
        src_p = src if isinstance(src, pathlib.Path) else OUT / src
        ok = kontext(str(src_p), str(dest_p), prompt)
        if not ok:
            print(f"ÉCHEC {dest}", flush=True)
        time.sleep(2)
    # le canon lui-même sert d'A pour goblet/curl (haltère déjà en main poitrine)
    if not (OUT / "A_m_goblet.png").exists():
        shutil.copy(CANON, OUT / "A_m_goblet.png")
    print("STARTS TERMINÉS", flush=True)
