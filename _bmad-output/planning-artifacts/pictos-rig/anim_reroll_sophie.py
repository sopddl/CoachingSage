import pathlib
import sys
import time

sys.path.insert(0, ".")
from kontext_edit import kontext
from kling_animate import kling, STYLE, M, B

# Re-rolls retours Sophie 07-12 (galerie annotée) :
#   biceps-curl_v2 KO — bras gauche plie à l'envers → v3 coude naturel martelé
#   cat-cow KO — dos rond pas assez visible → v2 amplitude exagérée
#   chair_v2 KO — pas assez assise → v3 descente plus profonde (bras levés = doctrine ok)
#   goblet v4 bonus — départ corrigé : les DEUX mains tiennent l'haltère

STAND_GOBLET2 = M / "A_m_stand_goblet2.png"

if __name__ == "__main__":
    kling("biceps-curl_v3", M / "B_biceps-curl_fix2.png",
        "The man performs slow alternating biceps curls. Each arm bends ONLY at the "
        "elbow in the natural human direction: the elbow stays pointing down at his "
        "side and the hand holding the dumbbell rises up in FRONT of him toward his "
        "shoulder, then lowers back down. The elbow never bends backwards. One arm "
        "curls up while the other lowers, alternating." + STYLE)
    time.sleep(3)
    kling("cat-cow_v2", B / "B_cat-cow.png",
        "On all fours, the woman slowly rounds her spine UP toward the ceiling into "
        "a clearly visible HIGH round arch like a stretching cat, tucking her head "
        "and tailbone down, then slowly reverses, dipping her belly down and lifting "
        "her head. LARGE exaggerated spine movement, very visible rounding." + STYLE)
    time.sleep(3)
    kling("chair_v3", B / "B_chair.png",
        "The woman sinks clearly DEEPER into chair pose: her knees bend much more "
        "and her hips drop LOW as if sitting down into an invisible chair, thighs "
        "approaching horizontal, both feet staying flat on the mat, arms staying "
        "raised. She NEVER kneels and NEVER touches the floor with her hands or "
        "knees. She holds the deep seated position breathing calmly." + STYLE)
    time.sleep(3)
    if not STAND_GOBLET2.exists():
        kontext(M / "A_m_stand_goblet.png", STAND_GOBLET2,
            "Small correction: BOTH of his hands grip the vertical dumbbell together "
            "against his chest, both palms clearly touching and holding it.")
    kling("goblet-squat_v4", STAND_GOBLET2,
        "Starting from standing, the man slowly bends his knees and hips and squats "
        "all the way DOWN into a deep squat keeping the dumbbell held at his chest "
        "with BOTH hands, then pushes back up to standing fully upright. Slow full "
        "squat repetitions, deep and complete, both hands always on the dumbbell." + STYLE)
    print("REROLLS SOPHIE TERMINÉS", flush=True)
