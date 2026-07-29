import pathlib
import sys
import time

sys.path.insert(0, ".")
from pilot_flux import replicate_run, b64
from kontext_edit import kontext

# VAGUE 4 — essai 2 ciblé après gate 1 pleine taille (07-11).
# Deux familles de retry :
#   FLUX  : re-génération seed 1234 + prompt renforcé sur le mode d'échec observé
#   KONTEXT : correction chirurgicale d'une image par ailleurs bonne (drift équipement/perso)
# Après cet essai 2 : ce qui échoue part en à-revoir (politique 2 essais max).

V3 = pathlib.Path("ai-explo/vague3")
V4 = pathlib.Path("ai-explo/vague4")
PLANCHE = pathlib.Path("ai-explo/planche")

MALE = ("flat vector illustration of a man doing a strength exercise, {pose}, "
        "short dark hair, wearing a fitted white t-shirt, navy blue pants and sneakers, "
        "minimalist flat design, clean simple shapes, soft muted colors, plain light "
        "mauve-gray background, on a thin dark navy exercise mat, full body visible, side view")
# variante sans "side view" pour les poses de FACE (le suffixe side view écrasait FRONT)
FEMALE_FRONT = ("flat vector illustration of a woman practicing yoga, {pose}, "
    "wearing a fitted white sleeveless top fully covering her torso and light blue leggings, "
    "barefoot, short brown hair in a low bun, minimalist flat design, clean simple shapes, "
    "soft muted colors, plain warm light beige background, on a thin white exercise mat, "
    "full body visible, front view facing the viewer")
FEMALE_SIDE = FEMALE_FRONT.replace("front view facing the viewer", "side view")

# slug -> (control, template, pose, prefix)
FLUX_RETRIES = {
 "bentover-row": (V4 / "bentover-row_control.png", MALE,
    "bent-over barbell row, torso hinged forward with a FLAT back, knees slightly bent, "
    "BOTH hands gripping a horizontal barbell pulled up against his stomach, the bar "
    "stays BELOW his chest near his belly, elbow bent pointing up behind his back, one "
    "small round weight plate on the end of the bar", "M"),
 "side-plank": (V3 / "side-plank_control.png", MALE,
    "side plank, one straight arm with the hand flat on the mat, body in one straight "
    "diagonal line, both feet STACKED together RESTING ON the mat, the edge of the "
    "bottom foot touching the ground, the other arm pointing straight up", "M"),
 "glute-bridge": (V4 / "glute-bridge_control.png", MALE,
    "glute bridge, lying on his BACK face up, head and shoulders resting flat on the "
    "mat, hips lifted HIGH so his body forms a straight ramp from shoulders to knees, "
    "knees bent, both feet flat on the mat, arms resting on the mat along his sides", "M"),
 "calf-raise": (V4 / "calf-raise_control.png", MALE,
    "standing calf raise, standing tall perfectly upright, both HEELS RAISED HIGH off "
    "the ground, standing on tiptoes on the balls of his feet, a clear visible gap "
    "between his heels and the mat, legs straight, arms relaxed at his sides", "M"),
 "pullup": (V4 / "pullup_control.png", MALE,
    "pull-up, hanging from a horizontal bar mounted on a tall frame, BOTH hands "
    "gripping the bar overhead, elbows bent, chin just below the bar, body hanging "
    "straight down with knees bent and feet lifted off the floor", "M"),
 "dips": (V4 / "dips_control.png", MALE,
    "triceps dips, body UPRIGHT held between two parallel bars, both arms straight "
    "and locked, hands gripping the bars beside his hips, knees bent with feet "
    "crossed behind him, feet clearly OFF the floor, body supported only by his arms", "M"),
 "rdl-barbell": (PLANCHE / "deadlift_control.png", MALE,
    "Romanian deadlift with a barbell, hips hinged back, back perfectly FLAT, head in "
    "line with the spine, knees slightly bent, both arms straight holding a LONG THIN "
    "horizontal barbell at mid-shin height, one round weight plate at the end of the "
    "long bar, NOT a dumbbell, both feet flat side by side", "M"),
 "box-jump": (V4 / "box-jump_control.png", MALE,
    "box jump landing, standing on top of a sturdy dark plyometric box with BOTH feet "
    "flat on the box wearing sneakers, knees and hips bent in a stable landing squat, "
    "torso leaning slightly forward, both arms extended forward for balance", "M"),
 "lat-pulldown": (V4 / "lat-pulldown_control.png", MALE,
    "lat pulldown machine, seated with thighs under a knee pad, both hands gripping a "
    "long straight wide bar pulled down to his upper chest, elbows bent pointing "
    "down, a thin cable running from the middle of the bar straight up to the top "
    "pulley of the machine, nothing else attached to the bar", "M"),
 "hanging-leg-raise": (V4 / "hanging-leg-raise_control.png", MALE,
    "hanging leg raise, hanging from a high horizontal bar, BOTH arms straight "
    "overhead with both hands visibly gripping the bar, shoulders below the hands, "
    "both legs together raised straight forward horizontal at hip height, feet off "
    "the floor", "M"),
 "facepull": (V4 / "facepull_control.png", MALE,
    "cable face pull, standing facing a tall cable column, elbows BENT high and "
    "wide at shoulder height, both hands pulled back close to his face, a thin cable "
    "running from his hands to the top of the column, short dark hair", "M"),
 "hip-thrust": (V4 / "hip-thrust_control.png", MALE,
    "barbell hip thrust, upper back and shoulders resting on a low dark bench behind "
    "him, hips lifted high level with his shoulders, knees bent at 90 degrees, both "
    "feet flat on the floor, a horizontal barbell resting across his hips with one "
    "round weight plate at the end", "M"),
 "bird-dog-m": (V4 / "bird-dog_control.png", MALE,
    "bird dog exercise, kneeling on all fours on the mat, ONE person only, one arm "
    "extended straight forward horizontal, the opposite leg extended straight back "
    "horizontal, back flat and parallel to the ground, one hand and one knee on the "
    "mat, ONE single head looking down", "M"),
 "nordic-curl": (V4 / "nordic-curl_control.png", MALE,
    "Nordic hamstring curl, kneeling upright with both shins flat on the mat, his "
    "ankles held down by a low padded roller close to the mat behind his heels, body "
    "leaning slowly forward in one straight rigid line from knees to head, arms "
    "crossed over his chest, nothing in his hands", "M"),
 "leg-curl": (V4 / "leg-curl_control.png", MALE,
    "lying leg curl machine, a man lying face DOWN flat on a long horizontal bench, "
    "chest and hips on the bench, both shins bent up toward the ceiling with a small "
    "padded roller resting on the back of his ankles, hands holding handles under "
    "the bench, ONE person, normal human body", "M"),
 # ---- yoga ----
 "butterfly": (V4 / "butterfly_control.png", FEMALE_FRONT,
    "butterfly pose (baddha konasana), FRONT view facing the viewer, adult woman "
    "sitting upright LARGE in the frame, soles of both feet pressed together in "
    "front of her, both knees bent open wide to the sides, hands holding her feet, "
    "back straight, head upright", "Y"),
 "child": (V4 / "child_control.png", FEMALE_SIDE,
    "child's pose (balasana), KNEELING with her hips sitting back resting on her "
    "heels, knees folded completely under her body, torso folded forward resting on "
    "her thighs, forehead touching the mat, arms extended forward flat on the mat", "Y"),
 "warrior3": (V3 / "warrior3_control.png", FEMALE_SIDE,
    "warrior three pose, balancing on one straight standing leg, torso horizontal "
    "parallel to the floor, the back leg lifted straight behind at hip height, BOTH "
    "arms extended straight FORWARD past her ears in line with her body, hands NOT "
    "touching the floor, body forming a straight horizontal T", "Y"),
 "side-plank-f": (V3 / "side-plank_control.png", FEMALE_SIDE,
    "side plank, one straight arm with the hand flat on the mat, body in one "
    "straight diagonal line, both feet STACKED together RESTING ON the mat, the "
    "edge of the bottom foot touching the ground, the other arm pointing straight "
    "up toward the ceiling", "Y"),
}

# corrections chirurgicales d'images par ailleurs bonnes
KONTEXT_FIXES = {
 "rdl-dumbbell": (V4 / "M_rdl-dumbbell_s777.png", V4 / "M_rdl-dumbbell_fix.png",
    "Small correction: make the dumbbell he is holding much smaller, with two small "
    "round dark gray heads and a thin dark gray handle, a normal hand-held dumbbell."),
 "kb-swing": (V4 / "M_kb-swing_s777.png", V4 / "M_kb-swing_fix.png",
    "Small correction: change his hair to short flat dark hair, change the kettlebell "
    "color to dark gray, and change his shoes to plain navy blue sneakers."),
 "cable-row": (V4 / "M_cable-row_s777.png", V4 / "M_cable-row_fix.png",
    "Small correction: change his top to a fitted white t-shirt with short sleeves "
    "covering his shoulders."),
 "pushup": (V4 / "M_pushup_s777.png", V4 / "M_pushup_fix.png",
    "Small correction: give him short dark hair neatly drawn on his head."),
}

if __name__ == "__main__":
    for slug, (ctrl, tmpl, pose, prefix) in FLUX_RETRIES.items():
        dest = V4 / f"{prefix}_{slug}_s1234.png"
        if dest.exists():
            continue
        assert ctrl.exists(), f"contrôle manquant {ctrl}"
        replicate_run("black-forest-labs/flux-canny-pro",
            {"prompt": tmpl.format(pose=pose), "control_image": b64(ctrl),
             "guidance": 30, "steps": 50, "seed": 1234, "output_format": "png",
             "safety_tolerance": 2}, dest)
        time.sleep(2)
    for slug, (src, dest, prompt) in KONTEXT_FIXES.items():
        if dest.exists():
            continue
        kontext(src, dest, prompt)
        time.sleep(2)
    print("RETRIES VAGUE 4 TERMINÉS", flush=True)
