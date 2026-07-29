import sys
sys.path.insert(0, "..")
from posture_rig import *
from rig_to_openpose import build_keypoints, render_openpose_png

# ---- Tadasana : pose symétrique debout, bras le long du corps ----
c = Chain("ankle", (40, 43))
c.add("knee", SHIN, 270, kind='leg')
c.add("hip", THIGH, 270, kind='leg')
c.add("shoulder", TORSO, 270)
c.add_arm("", 100, 100, from_name="shoulder")
head_c, _ = head_and_neck(c.points["shoulder"], 270)

mapping = {
    "Nose": head_c,
    "Neck": c.points["shoulder"],
    "RShoulder": c.points["shoulder"], "LShoulder": c.points["shoulder"],
    "RElbow": c.points["elbow"], "LElbow": c.points["elbow"],
    "RWrist": c.points["wrist"], "LWrist": c.points["wrist"],
    "RHip": c.points["hip"], "LHip": c.points["hip"],
    "RKnee": c.points["knee"], "LKnee": c.points["knee"],
    "RAnkle": c.points["ankle"], "LAnkle": c.points["ankle"],
}
kp = build_keypoints(mapping, 512, 512)
render_openpose_png(kp, 512, 512, "tadasana_openpose.png")
print("OK — tadasana_openpose.png")

# ---- Triangle : vue de face, 2 jambes écartées, bras asymétriques (cas riche) ----
c2 = Chain("hip", (40, 26))
c2.add_leg("R", 20, 20, 350, from_name="hip")
c2.add_leg("L", 160, 160, 190, from_name="hip")
c2.add("shoulder", TORSO, 320, from_name="hip")
c2.add("elbow", UPPER_ARM, 100, from_name="shoulder", kind='arm')
c2.add("wrist", FOREARM, 100, kind='arm')
c2.add("elbowT", UPPER_ARM, 280, from_name="shoulder", kind='arm')
c2.add("wristT", FOREARM, 280, kind='arm')
head_c2, _ = head_and_neck(c2.points["shoulder"], 320)

mapping2 = {
    "Nose": head_c2,
    "Neck": c2.points["shoulder"],
    "RShoulder": c2.points["shoulder"], "LShoulder": c2.points["shoulder"],
    "RElbow": c2.points["elbow"], "RWrist": c2.points["wrist"],
    "LElbow": c2.points["elbowT"], "LWrist": c2.points["wristT"],
    "RHip": c2.points["hip"], "LHip": c2.points["hip"],
    "RKnee": c2.points["Rknee"], "RAnkle": c2.points["Rankle"],
    "LKnee": c2.points["Lknee"], "LAnkle": c2.points["Lankle"],
}
kp2 = build_keypoints(mapping2, 512, 512)
render_openpose_png(kp2, 512, 512, "triangle_openpose.png")
print("OK — triangle_openpose.png")
