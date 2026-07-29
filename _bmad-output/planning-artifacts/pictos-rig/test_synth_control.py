import pathlib, sys
sys.path.insert(0, ".")
from pilot_flux import replicate_run, b64 as b64uri
from generate_reliquat import GYM

OUT = pathlib.Path("reliquat_final")
ctrl_src = pathlib.Path(
    "/private/tmp/claude-501/-Users-sophieslama-CL3-CoachingSage/1ebc4de0-525f-4a83-a3e0-de235546a9ae/"
    "scratchpad/pictos_poc/hipthrust_control_synth.png")
ctrl_dest = OUT / "hip-thrust-synth_control.png"
ctrl_dest.write_bytes(ctrl_src.read_bytes())

pose_desc = ("only the upper back and shoulder blades resting on a raised bench, "
             "hips lifted high into a full bridge extension, knees bent at a right angle, "
             "feet flat on the floor, a heavy round weight plate resting across the front of the hips")

dest = OUT / "hip-thrust-synth.png"
ok = replicate_run('black-forest-labs/flux-canny-pro',
    {'prompt': GYM.format(pose=pose_desc), 'control_image': b64uri(ctrl_dest),
     'guidance': 22, 'steps': 50, 'seed': 777, 'output_format': 'png',
     'safety_tolerance': 2}, dest)
print("RESULT", ok, dest)
