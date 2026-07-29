import pathlib
import sys
import time

sys.path.insert(0, ".")
from kontext_edit import kontext
from kling_animate import kling, STYLE, M

# Re-roll v3 goblet-squat + lunge (07-11) — cause racine des échecs v1/v2 :
# Kling ancre le mouvement sur l'image de départ (position basse) et refuse de
# remonter debout. Fix : démarrer DEBOUT et descendre-remonter.
#   - lunge : départ = A_m_stand_db (debout, haltères aux côtés — existe déjà)
#   - goblet : départ debout créé via kontext depuis l'image validée

STAND_GOBLET = M / "A_m_stand_goblet.png"

if __name__ == "__main__":
    if not STAND_GOBLET.exists():
        kontext(M / "B_goblet-squat_fix2.png", STAND_GOBLET,
            "Small correction: he now stands fully upright with his legs completely "
            "straight and his hips fully extended, still holding the dumbbell "
            "vertically against his chest with both hands.")
    assert STAND_GOBLET.exists()
    time.sleep(2)
    kling("goblet-squat_v3", STAND_GOBLET,
        "Starting from standing, the man slowly bends his knees and hips and squats "
        "all the way DOWN into a deep squat keeping the dumbbell at his chest, then "
        "pushes back up to standing fully upright. Slow full squat repetitions, deep "
        "and complete." + STYLE)
    time.sleep(3)
    kling("lunge-dumbbell_v3", M / "A_m_stand_db.png",
        "Starting from standing with dumbbells at his sides, the man steps forward "
        "with one leg and sinks into a deep lunge bending both knees, then pushes "
        "back up and RETURNS to standing with his feet together. Slow full lunge "
        "repetitions." + STYLE)
    print("REROLLS V3 TERMINÉS", flush=True)
