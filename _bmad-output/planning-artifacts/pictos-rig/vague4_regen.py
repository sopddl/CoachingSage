import pathlib
import sys

sys.path.insert(0, ".")
from pilot_flux import replicate_run, b64

# Re-génération propre FLUX-canny (07-12) des 4 récalcitrants au kontext.
# Cause racine : le kontext oscille sur build/pose. On repart du RIG (pose juste)
# avec un prompt qui BAKE le bon gabarit (ordinaire, membres lisses) dès la source.
# leg-extension : rig corrigé (tibia horizontal). dead-bug/rdl/kb-swing : rig OK.

V4 = pathlib.Path("ai-explo/vague4")
SEED = 888

# Prompt homme = gabarit ORDINAIRE lisse (= réf A_m_stand), pas maigre pas musclé.
MALE = ("flat vector illustration of a man doing a strength exercise, {pose}, "
        "ORDINARY average body build with normal healthy proportions, smooth flat "
        "limbs with NO muscle definition, not skinny and not muscular, short dark "
        "hair, wearing a fitted white t-shirt with short sleeves, navy blue pants "
        "and navy sneakers, minimalist flat design, clean simple shapes, soft muted "
        "colors, NO thick black outlines, plain light mauve-gray background, on a "
        "thin dark navy exercise mat, full body fully visible inside the frame, side view")

JOBS = {
 "rdl-dumbbell": (V4 / "rdl-dumbbell_control.png",
    "Romanian deadlift with a dumbbell, hips hinged back, back perfectly FLAT and "
    "straight, head in line with the spine, knees slightly bent, arm hanging straight "
    "down holding one normal-size dumbbell in front of the shins, both feet flat side by side"),
 "kb-swing": (V4 / "kb-swing_control.png",
    "kettlebell swing, hips hinged back, back flat, knees slightly bent, BOTH hands "
    "together gripping the handle of ONE single kettlebell, both arms straight extended "
    "forward at chest height, both feet flat on the mat parallel side by side"),
 "leg-extension": (V4 / "leg-extension_control_fix.png",
    "seated leg extension machine, sitting upright on the machine seat, hands holding "
    "the side handles, one leg extended straight forward HORIZONTAL with the shin in "
    "line with the thigh and the foot at knee height against a padded roller at the "
    "ankle, knee almost straight"),
 "dead-bug": (V4 / "dead-bug_control.png",
    "dead bug core exercise, lying on his back on the mat, one thigh vertical with the "
    "shin horizontal (knee bent 90 degrees over the hip), the other leg extended "
    "straight and low near the mat, one arm reaching straight overhead, head resting "
    "on the mat"),
}

if __name__ == "__main__":
    for slug, (ctrl, pose) in JOBS.items():
        dest = V4 / f"M_{slug}_regen.png"
        assert ctrl.exists(), f"contrôle manquant {ctrl}"
        replicate_run("black-forest-labs/flux-canny-pro",
            {"prompt": MALE.format(pose=pose), "control_image": b64(ctrl),
             "guidance": 30, "steps": 50, "seed": SEED, "output_format": "png",
             "safety_tolerance": 2}, dest)
        print(f"OK — {dest}", flush=True)
    print("REGEN TERMINÉE", flush=True)
