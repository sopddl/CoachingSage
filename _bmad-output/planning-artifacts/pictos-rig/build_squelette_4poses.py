"""4 poses (plyo-jumpsquat, reverse-hyper, side-plank, sled-push) via la
methode validee squelette-trace -> silhouette -> make_control -> flux-canny-pro
(cf test_boat.py, succes 2026-07-20). Geometrie + verification numerique dans
skel4.py (scratchpad). Template GYM verrouille (generate_reliquat.py).
"""
import pathlib
import sys

from PIL import Image, ImageDraw

sys.path.insert(0, "/private/tmp/claude-501/-Users-sophieslama-CL3-CoachingSage/"
                    "1ebc4de0-525f-4a83-a3e0-de235546a9ae/scratchpad/pictos_poc")
import skel4 as S  # noqa: E402

sys.path.insert(0, ".")
from generate_reliquat import make_control, GYM  # noqa: E402
from pilot_flux import replicate_run, b64  # noqa: E402

OUT = pathlib.Path("reliquat_final")
MARGIN = 220


def capsule(d, p1, p2, width):
    d.line([p1, p2], fill=0, width=int(width))
    for p in (p1, p2):
        r = width / 2
        d.ellipse([p1[0] - r, p1[1] - r, p1[0] + r, p1[1] + r], fill=0)


def render(pts, chain, acc_rects, out_path):
    all_pts = list(pts.values())
    for rect in acc_rects:
        all_pts += [(rect[0], rect[1]), (rect[2], rect[3])]
    x0, y0, x1, y1 = S.bbox(all_pts, pad=int(S.TORSO_W_PX / 2 + 10))
    W = int(x1 - x0) + MARGIN * 2
    H = int(y1 - y0) + MARGIN * 2
    ox, oy = MARGIN - x0, MARGIN - y0

    def off(p):
        return (p[0] + ox, p[1] + oy)

    im = Image.new("L", (W, H), 255)
    d = ImageDraw.Draw(im)

    for rect in acc_rects:
        rx0, ry0, rx1, ry1 = rect
        d.rectangle([rx0 + ox, ry0 + oy, rx1 + ox, ry1 + oy], fill=0)

    widths = {
        ("shoulder", "hip"): S.TORSO_W_PX, ("hip", "shoulder"): S.TORSO_W_PX,
        ("shoulder", "elbow"): S.ARM_W_PX, ("elbow", "hand"): S.ARM_W_PX,
        ("shoulder", "free_elbow"): S.ARM_W_PX, ("free_elbow", "free_hand"): S.ARM_W_PX,
        ("hip", "knee"): S.LEG_W_PX, ("knee", "ankle"): S.SHIN_W_PX, ("ankle", "toe"): S.FOOT_W_PX,
        ("hip", "back_knee"): S.LEG_W_PX, ("back_knee", "back_ankle"): S.SHIN_W_PX,
        ("back_ankle", "back_toe"): S.FOOT_W_PX,
        ("shoulder", "neck_head"): S.NECK_W_PX,
    }
    for frm, ang, length, to in chain:
        if to == "head":
            continue
        w = widths.get((frm, to), S.ARM_W_PX)
        capsule(d, off(pts[frm]), off(pts[to]), w)
    # bras libre (side-plank) + jambe arriere (sled-push) : segments hors chain{}
    if "free_elbow" in pts:
        capsule(d, off(pts["shoulder"]), off(pts["free_elbow"]), S.ARM_W_PX)
        capsule(d, off(pts["free_elbow"]), off(pts["free_hand"]), S.ARM_W_PX)
    if "back_knee" in pts:
        capsule(d, off(pts["hip"]), off(pts["back_knee"]), S.LEG_W_PX)
        capsule(d, off(pts["back_knee"]), off(pts["back_ankle"]), S.SHIN_W_PX)
        capsule(d, off(pts["back_ankle"]), off(pts["back_toe"]), S.FOOT_W_PX)
    # cou + tete (tete dessinee en dernier, par-dessus)
    capsule(d, off(pts["shoulder"]), off(pts["head"]), S.NECK_W_PX)
    hx, hy = off(pts["head"])
    r = S.HEAD_R_PX
    d.ellipse([hx - r, hy - r, hx + r, hy + r], fill=0)

    im.save(out_path)
    return out_path


POSES = {
    "plyo-jumpsquat": dict(
        pts=S.pts1, chain=S.chain1, acc=S.acc1,
        desc=("explosive jump squat captured at the peak of the airborne phase, the entire body "
              "floating and suspended high up in mid-air, both feet completely off the ground and "
              "NOT touching any platform, surface, step, or floor of any kind, there is empty open air "
              "below both of his feet with a visible gap between his feet and the ground, this is NOT a "
              "standing pose and NOT a single-leg balance pose, both knees are equally bent together and "
              "pulled up toward the chest in a tight symmetric tucked position, both thighs raised close "
              "to horizontal, both shins folded back and up beneath the thighs, torso upright and leaning "
              "slightly backward for balance, both arms swept down and behind the body from the momentum "
              "of the jump, head up, a dynamic mid-flight jump photo, weightless, airborne")),
    "reverse-hyper": dict(
        pts=S.pts2, chain=S.chain2, acc=S.acc2,
        desc=("reverse hyperextension exercise, lying face down on top of a raised flat exercise bench, "
              "hips positioned right at the edge of the bench, chest and head fully supported flat on the "
              "bench surface, both hands gripping the sides of the bench near the shoulders, both legs "
              "extended straight together and lifted up behind him clearly above hip height into hip "
              "extension, forming a straight line continuing from the torso, side view")),
    "side-plank": dict(
        pts=S.pts3, chain=S.chain3, acc=S.acc3,
        desc=("side plank exercise, the whole body turned completely onto its side and viewed from a "
              "lateral side profile with the torso rotated fully sideways, NOT facing the camera and NOT "
              "a front-facing plank, lying on one side with the body forming one straight rigid line from "
              "head to feet, supporting all body weight on one forearm placed flat on the floor directly "
              "under the shoulder with the elbow bent at a right angle, both feet stacked directly on top "
              "of each other, hips lifted so the body forms a straight line from shoulder to ankle, the "
              "free arm reaching straight up toward the ceiling perpendicular to the floor")),
    "sled-push": dict(
        pts=S.pts4, chain=S.chain4, acc=S.acc4,
        desc=("sled push exercise, standing and pushing against a low sled apparatus, torso bent forward "
              "dramatically at the hips until it is almost parallel to the ground, both arms fully "
              "extended straight forward and down gripping the low upright handles of the sled, hands NOT "
              "on the ground, this is NOT a plank or push-up position, a big powerful running-stride lunge "
              "with a large distance between the two feet like a sprinter's start: the FRONT leg is sharply "
              "bent with the knee driving forward and down directly under the torso, while the BACK leg is "
              "almost completely straight and stretched far out behind him at a low shallow angle close to "
              "the ground with the heel lifted high and only the toes touching the ground pushing off, the "
              "two legs look clearly different from each other, not symmetric, not a crouched squat, head "
              "down looking forward toward the sled, low aggressive forward-leaning pushing posture")),
}


def run_one(slug, seed=777, guidance=22):
    p = POSES[slug]
    sil = OUT / f"{slug}_silhouette.png"
    render(p["pts"], p["chain"], p["acc"], sil)
    ctrl = OUT / f"{slug}_control.png"
    make_control(sil, ctrl)
    dest = OUT / f"{slug}.png"
    ok = replicate_run("black-forest-labs/flux-canny-pro",
        {"prompt": GYM.format(pose=p["desc"]), "control_image": b64(ctrl),
         "guidance": guidance, "steps": 50, "seed": seed, "output_format": "png",
         "safety_tolerance": 2}, dest)
    return ok, dest


if __name__ == "__main__":
    slugs = sys.argv[1:] or list(POSES.keys())
    for slug in slugs:
        ok, dest = run_one(slug)
        print(slug, "OK" if ok else "FAIL", dest)
