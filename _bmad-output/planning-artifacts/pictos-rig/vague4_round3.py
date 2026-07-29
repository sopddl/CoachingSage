import pathlib
import sys

sys.path.insert(0, ".")
from pilot_flux import replicate_run, b64

# Round 3 (07-12) — retours rendu Sophie sur les 3 restants :
#   hanging « trop gros » → regen rig build ordinaire lisse (comme rdl/kb-swing validés)
#   leg-extension « trop maigre » → regen build un peu PLUS PLEIN (sur-correction inverse)
#   dead-bug « pied coupé » → SVG jambe tendue rentrée (foot x56) + regen

V4 = pathlib.Path("ai-explo/vague4")

# gabarit ordinaire lisse (validé sur rdl/kb-swing/cable-row)
FLAT = ("ORDINARY average body build with normal healthy proportions, smooth flat "
        "limbs with NO muscle definition, not skinny and not muscular, ")
# variante un peu plus pleine pour leg-extension (jugé trop maigre)
FULLER = ("NORMAL healthy adult body build, NOT skinny, with normal solid legs and "
          "torso (not thin), smooth flat limbs with no muscle definition, ")

BASE = ("short dark hair, fitted white t-shirt with short sleeves, navy blue "
        "full-length pants and navy sneakers, minimalist flat design, clean simple "
        "shapes, soft muted colors, NO thick black outlines, plain light mauve-gray "
        "background, thin dark navy exercise mat, full body fully visible inside the "
        "frame, side view")

JOBS = [
    ("M_hanging-leg-raise_regen.png", V4 / "hanging-leg-raise_control.png",
     "flat vector illustration of a man doing a hanging leg raise, hanging from a "
     "high horizontal bar with both arms straight overhead, both legs together "
     "raised straight forward horizontal at hip height, feet off the floor, "
     + FLAT + BASE),
    ("M_leg-extension_regen5.png", V4 / "leg-extension_control_fix.png",
     "flat vector illustration of a man doing a seated leg extension on a machine, "
     "sitting upright, hands holding the side handles, one leg extended straight "
     "forward HORIZONTAL with the shin in line with the thigh and the foot at knee "
     "height against a padded roller, knee almost straight, "
     + FULLER + BASE),
    ("M_dead-bug_regen5.png", V4 / "dead-bug_control_fix.png",
     "flat vector illustration of a man doing the dead bug core exercise, lying flat "
     "on his back on the mat, one knee bent up in tabletop (thigh vertical, shin "
     "horizontal), the other leg extended straight out and LOW just above the mat, "
     "one arm reaching straight up with a simple rounded mitten hand and no fingers, "
     "the other arm resting on the mat, head on the mat, "
     + FLAT + "all hands drawn as simple rounded shapes without fingers, " + BASE),
]

if __name__ == "__main__":
    for dest, ctrl, prompt in JOBS:
        assert ctrl.exists(), f"contrôle manquant {ctrl}"
        replicate_run("black-forest-labs/flux-canny-pro",
            {"prompt": prompt, "control_image": b64(ctrl), "guidance": 30,
             "steps": 50, "seed": 888, "output_format": "png", "safety_tolerance": 2},
            V4 / dest)
        print(f"OK — {dest}", flush=True)
    print("ROUND3 TERMINÉ", flush=True)
