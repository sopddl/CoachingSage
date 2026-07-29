import pathlib, sys
sys.path.insert(0, ".")
from pilot_flux import replicate_run, b64 as b64uri
from generate_reliquat import make_control, FEMALE

OUT = pathlib.Path("reliquat_final")
SIL = pathlib.Path(
    "/private/tmp/claude-501/-Users-sophieslama-CL3-CoachingSage/1ebc4de0-525f-4a83-a3e0-de235546a9ae/"
    "scratchpad/pictos_poc/rig4")

POSES = {
    "ardhaBaddhaPadmottanasana": (
        SIL / "ardha_silhouette.png",
        "ardha baddha padmottanasana, standing balanced on ONE straight leg only, torso "
        "bent forward at the hip to a horizontal flat-back position, this is NOT a "
        "symmetric two-legged forward fold — the other leg is CLEARLY bent backward in "
        "half-lotus, its knee pointing down and visibly sticking out behind the standing "
        "leg, its foot tucked near the opposite hip crease, the same-side hand reaching "
        "behind the back to hold that tucked foot, the free arm extended forward and down "
        "toward the floor for balance, head reaching toward the shin of the straight "
        "standing leg, only one foot touches the ground"),
    "bhujapidasana": (
        SIL / "bhuja_silhouette.png",
        "bhujapidasana, compact crouching arm balance, this is NOT a standing pose and "
        "NOT a forward fold — the entire body except the hands hovers off the ground, "
        "one bent arm with a sharply angled elbow presses a single palm flat on the floor "
        "and supports the full body weight, the body is curled into a low compact ball "
        "close to the floor, both knees are tucked tightly near the armpit and shoulder, "
        "both legs wrap backward with ankles crossed behind, feet clearly dangling in "
        "midair well above the floor, NO foot touches the ground anywhere, upper back "
        "rounded, head tucked low near the supporting arm looking forward"),
    "eagle": (
        SIL / "eagle_silhouette.png",
        "garudasana eagle pose, standing balance on one leg with the knee softly bent, the "
        "other leg CLEARLY wrapped and hooked around the front of the standing thigh, its "
        "foot tucked and hooked behind the standing calf, visibly a separate wrapped leg "
        "shape sticking out to the side, not two straight parallel legs — both arms are "
        "crossed and tightly wrapped around each other in front of the chest and face, "
        "forearms twisted together with palms pressed together near the chin, this is NOT "
        "one arm raised in a wave, both forearms are braided together, torso upright "
        "leaning slightly forward"),
    "kapotasana": (
        SIL / "kapot_silhouette.png",
        "kapotasana king pigeon pose, kneeling upright with both knees and shins on the "
        "floor, thighs vertical, hips pushed forward, a deep backbend arching the spine "
        "backward, chest lifted and open toward the ceiling, head dropped back reaching "
        "toward the feet, both arms reaching up and back overhead with bent elbows to grip "
        "the ankles behind"),
}

if __name__ == "__main__":
    slug = sys.argv[1] if len(sys.argv) > 1 else None
    targets = [slug] if slug else list(POSES)
    for s in targets:
        sil, pose_desc = POSES[s]
        assert sil.exists(), f"silhouette manquante: {sil}"
        ctrl = OUT / f"{s}_control.png"
        make_control(sil, ctrl)
        dest = OUT / f"{s}.png"
        ok = replicate_run(
            "black-forest-labs/flux-canny-pro",
            {"prompt": FEMALE.format(pose=pose_desc), "control_image": b64uri(ctrl),
             "guidance": 22, "steps": 50, "seed": 777, "output_format": "png",
             "safety_tolerance": 2},
            dest)
        print("RESULT", s, ok, dest)
