import pathlib
import sys
import time

sys.path.insert(0, ".")
from kontext_edit import kontext
from pilot_flux import replicate_run, b64

# VAGUE MUSCU — retries gate 1 (round 2, dernier pour la plupart).
# Corrections ciblées d'après la revue anti-bug pleine taille.

OUT = pathlib.Path("ai-explo/muscu")
A = {
    "stand": OUT / "A_m_stand.png",
    "stand_db": OUT / "A_m_stand_db.png",
    "stand_bb": OUT / "A_m_stand_bb_v2.png",
    "plank": OUT / "A_m_plank.png",
    "tabletop": OUT / "A_m_tabletop.png",
}

RETRIES = {
    "squat-bodyweight": ("stand",
        "Change his pose: he squats down on both legs together, BOTH knees bent deep side "
        "by side, NO knee touching the floor, both feet flat on the mat side by side, "
        "thighs parallel to the floor, hips pushed back, both arms extended straight "
        "FORWARD horizontally in front of him, back straight, staying in side view."),
    "calf-raise": ("stand",
        "Change his pose: standing perfectly upright with BOTH feet together side by side, "
        "he lifts BOTH heels off the mat at the same time, balancing on the balls of both "
        "feet, legs straight and vertical, arms relaxed at his sides, staying in side view."),
    "triceps-overhead": ("stand_db",
        "Change his pose, STAYING in strict side view profile facing left: he holds one "
        "single dumbbell with both hands behind his head, elbows bent pointing straight "
        "up toward the ceiling, upper arms vertical beside his ears, standing upright. "
        "The second dumbbell is gone."),
    "kb-swing": ("stand_db",
        "Replace the dumbbells with one single kettlebell held with both hands, staying "
        "in side view. Change his pose: hips hinged BACK, torso leaning forward, back "
        "flat, knees slightly bent, both feet flat side by side, both arms straight and "
        "extended, the kettlebell swung forward AWAY from his body at shoulder height."),
    "deadlift-conventional": ("stand_bb",
        "Change his pose: the barbell now LIES ON THE MAT, its round weight plates "
        "resting on the mat surface so the bar sits at shin height. He crouches down "
        "over the bar: knees deeply bent, hips low and pushed back, back flat, chest up, "
        "both arms straight and vertical gripping the bar, both feet flat side by side."),
    "bentover-row-barbell": ("stand_bb",
        "Change his pose: torso hinged forward, back flat, knees slightly bent, both "
        "feet flat side by side, ELBOWS BENT pointing up behind his back, pulling the "
        "barbell up so the bar touches his stomach."),
    "pushup": ("plank",
        "Change his pose: keeping the same straight body line and toes tucked on the "
        "mat, he BENDS both elbows to 90 degrees pointing backward along his body, "
        "lowering his chest and hips close to the mat, hovering just above it."),
    "side-plank": ("plank",
        "Change his pose into a side plank: his whole body rotates to face the viewer, "
        "resting on ONE straight arm with the hand flat on the mat directly under the "
        "shoulder, both feet STACKED one on top of the other, body in one straight "
        "diagonal line from head to feet, the free arm pointing straight up."),
    "bird-dog": ("tabletop",
        "Change his pose: still kneeling on all fours, he RAISES one arm extended "
        "straight forward parallel to the mat, AND the opposite leg extended straight "
        "back parallel to the mat, while the other hand and the other knee stay on the "
        "mat, back flat, staying in side view."),
    "wall-sit": ("stand",
        "Add a flat vertical wall directly behind him. Change his pose: his back and "
        "shoulders PRESSED FLAT against the wall, sliding down it so his knees are bent "
        "at 90 degrees, thighs horizontal, feet flat on the floor in front, arms "
        "hanging at his sides, like sitting on an invisible chair against the wall."),
    "pullup": ("stand",
        "Add a high horizontal pull-up bar. Change his pose: he pulls himself UP on the "
        "bar, both hands gripping it, ELBOWS FULLY BENT, chin just above the bar level, "
        "his whole body lifted high off the ground, knees bent with feet crossed "
        "behind him, far above the mat."),
    "hanging-leg-raise": ("stand",
        "Add a high horizontal pull-up bar. Change his pose: he hangs from the bar with "
        "both arms straight and his body lifted well off the ground, and raises BOTH "
        "legs together straight out in FRONT of him, horizontal at hip height, feet "
        "together, far above the mat."),
    "pallof-press": ("stand",
        "Add a tall vertical cable column on the far right edge of the image. Change "
        "his pose: he stands upright well away from the column, two big steps to the "
        "left of it, holding a small handle with both hands, both arms pressed straight "
        "out horizontally in front of his chest, a thin taut cable running horizontally "
        "from the handle to the column."),
    "triceps-pushdown": ("stand",
        "Add a tall vertical cable column on the right edge of the image. Change his "
        "pose: he faces the column standing upright, BOTH hands side by side gripping "
        "one short horizontal bar in front of him, elbows bent and pinned at his sides, "
        "forearms pushing the bar DOWN to hip height, a thin cable running from the "
        "middle of the bar up to the top of the column."),
    "nordic-curl": ("stand",
        "Change his pose: he kneels on the mat, shins flat on the mat, with his ankles "
        "held down under a low padded bar behind him, and his body leans FORWARD from "
        "the knees at about 30 degrees in ONE perfectly straight line from knees to "
        "hips to shoulders to head, arms crossed over his chest, staying in side view."),
    "dips": ("stand",
        "Change the scene: he is now supported UP BETWEEN two parallel dip bars at hip "
        "height, one hand gripping each bar, both arms straight and locked, his whole "
        "body held above the bars, both feet OFF the floor with knees bent and feet "
        "crossed behind him, staying in side view."),
    "lat-pulldown": ("stand",
        "Change the scene: he sits upright at a lat pulldown machine, knees held under "
        "a pad, and PULLS the wide bar DOWN to his upper chest, elbows bent pointing "
        "down, the cable running from the middle of the bar up to the top pulley of "
        "the machine frame."),
    "back-squat": ("stand_bb",
        "Change his pose, STAYING in strict side view profile facing left: the barbell "
        "rests across his upper back and shoulders behind his neck, both hands gripping "
        "it, and he squats DEEP, knees fully bent, thighs parallel to the floor, hips "
        "pushed back, both feet flat, torso leaning slightly forward with a straight back."),
    "ohp-barbell": ("stand_bb",
        "Change his pose, STAYING in strict side view profile facing left: he presses "
        "the barbell straight overhead, both arms fully extended vertically, the bar "
        "directly above his head, standing upright, both feet flat side by side."),
    "rdl-barbell": ("stand_bb",
        "Change his pose, staying in side view: he hinges forward at the hips, back "
        "flat, knees slightly bent, BOTH feet flat side by side (not staggered), hips "
        "pushed back, both arms hanging straight down holding the barbell CLOSE to his "
        "legs at mid-shin height, the plates NOT touching the mat."),
}

# forearm-plank homme : FLUX-canny-pro direct (recette pilote validée), prompt homme
FP_MALE = ("flat vector illustration of a man doing a forearm plank exercise, his ELBOWS "
           "and FOREARMS pressed flat INTO the dark navy mat on the floor, weight resting "
           "on the forearms which TOUCH the mat, body in one straight horizontal line just "
           "above the floor, toes tucked on the mat, side view, short dark hair, wearing a "
           "fitted white t-shirt, navy blue pants and sneakers, minimalist flat design, "
           "clean simple shapes, plain light mauve-gray background, full body visible")


if __name__ == "__main__":
    for slug, (a_key, prompt) in RETRIES.items():
        dest = OUT / f"B_{slug}_v2.png"
        if dest.exists():
            continue
        kontext(str(A[a_key]), str(dest), prompt)
        time.sleep(2)
    fp = OUT / "B_forearm-plank_v2.png"
    if not fp.exists():
        replicate_run("black-forest-labs/flux-canny-pro",
            {"prompt": FP_MALE,
             "control_image": b64(pathlib.Path("ai-explo/vague3/forearm-plank_control.png")),
             "guidance": 30, "steps": 50, "seed": 2025, "output_format": "png",
             "safety_tolerance": 2}, fp)
    print("RETRIES TERMINÉS", flush=True)
