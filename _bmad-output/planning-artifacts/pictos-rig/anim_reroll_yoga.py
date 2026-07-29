import sys
import time

sys.path.insert(0, ".")
from kling_animate import kling, STYLE, B

# Re-rolls yoga (gate 1 du 07-11) : chair s'effondre à genoux, staff-pose part
# regarder le plafond. Contrainte de maintien martelée.

if __name__ == "__main__":
    kling("chair_v2", B / "B_chair.png",
        "The woman HOLDS chair pose without moving her legs: both feet stay flat on "
        "the mat, knees stay bent, she NEVER kneels and NEVER touches the floor with "
        "her knees or hands. Only her chest rises and falls gently as she breathes "
        "calmly. She stays in the exact same position the whole time." + STYLE)
    time.sleep(3)
    kling("staff-pose_v2", B / "B_staff-pose.png",
        "The woman HOLDS staff pose completely still: sitting upright, legs straight, "
        "her head stays NEUTRAL with her gaze fixed FORWARD at eye level, she never "
        "looks up. Only her chest rises and falls gently as she breathes calmly." + STYLE)
    print("REROLLS YOGA TERMINÉS", flush=True)
