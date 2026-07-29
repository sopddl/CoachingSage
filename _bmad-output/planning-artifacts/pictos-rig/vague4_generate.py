import pathlib
import sys
import time

sys.path.insert(0, ".")
from pilot_flux import replicate_run, b64, FEMALE

# VAGUE 4 — génération FLUX-canny-pro depuis les contrôles rig (recette pilote).
# Muscu = homme canonique ; yoga = femme catalogue. 1 seed, retry ciblé ensuite.

V3 = pathlib.Path("ai-explo/vague3")
V4 = pathlib.Path("ai-explo/vague4")
PLANCHE = pathlib.Path("ai-explo/planche")
OUT = pathlib.Path("ai-explo/vague4")

MALE = ("flat vector illustration of a man doing a strength exercise, {pose}, "
        "short dark hair, wearing a fitted white t-shirt, navy blue pants and sneakers, "
        "minimalist flat design, clean simple shapes, soft muted colors, plain light "
        "mauve-gray background, on a thin dark navy exercise mat, full body visible, side view")

# slug -> (control path, prompt {pose})
MUSCU = {
 "plank": (V4 / "plank_control.png",
    "high plank, both palms flat on the mat directly under his shoulders, arms straight "
    "and vertical, body in one straight line from head to heels, toes tucked"),
 "pushup": (V4 / "pushup_control.png",
    "bottom of a push-up, elbows bent pointing back and up, chest hovering just above "
    "the mat, hands flat on the mat, body in one straight low line, toes tucked"),
 "glute-bridge": (V4 / "glute-bridge_control.png",
    "glute bridge, lying on his back with head and shoulders resting on the mat, hips "
    "lifted high, knees bent, both feet flat on the mat, arms resting along his sides"),
 "dead-bug": (V4 / "dead-bug_control.png",
    "dead bug exercise, lying flat on his back on the mat, one arm extended straight up "
    "toward the ceiling, one knee bent above the hip, the other leg extended straight "
    "and low, head resting on the mat"),
 "rdl-dumbbell": (V4 / "rdl-dumbbell_control.png",
    "Romanian deadlift with a dumbbell, hips hinged back, back perfectly FLAT and "
    "straight, head in line with the spine, knees slightly bent, arm hanging straight "
    "down holding a dumbbell in front of the shins, both feet flat side by side"),
 "rdl-barbell": (PLANCHE / "deadlift_control.png",
    "Romanian deadlift with a barbell, hips hinged back, back perfectly FLAT, head in "
    "line with the spine, knees slightly bent, both arms straight holding the barbell "
    "at mid-shin height close to his legs, round weight plates on the bar, plates not "
    "touching the mat, both feet flat side by side"),
 "bentover-row": (V4 / "bentover-row_control.png",
    "bent-over barbell row, torso hinged forward with a FLAT back, knees slightly bent, "
    "elbow bent pulled up behind his back, hand gripping a barbell pulled up against "
    "his stomach, round weight plate on the bar end"),
 "kb-swing": (V4 / "kb-swing_control.png",
    "kettlebell swing, hips hinged back, back flat, knees slightly bent, both arms "
    "straight extended forward and up swinging one kettlebell at chest height, both "
    "feet flat on the mat"),
 "calf-raise": (V4 / "calf-raise_control.png",
    "standing calf raise, standing tall perfectly upright, BOTH heels lifted high off "
    "the mat, balancing on the balls of the feet, legs straight, arms relaxed at his sides"),
 "wall-sit": (V4 / "wall-sit_control.png",
    "wall sit, his back and shoulders pressed flat against a vertical wall, knees bent "
    "at 90 degrees, thighs horizontal, feet flat on the floor, arms at his sides"),
 "box-jump": (V4 / "box-jump_control.png",
    "box jump landing, standing on top of a sturdy plyometric box with BOTH feet flat "
    "at the center of the box, knees and hips bent in a stable landing squat, arms "
    "extended forward for balance"),
 "nordic-curl": (V4 / "nordic-curl_control.png",
    "Nordic hamstring curl, kneeling with shins flat on the mat and ankles anchored "
    "under a padded bar behind him, body leaning forward from the knees in one straight "
    "line from knees to head, arms crossed over his chest"),
 "pullup": (V4 / "pullup_control.png",
    "pull-up on a pull-up bar frame, both hands gripping the horizontal bar overhead, "
    "elbows bent pulling his body up, chin near the bar, knees bent with feet lifted "
    "behind him, body well above the floor"),
 "hanging-leg-raise": (V4 / "hanging-leg-raise_control.png",
    "hanging leg raise, hanging from a high horizontal bar with both arms straight, "
    "both legs together raised straight forward horizontal at hip height, feet off the "
    "floor"),
 "dips": (V4 / "dips_control.png",
    "triceps dips on parallel bars, both hands gripping the bars at hip height, arms "
    "straight and locked supporting his whole body, knees bent with feet lifted behind "
    "him, feet off the floor"),
 "pallof-press": (V4 / "pallof-press_control.png",
    "Pallof press at a cable machine, standing upright away from a tall cable column, "
    "both arms extended straight forward at chest height holding a small handle, a thin "
    "taut cable running horizontally from the handle to the column"),
 "triceps-pushdown": (V4 / "triceps-pushdown_control.png",
    "cable triceps pushdown, standing facing a tall cable column, elbows bent and "
    "pinned at his sides, both hands gripping a short bar pushed down toward his "
    "thighs, a thin cable running from the bar up to the top of the column"),
 "facepull": (V4 / "facepull_control.png",
    "cable face pull, standing facing a tall cable column, elbows high and wide, hands "
    "pulling a cable attachment toward his face, a thin cable running from his hands "
    "to the top of the column"),
 "cable-row": (V4 / "cable-row_control.png",
    "seated cable row, sitting upright on a low bench with legs extended forward and "
    "knees slightly bent, elbow pulled back, hands pulling a cable handle to his "
    "torso, a thin taut cable running horizontally to a low pulley column in front"),
 "lat-pulldown": (V4 / "lat-pulldown_control.png",
    "lat pulldown machine, seated with thighs under a knee pad, both hands gripping a "
    "wide bar pulled down to his upper chest, elbows bent pointing down, a thin cable "
    "running from the middle of the bar up to the top pulley of the machine"),
 "leg-extension": (V4 / "leg-extension_control.png",
    "leg extension machine, seated upright on the machine seat, hands holding the side "
    "handles, one shin extended straight forward and up against a padded roller at the "
    "ankle"),
 "leg-curl": (V4 / "leg-curl_control.png",
    "lying leg curl machine, lying face down on the machine bench, shins curled up "
    "toward the ceiling against a padded roller at the ankles, hands holding the "
    "handles under the bench"),
 "bench-press": (V4 / "bench-press_control.png",
    "barbell bench press, lying on his back on a flat bench, feet flat on the floor, "
    "both arms extended straight up holding a barbell with round weight plates above "
    "his chest"),
 "hip-thrust": (V4 / "hip-thrust_control.png",
    "barbell hip thrust, upper back and shoulders resting on a low bench, hips lifted "
    "high in line with the shoulders, knees bent, feet flat on the floor, a barbell "
    "with round plates resting across his hips"),
 "side-plank": (V3 / "side-plank_control.png",
    "side plank, balancing on one straight arm with the hand flat on the mat, body "
    "turned sideways in one straight diagonal line, feet stacked, the other arm "
    "pointing straight up toward the ceiling"),
 "bird-dog": (V4 / "bird-dog_control.png",
    "bird dog exercise, on all fours on the mat, one arm extended straight forward "
    "horizontal and the opposite leg extended straight back horizontal, back flat, "
    "supported on the other hand and knee"),
 "forearm-plank": (V3 / "forearm-plank_control.png",
    "forearm plank, elbows and forearms pressed flat into the mat under the shoulders, "
    "body in one straight horizontal line from head to heels, toes tucked"),
}

YOGA = {
 "butterfly": (V4 / "butterfly_control.png",
    "butterfly pose (baddha konasana), FRONT view, sitting upright with the soles of "
    "both feet pressed together in front of her, knees bent open to the sides, hands "
    "holding her feet, back straight"),
 "head-to-knee": (V4 / "head-to-knee_control.png",
    "head to knee pose (janu sirsasana), sitting with one leg extended straight "
    "forward, the other knee bent open with the foot against the inner thigh, torso "
    "folded forward over the straight leg, hands reaching toward the foot"),
 "child": (V4 / "child_control.png",
    "child's pose (balasana), kneeling with hips resting back on the heels, torso "
    "folded forward over the thighs, forehead close to the mat, arms extended forward "
    "on the mat"),
 "bird-dog": (V4 / "bird-dog_control.png",
    "bird dog exercise, on all fours on the mat, one arm extended straight forward "
    "horizontal and the opposite leg extended straight back horizontal, back flat, "
    "supported on the other hand and knee"),
 "warrior2": (V3 / "warrior2_control.png",
    "warrior two pose, deep lunge with the front knee bent above the ankle, back leg "
    "straight, both feet flat, torso UPRIGHT vertical, both arms extended straight "
    "horizontal at shoulder height, one forward one backward, gaze forward"),
 "warrior3": (V3 / "warrior3_control.png",
    "warrior three pose, balancing on one straight leg, torso horizontal leaning "
    "forward, the back leg lifted straight behind at hip height, arms extended forward "
    "past the ears, body forming a T"),
 "wide-angle-seated-fold": (V3 / "wide-angle-seated-fold_control.png",
    "wide angle seated forward fold, FRONT view, sitting with both legs stretched "
    "straight and spread wide apart in a V, torso leaning forward between the legs, "
    "hands on the mat"),
 "wide-legged-forward-fold": (V3 / "wide-legged-forward-fold_control.png",
    "wide legged standing forward fold, FRONT view, feet spread very wide apart flat "
    "on the mat, legs straight, torso folded down with the head hanging between the "
    "legs, hands on the mat"),
 "side-plank-f": (V3 / "side-plank_control.png",
    "side plank, balancing on one straight arm with the hand flat on the mat, body "
    "turned sideways in one straight diagonal line, feet stacked, the other arm "
    "pointing straight up toward the ceiling"),
}


def run(table, tmpl, prefix, seed=777):
    for slug, (ctrl, pose) in table.items():
        dest = OUT / f"{prefix}_{slug}_s{seed}.png"
        if dest.exists():
            continue
        assert ctrl.exists(), f"contrôle manquant {ctrl}"
        replicate_run("black-forest-labs/flux-canny-pro",
            {"prompt": tmpl.format(pose=pose), "control_image": b64(ctrl),
             "guidance": 30, "steps": 50, "seed": seed, "output_format": "png",
             "safety_tolerance": 2}, dest)
        time.sleep(2)


if __name__ == "__main__":
    run(MUSCU, MALE, "M")
    run(YOGA, FEMALE, "Y")
    print("VAGUE 4 GÉNÉRÉE", flush=True)
