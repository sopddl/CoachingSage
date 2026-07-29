import pathlib, sys
sys.path.insert(0, ".")
from pilot_flux import replicate_run, b64 as b64uri
from generate_reliquat import make_control, FEMALE_OPEN_KNEES

OUT = pathlib.Path("reliquat_final")
src = pathlib.Path(
    "/private/tmp/claude-501/-Users-sophieslama-CL3-CoachingSage/1ebc4de0-525f-4a83-a3e0-de235546a9ae/"
    "scratchpad/pictos_poc/kapotasana_silhouette2.png")
ctrl = OUT / "kapotasana_control.png"
make_control(src, ctrl)

pose_desc = ("kapotasana, seated on the shins with a deep backbend, front leg folded on the "
             "ground, back leg bent with the foot lifted up and back, both hands reaching "
             "overhead and back to grab the lifted foot behind the head, "
             "chest lifted and open, head tilted back looking up, "
             "camera angle and body orientation matching the reference exactly")

dest = OUT / "kapotasana.png"
ok = replicate_run('black-forest-labs/flux-canny-pro',
    {'prompt': FEMALE_OPEN_KNEES.format(pose=pose_desc), 'control_image': b64uri(ctrl),
     'guidance': 22, 'steps': 50, 'seed': 777, 'output_format': 'png',
     'safety_tolerance': 2}, dest)
print("RESULT", ok, dest)
