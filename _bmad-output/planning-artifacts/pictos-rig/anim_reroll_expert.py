import pathlib
import sys
import time

sys.path.insert(0, ".")
from kling_animate import kling, STYLE, M, B

# Re-rolls prescrits par le gate expert animations (07-12, 4 P1) :
#   lunge v3 — haltères qui se balancent + tronc penché + genou arrière raide
#   warrior1 — le genou avant se redresse pendant la tenue (pattern maintien martelé)
#   tree — pied contre le genou (erreur à proscrire) + genou pointé devant
#   cat-cow v2 — phase vache absente (que du chat)

if __name__ == "__main__":
    kling("lunge-dumbbell_v4", M / "A_m_stand_db.png",
        "Starting from standing, the man steps forward into a deep lunge: his BACK "
        "KNEE bends and lowers toward the floor, his front knee bends to 90 degrees, "
        "his TORSO stays perfectly VERTICAL and upright the whole time, and both "
        "dumbbells stay hanging straight DOWN at his sides without swinging. Then he "
        "pushes back up and returns to standing with feet together. Slow controlled "
        "repetitions." + STYLE)
    time.sleep(3)
    kling("warrior1_v2", B / "B_warrior1.png",
        "The woman HOLDS warrior one pose completely still: her front knee stays "
        "deeply bent at 90 degrees the entire time and never straightens, her back "
        "leg stays straight, her arms stay reaching up. Only her chest rises and "
        "falls gently as she breathes calmly. She stays in the exact same position "
        "the whole time." + STYLE)
    time.sleep(3)
    kling("tree_v2", B / "B_tree.png",
        "The woman HOLDS tree pose completely still: her lifted knee stays OPEN out "
        "to the side, her foot stays pressed high against the INNER THIGH of the "
        "standing leg, well above the knee, never against the knee. The standing leg "
        "stays straight. Only her chest rises and falls gently as she breathes "
        "calmly. She stays in the exact same position the whole time." + STYLE)
    time.sleep(3)
    kling("cat-cow_v3", B / "B_cat-cow.png",
        "On all fours, the woman performs ONE complete cat-cow cycle: first she "
        "rounds her spine UP toward the ceiling tucking her head down (cat), then "
        "she clearly REVERSES, dropping her belly down, arching her back the "
        "opposite way and lifting her head and chest up (cow), then returns to "
        "neutral. BOTH phases clearly visible in the video." + STYLE)
    print("REROLLS EXPERT TERMINÉS", flush=True)
