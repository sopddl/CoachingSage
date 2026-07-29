import pathlib
import sys

sys.path.insert(0, ".")
from kontext_edit import kontext
from pilot_flux import replicate_run, b64

# Nettoyage garde-robe post-regen (07-12) : la re-gen rig a réglé pose+build+outline,
# restent des dérives seed 888 (short au lieu de pantalon, jambe foncée, pied nu, 4:3).
# Kontext = wardrobe only (ne touche PAS pose/build désormais corrects).

V4 = pathlib.Path("ai-explo/vague4")

MALE = ("flat vector illustration of a man doing a strength exercise, {pose}, "
        "ORDINARY average body build with normal healthy proportions, smooth flat "
        "limbs with NO muscle definition, short dark hair, wearing a fitted white "
        "t-shirt with short sleeves, navy blue full-length pants and navy sneakers, "
        "minimalist flat design, clean simple shapes, soft muted colors, NO thick "
        "black outlines, plain light mauve-gray background, on a thin dark navy "
        "exercise mat, full body fully visible inside the frame, side view")

if __name__ == "__main__":
    # rdl : short -> pantalon long
    kontext(V4 / "M_rdl-dumbbell_regen.png", V4 / "M_rdl-dumbbell_regen2.png",
        "Small correction: replace his shorts with full-length navy blue trousers "
        "reaching down to his navy sneakers.")
    # kb-swing : short -> pantalon long + les DEUX jambes en pantalon marine (pas de jambe foncée)
    kontext(V4 / "M_kb-swing_regen.png", V4 / "M_kb-swing_regen2.png",
        "Small correction: replace his shorts with full-length navy blue trousers on "
        "BOTH legs, both legs the exact same navy blue colour (no dark olive leg), "
        "reaching down to his navy sneakers.")
    # leg-extension : re-gen carré 1:1 + chaussure (fix aspect 4:3 + pied nu)
    replicate_run("black-forest-labs/flux-canny-pro",
        {"prompt": MALE.format(pose=(
            "seated leg extension machine, sitting upright on the machine seat, hands "
            "holding the side handles, one leg extended straight forward HORIZONTAL "
            "with the shin in line with the thigh and the foot at knee height against "
            "a padded roller at the ankle, knee almost straight, wearing navy sneakers")),
         "control_image": b64(V4 / "leg-extension_control_fix.png"),
         "guidance": 30, "steps": 50, "seed": 888, "aspect_ratio": "1:1",
         "output_format": "png", "safety_tolerance": 2},
        V4 / "M_leg-extension_regen2.png")
    print("CLEANUP TERMINÉ", flush=True)
