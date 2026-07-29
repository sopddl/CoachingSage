import pathlib, sys
sys.path.insert(0, ".")
from pilot_flux import replicate_run, b64 as b64uri
from generate_reliquat import make_control, FEMALE

OUT = pathlib.Path("reliquat_final")
src = pathlib.Path(
    "/private/tmp/claude-501/-Users-sophieslama-CL3-CoachingSage/1ebc4de0-525f-4a83-a3e0-de235546a9ae/"
    "scratchpad/pictos_poc/prasarita_silhouette.png")
ctrl = OUT / "prasaritaPadottanasana_control.png"
make_control(src, ctrl)

pose_desc = ("prasarita padottanasana, standing with legs spread very wide apart, "
             "torso folded forward and down at the hips, full torso and head clearly visible "
             "hanging between the legs, hands reaching down toward the floor, "
             "torso NOT hidden or shortened, back forms a clear diagonal line from hips to head")

dest = OUT / "prasaritaPadottanasana.png"
ok = replicate_run('black-forest-labs/flux-canny-pro',
    {'prompt': FEMALE.format(pose=pose_desc), 'control_image': b64uri(ctrl),
     'guidance': 22, 'steps': 50, 'seed': 777, 'output_format': 'png',
     'safety_tolerance': 2}, dest)
print("RESULT", ok, dest)
