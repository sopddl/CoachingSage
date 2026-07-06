#!/usr/bin/env python3
"""Annotation blocs budgétés — chantier durée réglable, pilote cycling (Increment 1).

Doctrine : _bmad-output/planning-artifacts/doctrine-duree-cycling-2026-07-04.md
(VALIDÉE Sophie 2026-07-04, section 2-4).

Ajoute sur chaque exercice cycling (root + variantes indoor/outdoor) : `role`
(core/accessory), `scaling_unit` (continuous/roundsReps/fixed), `priority`
(accessoires seulement, ordre de sacrifice) et `estimated_minutes` (minutes
réelles à cardinalité template). Ajoute sur chaque session/variante :
`warmup_minutes` / `cooldown_minutes`.

Principe de calcul (évite le calcul de minutes par exo indépendant, sujet à
dérive vs `duration_minutes`) :
  1. warmup_minutes / cooldown_minutes = somme des "N min" trouvés dans le
     texte FR (canonique) de warmup/cooldown.
  2. remainder = duration_minutes - warmup_minutes - cooldown_minutes
     (garde-fou : si le texte fait déborder le remainder sous un plancher,
     warmup/cooldown sont recadrés proportionnellement, cas loggé pour revue).
  3. Chaque exercice reçoit un poids brut (regex sur dose/duration + sets +
     rest_seconds) puis `estimated_minutes` = allocation PROPORTIONNELLE du
     `remainder` selon ces poids, arrondi avec ajustement du reliquat sur le
     bloc `core` principal → la somme ferme EXACTEMENT sur `duration_minutes`
     (le filet `CyclingBudgetedBlocksTests` vérifie cette fermeture).

Classification `role` :
  - ACCESSORY_PATTERNS (renforcement préventif, activation/sprint courts,
    étirements, récup post-test, travail de cadence isolé) → accessory.
  - type `mobility` : la routine ("mobilité"/"mobility") est TOUJOURS core,
    le pédalage qui l'accompagne TOUJOURS accessory (doctrine section 4.3,
    décision validée — contre-intuitif, la routine est le vrai cœur).
  - Sinon : provisoirement core. S'il reste 2+ blocs core dans la même
    séance (ex. séance interval à double bloc d'effort), celui au plus PETIT
    poids brut devient accessory (finisher/complément — le bloc dominant
    reste core). Évite un ordre de priorité inventé entre deux vrais blocs
    d'intervalle : seul le renforcement préventif est un vrai sacrifice de
    plan (doctrine, choix pragmatique documenté ici plutôt que dans le doc
    figé, cf review avant merge).

`scaling_unit` : `roundsReps` si `sets > 1`, sinon `continuous`. Aucun bloc
`fixed` identifié en V1 cycling (cf doctrine section 2).
"""
import glob
import json
import pathlib
import re
import sys

ROOT = pathlib.Path(__file__).resolve().parents[2] / "Sources/TemplateLoader/Resources/Templates"
TEMPLATES = [
    "cycling-beginner-reprise-6sem.json",
    "cycling-recreational-endurance-10sem.json",
    "cycling-regular-sorties-longues-12sem.json",
    "cycling-competitive-cyclosportive-16sem.json",
]

# Renforcement préventif / activation courte / étirements / récup post-test / travail de
# cadence isolé — jamais le cœur d'une séance cycling (cf leon-algo-doctrine-by-sport.md
# "Renforcement préventif" + constat data réel doctrine section 1).
ACCESSORY_PATTERNS = [
    r"planche", r"pont fessier", r"calf raises", r"side plank", r"bird-dog",
    r"gainage", r"deadlift roumain", r"hip thrust", r"squat", r"single-leg",
    r"nordic curl", r"clamshell", r"abducteur",
    r"étirement", r"stretch",
    r"sprint", r"opener", r"strides", r"activation",
    r"récupération post-test", r"repos absolu",
    r"^cadence haute ftp-z2$", r"^travail cadence haute ftp-z2$",
]
ACCESSORY_RE = re.compile("|".join(ACCESSORY_PATTERNS), re.IGNORECASE)
MOBILITY_CORE_RE = re.compile(r"mobilit|mobility", re.IGNORECASE)

MIN_RE = re.compile(r"(\d+)(?:-(\d+))?\s*min")
MULT_RE = re.compile(r"(\d+)\s*[×x]\s*(\d+)(?:-(\d+))?\s*(min|sec)")
# Fenêtres de temps nutrition/hydratation ("dans les 30 min", "protéines 30 min après") —
# ne sont PAS des composantes de durée warmup/cooldown, à exclure avant comptage. Scopé au
# vocabulaire nutrition/hydratation à proximité (± 40 car., cf `_is_nutrition_window`) pour
# ne pas avaler une future instruction chronométrée sans rapport (ex. « étirements dans les
# 5 min qui suivent »). Python `re` n'autorise pas les lookbehind à largeur variable, d'où
# le filtrage manuel (`_strip_nutrition_windows`) plutôt qu'un unique gros pattern.
NUTRITION_KEYWORDS_RE = re.compile(
    r"collation|hydrat|glucide|prot[eé]ine|boi(?:s|re)|[eé]lectrolyte|\beau\b|nutrition",
    re.IGNORECASE
)
NUTRITION_WINDOW_RE = re.compile(
    r"dans les \d+(?:-\d+)?\s*min|\d+(?:-\d+)?\s*min\s+apr[eè]s", re.IGNORECASE
)
_CONTEXT_RADIUS = 40


def _strip_nutrition_windows(text: str) -> str:
    """Retire les fenêtres nutrition UNIQUEMENT si un mot-clé nutrition apparaît dans les
    `_CONTEXT_RADIUS` caractères autour — sinon on garde la phrase (probablement une vraie
    composante de durée, cf finding review « scope trop large sinon »)."""
    out = []
    last_end = 0
    for m in NUTRITION_WINDOW_RE.finditer(text):
        window = text[max(0, m.start() - _CONTEXT_RADIUS): m.end() + _CONTEXT_RADIUS]
        if NUTRITION_KEYWORDS_RE.search(window):
            out.append(text[last_end:m.start()])
            last_end = m.end()
    out.append(text[last_end:])
    return "".join(out)


def minutes_in_text(text: str) -> float:
    """Minutes réelles décrites par un texte FR warmup/cooldown : gère les répétitions
    ("2×1 min à 110% FTP" = 2 min) et exclut les fenêtres nutrition ("dans les 30 min",
    "protéines 30 min après") qui ne sont pas des composantes de durée."""
    text = _strip_nutrition_windows(text or "")

    total = 0.0

    def consume_mult(m: re.Match) -> str:
        nonlocal total
        reps = int(m.group(1))
        lo = int(m.group(2))
        hi = int(m.group(3)) if m.group(3) else lo
        avg = (lo + hi) / 2
        unit_minutes = avg if m.group(4) == "min" else avg / 60.0
        total += reps * unit_minutes
        return ""

    text = MULT_RE.sub(consume_mult, text)

    for a, b in MIN_RE.findall(text):
        lo = int(a)
        hi = int(b) if b else lo
        total += (lo + hi) / 2
    return total


def exercise_raw_weight(ex: dict) -> tuple:
    """Poids brut en minutes-équivalent (dose structurée > texte libre, × sets, + repos)
    + un flag explicite `used_fallback` (vrai ssi RIEN n'était parseable et qu'on est
    retombé sur le placeholder 1.0/rep — le seul cas qui mérite un avertissement)."""
    sets = ex.get("sets") or 1
    rest_min = (ex.get("rest_seconds") or 0) / 60.0

    per_rep_minutes = None
    dose = ex.get("dose")
    if isinstance(dose, dict) and "unit" in dose and "value" in dose:
        value = dose["value"]
        lo_hi = re.match(r"(\d+)(?:-(\d+))?", str(value))
        if lo_hi:
            lo = int(lo_hi.group(1))
            hi = int(lo_hi.group(2)) if lo_hi.group(2) else lo
            avg = (lo + hi) / 2
            if dose["unit"] == "minutes":
                per_rep_minutes = avg
            elif dose["unit"] == "seconds":
                per_rep_minutes = avg / 60.0

    if per_rep_minutes is None:
        text = ex.get("duration") or ""
        parsed = minutes_in_text(text)
        if parsed > 0:
            per_rep_minutes = parsed
        else:
            # secondes en texte libre ("30 sec", "15 sec")
            sec_matches = re.findall(r"(\d+)\s*sec", text)
            if sec_matches:
                per_rep_minutes = sum(int(s) for s in sec_matches) / 60.0

    used_fallback = per_rep_minutes is None
    if used_fallback:
        per_rep_minutes = 1.0

    return per_rep_minutes * sets + rest_min * sets, used_fallback


def _exactly_one_core(roles: list, weights: list) -> list:
    """Parmi les candidats 'core' détectés par mot-clé (ou, à défaut, parmi TOUS les
    exercices si aucun n'a matché), celui au plus gros poids brut reste core — les autres
    passent accessory. Garantit ≥1 core même si le classement par mot-clé échoue totalement
    (ex. renommage futur d'un match_key qui ne matche plus aucun pattern)."""
    n = len(roles)
    candidates = [i for i, r in enumerate(roles) if r == "core"] or list(range(n))
    dominant = max(candidates, key=lambda i: weights[i])
    return [("core" if i == dominant else "accessory") for i in range(n)]


def classify_roles(session_type: str, exercises: list, weights: list) -> list:
    """Retourne la liste des rôles ('core'/'accessory') alignée sur `exercises`."""
    n = len(exercises)
    if n == 1:
        return ["core"]

    if session_type == "mobility":
        # La routine mobilité est TOUJOURS core (doctrine section 4.3) ; même garde-fou
        # ≥1 core que la branche générique si un futur renommage fait perdre le match
        # MOBILITY_CORE_RE sur tous les exercices.
        roles = ["core" if MOBILITY_CORE_RE.search(e.get("match_key", "")) else "accessory"
                 for e in exercises]
        return _exactly_one_core(roles, weights)

    roles = ["accessory" if ACCESSORY_RE.search(e.get("match_key", "")) else "core"
              for e in exercises]
    return _exactly_one_core(roles, weights)


def annotate_exercises(session_type: str, exercises: list, remainder: float, log_prefix: str, warnings: list) -> None:
    if not exercises:
        return
    raw = [exercise_raw_weight(e) for e in exercises]
    weights = [w for w, _ in raw]
    for e, (_, used_fallback) in zip(exercises, raw):
        if used_fallback:
            warnings.append(f"{log_prefix} | poids fallback (1.0/rep) pour « {e.get('match_key')} »")

    roles = classify_roles(session_type, exercises, weights)

    total_w = sum(weights) or 1.0
    remainder = max(remainder, 0.0)
    raw_alloc = [remainder * w / total_w for w in weights]
    estimated = [round(a) for a in raw_alloc]
    drift = round(remainder) - sum(estimated)
    if drift != 0:
        # Le reliquat d'arrondi va sur le bloc core au plus gros poids (jamais un accessoire).
        core_idxs = [i for i, r in enumerate(roles) if r == "core"]
        target = max(core_idxs, key=lambda i: weights[i]) if core_idxs else max(range(len(weights)), key=lambda i: weights[i])
        estimated[target] += drift
        if estimated[target] < 0:
            # Ne devrait pas arriver (drift borné par l'arrondi, ≪ allocation du bloc
            # dominant) — si ça arrive quand même, on le dit au lieu de clamper en silence
            # et de casser la fermeture exacte du budget sans que personne ne le sache.
            warnings.append(
                f"{log_prefix} | drift d'arrondi ({drift}) a rendu « {exercises[target].get('match_key')} » "
                f"négatif ({estimated[target]}) — clampé à 0, budget ne ferme plus exactement"
            )

    accessory_order = 1
    for e, role, est in zip(exercises, roles, estimated):
        e["role"] = role
        e["scaling_unit"] = "roundsReps" if (e.get("sets") or 1) > 1 else "continuous"
        e["estimated_minutes"] = max(est, 0)
        if role == "accessory":
            e["priority"] = accessory_order
            accessory_order += 1
        else:
            e.pop("priority", None)


def annotate_session_like(session_type: str, node: dict, log_prefix: str, warnings: list) -> None:
    """`node` = session root OU variante — mêmes champs warmup/cooldown/exercises/duration_minutes."""
    warmup_text = (node.get("warmup") or {}).get("fr", "")
    cooldown_text = (node.get("cooldown") or {}).get("fr", "")
    warmup_min = minutes_in_text(warmup_text)
    cooldown_min = minutes_in_text(cooldown_text)

    duration = node["duration_minutes"]
    floor_remainder = max(duration * 0.2, 5)
    if warmup_min + cooldown_min > duration - floor_remainder:
        scale = (duration - floor_remainder) / (warmup_min + cooldown_min) if (warmup_min + cooldown_min) > 0 else 0
        warnings.append(
            f"{log_prefix} | warmup({warmup_min:.0f})+cooldown({cooldown_min:.0f}) "
            f"trop long vs duration({duration}) — recadré ×{scale:.2f}"
        )
        warmup_min *= scale
        cooldown_min *= scale

    node["warmup_minutes"] = round(warmup_min)
    node["cooldown_minutes"] = round(cooldown_min)
    remainder = duration - node["warmup_minutes"] - node["cooldown_minutes"]
    annotate_exercises(session_type, node.get("exercises", []), remainder, log_prefix, warnings)


def dump_matching_style(obj, original: str) -> str:
    """Round-trip du style du fichier d'origine (cf précédent scripts/densite_b)."""
    swift = '" : ' in original[:2000]
    out = json.dumps(obj, ensure_ascii=False, indent=2, sort_keys=True,
                      separators=(",", " : " if swift else ": "))
    if swift:
        out = re.sub(r'^(\s*)("[^"]+" : )\[\](,?)$', r"\1\2[\n\n\1]\3", out, flags=re.M)
    if original.endswith("\n"):
        out += "\n"
    return out


def main() -> int:
    total_sessions = 0
    all_warnings = []
    for fname in TEMPLATES:
        path = ROOT / fname
        original = path.read_text()
        t = json.loads(original)
        for w in t["weeks"]:
            for s in w["sessions"]:
                if s["type"] == "rest":
                    continue
                log_prefix = f"{fname} W{w['week_number']}D{s['day']} « {s['name'].get('fr','')[:40]} »"
                annotate_session_like(s["type"], s, log_prefix, all_warnings)
                for v in (s.get("variants") or []):
                    annotate_session_like(s["type"], v, log_prefix + f" [{v.get('environment')}]", all_warnings)
                total_sessions += 1
        path.write_text(dump_matching_style(t, original))
        print(f"{fname}: annoté")

    print(f"\nTOTAL: {total_sessions} séances annotées (rest exclu)")
    if all_warnings:
        print(f"\n{len(all_warnings)} AVERTISSEMENT(S) — à revoir :")
        for msg in all_warnings:
            print(f"  ! {msg}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
