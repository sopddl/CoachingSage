import json
import pathlib
import sys
import time

sys.path.insert(0, ".")
from kontext_edit import kontext

# Vague de retries gate-1 : prompts renforcés. Les "Small correction" partent de
# la B existante (itération) ; les "Change her pose" repartent de la A du type.
BATCH = pathlib.Path("ai-explo/batch")
manifest = {m["slug"]: m for m in json.loads((BATCH / "manifest.json").read_text())}
A_IMAGES = {"debout": "A_debout.png", "assis_sol": "A_assis_sol.png", "quadrupede": "A_quadrupede.png"}
retries = json.loads((BATCH / "retry_prompts.json").read_text())

for i, (slug, prompt) in enumerate(retries.items()):
    dest = BATCH / f"B_{slug}_v2.png"
    if dest.exists():
        continue
    if prompt.startswith("Small correction"):
        src = BATCH / f"B_{slug}.png"
    else:
        src = BATCH / A_IMAGES[manifest[slug]["start_type"]]
    ok = kontext(str(src), str(dest), prompt)
    print(f"[{i+1}/{len(retries)}] {slug}: {'ok' if ok else 'FAIL'}", flush=True)
    time.sleep(2)
print("RETRIES TERMINÉS", flush=True)
