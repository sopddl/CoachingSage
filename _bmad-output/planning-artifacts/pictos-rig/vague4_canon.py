import pathlib
import sys

sys.path.insert(0, ".")
from pilot_flux import replicate_run, b64

# CANONISATION personnage (07-12) — Sophie : « les profils doivent être identiques
# d'une image à l'autre ». Cause : images issues de pipelines différents (FLUX ath
# regonflé vs re-gen rig) → 2 corpulences + cheveux/chaussures qui dérivent.
# Fix : re-gen TOUT le set masculin depuis les rigs avec UN personnage verrouillé
# (= gabarit canon élancé A_m_stand) + SEED de personnage FIXE pour la cohérence.

V4 = pathlib.Path("ai-explo/vague4")
SEED = 700  # seed personnage fixe pour tous

# Personnage canonique verrouillé (aligné sur A_m_stand)
CHAR = ("the SAME young man with an ordinary slim-average build, normal proportions "
        "and smooth flat limbs with NO muscle definition (not muscular, not skinny), "
        "short dark brown hair neatly swept back, light neutral skin, plain minimalist "
        "flat profile face with a small simple nose, wearing a fitted white t-shirt "
        "with short sleeves, navy blue full-length pants and plain navy blue sneakers "
        "with thin white soles, minimalist flat vector design, clean simple shapes, "
        "soft muted colors, NO thick black outlines, plain light mauve-gray background, "
        "thin dark navy exercise mat, full body fully visible inside the frame, side view")

def M(pose):
    return f"flat vector illustration of {CHAR.split('the SAME')[0]}a man doing a strength exercise, {pose}, {CHAR}"

POSES = {
 "plank": (V4/"plank_control.png", "high plank, both palms flat on the mat under his shoulders, arms straight vertical, body in one straight line from head to heels, toes tucked"),
 "pushup": (V4/"pushup_control.png", "bottom of a push-up, elbows bent pointing back, chest hovering just above the mat, hands flat on the mat, body in one straight low line, toes tucked"),
 "wall-sit": (V4/"wall-sit_control.png", "wall sit, back and shoulders pressed flat against a vertical wall, knees bent 90 degrees, thighs horizontal, feet flat on the floor, arms at his sides"),
 "box-jump": (V4/"box-jump_control.png", "box jump landing, standing on top of a sturdy box with both feet flat, knees and hips bent in a stable landing squat, arms extended forward for balance"),
 "facepull": (V4/"facepull_control.png", "cable face pull, standing facing a tall cable column, elbows high and wide, hands pulling a cable attachment toward his face, a thin cable from his hands to the top of the column"),
 "bench-press": (V4/"bench-press_control.png", "barbell bench press, lying on his back on a flat bench, feet flat on the floor, both arms extended straight up holding a barbell with round plates above his chest"),
 "cable-row": (V4/"cable-row_control.png", "seated cable row, sitting upright on a low bench with legs extended forward knees slightly bent, hands pulling a cable handle to his torso, a thin cable to a low pulley column in front"),
 "rdl-dumbbell": (V4/"rdl-dumbbell_control.png", "Romanian deadlift with a dumbbell, hips hinged back, back perfectly FLAT, knees slightly bent, arm hanging straight down holding one dumbbell in front of the shins, both feet flat side by side parallel"),
 "kb-swing": (V4/"kb-swing_control.png", "kettlebell swing, hips hinged back, back flat, knees slightly bent, both hands together gripping the handle of ONE kettlebell, both arms straight extended forward at chest height, both feet flat parallel"),
 "hanging-leg-raise": (V4/"hanging-leg-raise_control.png", "hanging leg raise, hanging from a high horizontal bar with both arms straight overhead gripping the bar, both legs together raised straight forward horizontal at hip height, feet off the floor"),
 "leg-extension": (V4/"leg-extension_control_fix.png", "seated leg extension machine, sitting upright, hands holding the side handles, one leg extended straight forward HORIZONTAL with the shin in line with the thigh and the foot at knee height against a padded roller"),
 "dead-bug": (V4/"dead-bug_control_fix.png", "dead bug core exercise, lying flat on his back on the mat, one knee bent up in tabletop with thigh vertical and shin horizontal, the other leg extended straight out and LOW just above the mat, one arm reaching straight up with a simple rounded mitten hand and no fingers, the other arm resting on the mat, head on the mat"),
}

if __name__ == "__main__":
    for slug, (ctrl, pose) in POSES.items():
        assert ctrl.exists(), f"contrôle manquant {ctrl}"
        replicate_run("black-forest-labs/flux-canny-pro",
            {"prompt": M(pose), "control_image": b64(ctrl), "guidance": 30,
             "steps": 50, "seed": SEED, "output_format": "png", "safety_tolerance": 2},
            V4 / f"M_{slug}_canon.png")
        print(f"OK — M_{slug}_canon.png", flush=True)
    print("CANON TERMINÉ", flush=True)
