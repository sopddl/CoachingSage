import base64, json, pathlib, time, urllib.request

# Fix ciblé facepull (07-14 tard, session solo) : regen3 a la bonne pose/machine
# (elbows hauts, tirage au visage) mais (1) barre droite au lieu de corde à 2
# poignées, (2) fond rose/mauve au lieu du gris-mauve établi (wall-sit/rdl/fente),
# (3) build à revérifier vs le perso canon de la session. Root cause probable :
# prompt vague4_canon.py disait juste "cable attachment", jamais "rope".

TOKEN = pathlib.Path("~/.replicate_token").expanduser().read_text().strip()
SRC = "ai-explo/vague4/M_facepull_v5.png"
DEST = "ai-explo/vague4/M_facepull_v6.png"

PROMPT = (
    "Redraw this exact same man in the exact same face pull pose and exact same "
    "cable machine column, but make these two SPECIFIC changes: "
    "(1) THE ROPE: right now it is drawn as ONE continuous straight cord from the "
    "column all the way to both hands. Change it so that the cable from the column "
    "ends in a metal carabiner clip, and BELOW that clip hangs a short black rope "
    "attachment that SPLITS INTO TWO SEPARATE DANGLING ROPE ENDS with a knotted ball "
    "at the tip of each — his LEFT hand grips one rope end, his RIGHT hand grips the "
    "OTHER rope end, and the two hands and rope ends are clearly APART from each "
    "other near his face, not touching, with a visible V-shaped gap between the two "
    "ropes. "
    "(2) THE BACKGROUND COLOR: completely repaint the wall behind him from its "
    "current pink/rose tint to a neutral flat light warm gray (hex approximately "
    "#A8A0A3, the color of wet concrete, absolutely no pink or red hue), and repaint "
    "the floor mat from navy to a plain dark blue-gray. "
    "Everything else stays identical: same person, same short dark hair, same fitted "
    "white t-shirt, same navy blue pants, same navy sneakers, same body build, same "
    "flat vector illustration style, same side view, full body visible."
)

img = base64.b64encode(pathlib.Path(SRC).read_bytes()).decode()
inputs = {"prompt": PROMPT, "input_image": f"data:image/png;base64,{img}",
          "aspect_ratio": "1:1", "output_format": "png", "safety_tolerance": 2}
body = json.dumps({"input": inputs}).encode()
pred = None
for attempt in range(6):
    req = urllib.request.Request(
        "https://api.replicate.com/v1/models/black-forest-labs/flux-kontext-pro/predictions",
        data=body, headers={"Authorization": f"Bearer {TOKEN}",
                             "Content-Type": "application/json", "Prefer": "wait=60"})
    try:
        with urllib.request.urlopen(req, timeout=90) as r:
            pred = json.load(r)
        break
    except urllib.error.HTTPError as e:
        if e.code == 429:
            time.sleep(15 * (attempt + 1))
        else:
            print(f"FAIL: HTTP {e.code} {e.read()[:300]}")
            raise SystemExit(1)
if pred is None:
    print("FAIL: 429 persistant"); raise SystemExit(1)
while pred["status"] not in ("succeeded", "failed", "canceled"):
    time.sleep(3)
    req = urllib.request.Request(pred["urls"]["get"], headers={"Authorization": f"Bearer {TOKEN}"})
    with urllib.request.urlopen(req, timeout=30) as r:
        pred = json.load(r)
if pred["status"] != "succeeded":
    print(f"FAIL: {pred.get('error')}"); raise SystemExit(1)
out = pred["output"]
url = out if isinstance(out, str) else out[-1]
urllib.request.urlretrieve(url, DEST)
print(f"OK — {DEST}")
