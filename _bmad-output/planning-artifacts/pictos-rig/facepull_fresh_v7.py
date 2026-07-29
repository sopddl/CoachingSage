import pathlib, sys
sys.path.insert(0, ".")
from pilot_flux import replicate_run, b64

# Nouvelle génération FRAÎCHE (pas un edit kontext) depuis le rig control —
# les 2 tentatives kontext (v5, v6) n'ont pas réussi à séparer la corde en 2
# brins ni changer le fond (kontext ancre trop sur l'image source). On repart
# du control rig + prompt EXPLICITE "rope, not a bar" — la génération fraîche
# construit le fond mauve-gray par le prompt, pas par édition d'un fond existant.

V4 = pathlib.Path("ai-explo/vague4")
ctrl = V4 / "facepull_control_fix.png"
dest = V4 / "M_facepull_v7.png"

MALE = ("flat vector illustration of a man doing a strength exercise, {pose}, "
        "short dark hair, wearing a fitted white t-shirt, navy blue pants and sneakers, "
        "minimalist flat design, clean simple shapes, soft muted colors, plain light "
        "mauve-gray background, on a thin dark navy exercise mat, full body visible, side view")

POSE = ("cable face pull, standing facing a tall cable machine column, elbows raised "
        "high and wide out to the sides, both hands pulling a ROPE ATTACHMENT toward "
        "his face — the rope is clearly split into TWO SEPARATE thick rope ends with "
        "a knot at each tip, one rope end gripped in each fist, the two hands and rope "
        "ends held apart from each other near his cheeks, NOT a single straight bar")

replicate_run("black-forest-labs/flux-canny-pro",
    {"prompt": MALE.format(pose=POSE), "control_image": b64(ctrl),
     "guidance": 30, "steps": 50, "seed": 4242, "output_format": "png",
     "safety_tolerance": 2}, dest)
