import json
import pathlib
import sys
import time

sys.path.insert(0, ".")
from kontext_edit import kontext

# Boucle batch : B (position clé) = kontext(A du start_type, prompt du manifeste).
# Reprise : skip si le PNG existe déjà. Log JSONL append-only pour suivi/audit.

BATCH = pathlib.Path("ai-explo/batch")
A_IMAGES = {
    "debout": BATCH / "A_debout.png",
    "assis_sol": BATCH / "A_assis_sol.png",
    "quadrupede": BATCH / "A_quadrupede.png",
    # allonge_dos : pas d'image A fiable (4 échecs) → file « à revoir »
}
LOG = BATCH / "generation_log.jsonl"

manifest = json.loads((BATCH / "manifest.json").read_text())
todo = [m for m in manifest if m["start_type"] in A_IMAGES]
skipped = [m for m in manifest if m["start_type"] not in A_IMAGES]
print(f"batch: {len(todo)} à générer, {len(skipped)} en file à revoir "
      f"({sorted(set(m['start_type'] for m in skipped))})", flush=True)

done = failed = 0
for i, m in enumerate(todo):
    dest = BATCH / f"B_{m['slug']}.png"
    if dest.exists():
        done += 1
        continue
    ok = kontext(str(A_IMAGES[m["start_type"]]), str(dest), m["kontext_prompt_en"])
    with LOG.open("a") as f:
        f.write(json.dumps({"slug": m["slug"], "ok": ok, "ts": time.strftime("%H:%M:%S")}) + "\n")
    done += ok
    failed += not ok
    print(f"[{i+1}/{len(todo)}] {m['slug']}: {'ok' if ok else 'FAIL'}", flush=True)
    time.sleep(2)  # throttle doux en plus du backoff 429

print(f"TERMINÉ — {done} ok, {failed} échecs, {len(skipped)} à-revoir", flush=True)
