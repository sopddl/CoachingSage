import pathlib
import sys
import time

sys.path.insert(0, ".")
from pilot_flux import replicate_run, b64
from kontext_edit import kontext

# Corrections finales vague 4 après gates expert + UX (07-11).
# kontext = P1 fixables sur images par ailleurs validées ; 1 seul essai chacune,
# échec → on garde l'original avec note. + 1 retry FLUX (head-to-knee essai 2 :
# hanches décollées, doit être ASSIS).

V4 = pathlib.Path("ai-explo/vague4")

FIXES = {
 "pushup": (V4 / "M_pushup_fix.png", V4 / "M_pushup_fix2.png",
    "Small correction: bend his elbows much more so his chest hovers just above the "
    "mat, upper arms angled back, clearly the bottom of a push-up."),
 "rdl-dumbbell": (V4 / "M_rdl-dumbbell_fix.png", V4 / "M_rdl-dumbbell_fix2.png",
    "Small correction: raise his head slightly so his neck is in line with his flat "
    "back, gaze directed forward and down, not straight down."),
 "bench-press": (V4 / "M_bench-press_s777.png", V4 / "M_bench-press_fix.png",
    "Small correction: move his hips fully onto the bench, bend his knees to 90 "
    "degrees with his feet flat on the floor under his knees, and attach his head "
    "to his neck resting on the bench."),
 "hanging-leg-raise": (V4 / "M_hanging-leg-raise_s777.png", V4 / "M_hanging-leg-raise_fix.png",
    "Small correction: draw both of his arms straight overhead beside his head, "
    "hands gripping the bar, nothing crossing in front of his face."),
 "box-jump": (V4 / "M_box-jump_s777.png", V4 / "M_box-jump_fix.png",
    "Small correction: place both of his feet wearing navy sneakers flat ON TOP of "
    "the box surface, clearly landed on the top of the box."),
}

FEMALE_SIDE = ("flat vector illustration of a woman practicing yoga, {pose}, "
    "wearing a fitted white sleeveless top fully covering her torso and light blue leggings, "
    "barefoot, short brown hair in a low bun, minimalist flat design, clean simple shapes, "
    "soft muted colors, plain warm light beige background, on a thin white exercise mat, "
    "full body visible, side view")

if __name__ == "__main__":
    for slug, (src, dest, prompt) in FIXES.items():
        if dest.exists():
            continue
        kontext(src, dest, prompt)
        time.sleep(2)
    dest = V4 / "Y_head-to-knee_s1234.png"
    if not dest.exists():
        ctrl = V4 / "head-to-knee_control.png"
        replicate_run("black-forest-labs/flux-canny-pro",
            {"prompt": FEMALE_SIDE.format(pose=(
                "head to knee pose (janu sirsasana), SITTING on the mat with her hips and "
                "sitting bones resting ON the floor, one leg extended straight forward along "
                "the mat, the other knee bent open to the side with the sole of the foot "
                "against the inner thigh of the straight leg, torso folded forward over the "
                "straight leg, hands reaching toward the foot")),
             "control_image": b64(ctrl), "guidance": 30, "steps": 50, "seed": 1234,
             "output_format": "png", "safety_tolerance": 2}, dest)
    print("FIX2 VAGUE 4 TERMINÉ", flush=True)
