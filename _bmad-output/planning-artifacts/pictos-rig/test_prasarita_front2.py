import pathlib, sys
sys.path.insert(0, ".")
from pilot_flux import replicate_run, b64 as b64uri
from generate_reliquat import make_control, FEMALE_OPEN_KNEES

OUT = pathlib.Path("reliquat_final")
src = pathlib.Path(
    "/private/tmp/claude-501/-Users-sophieslama-CL3-CoachingSage/1ebc4de0-525f-4a83-a3e0-de235546a9ae/"
    "scratchpad/pictos_poc/prasarita_front_silhouette2.png")
ctrl = OUT / "prasaritaPadottanasana_control.png"
make_control(src, ctrl)

pose_desc = ("prasarita padottanasana seen from the front, facing the camera directly, "
             "standing with legs spread very wide apart in a wide V shape, feet flat on the mat, "
             "torso folded forward and down, shoulders and arms clearly attached to the torso "
             "not the legs, head hanging down near the floor between the arms, "
             "both hands reaching down and touching the floor between the legs, "
             "camera angle and body orientation matching the reference exactly, front view not side view")

dest = OUT / "prasaritaPadottanasana.png"
ok = replicate_run('black-forest-labs/flux-canny-pro',
    {'prompt': FEMALE_OPEN_KNEES.format(pose=pose_desc), 'control_image': b64uri(ctrl),
     'guidance': 22, 'steps': 50, 'seed': 777, 'output_format': 'png',
     'safety_tolerance': 2}, dest)
print("RESULT", ok, dest)
