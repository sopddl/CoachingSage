#!/usr/bin/env python3
# Chantier structuration i18n du dosage (party 2026-06-14). Pipeline UNIQUE et pérenne :
#   - injecte le champ `dose` (structuré / intervalle / freeText) dans les templates JSON,
#     depuis une table de mapping FR distincte -> dose (tout-ou-rien, T2 « no Frankenstein ») ;
#   - régénère le bloc Swift `LegacyDoseMigration` (migration T3, backfill display-time des
#     séances déjà figées) depuis LA MÊME table -> source unique, zéro divergence.
#
# Usage :
#   python3 inject_dose.py inject 'running-*.json'   # injecte dans les fichiers matchés (cwd)
#   python3 inject_dose.py gen-migration running      # imprime le bloc Swift des entrées running
#
# Le format de sortie (swiftjson) est byte-compatible avec le sérialiseur des templates ;
# le trailing newline de CHAQUE fichier est préservé -> le diff git ne contient que les `dose`.
#
# Lots livrés : yoga (Lot 1, 2026-06-14) · running (Lot 2, 2026-06-15).

import sys, glob, json, copy, os
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from swiftjson import dumps

def S(value, unit, qualifier=None, style=None, modifier=None):
    d = {"value": value, "unit": unit}
    if qualifier: d["qualifier"] = qualifier
    if style: d["style"] = style
    if modifier: d["modifier"] = modifier
    return d

def F(fr, en, es):
    return {"free_text": {"fr": fr, "en": en, "es": es}}

def seg(value, unit, activity):
    return {"value": value, "unit": unit, "activity": activity}

def I(*segments):
    return {"segments": list(segments)}

# ============================================================================
# Table de mapping FR distincte -> dose. Sections par lot (yoga puis running).
# ============================================================================
YOGA = {
    # ====================== LOT 1 — YOGA ======================
    # --- DURATIONS ---
    "1 cycle": S("1", "cycles"),
    "1 cycle complet": S("1", "cycles"),
    "1 cycle breath-led": S("1", "cycles", style="breathLed"),
    "1 cycle = 9 respirations breath-led": F("1 cycle = 9 respirations au rythme du souffle", "1 cycle = 9 breath-led breaths", "1 ciclo = 9 respiraciones al ritmo de la respiración"),
    "1 cycle = 17 respirations breath-led": F("1 cycle = 17 respirations au rythme du souffle", "1 cycle = 17 breath-led breaths", "1 ciclo = 17 respiraciones al ritmo de la respiración"),
    "1 cycle complet (~1 min 30)": F("1 cycle complet (~1 min 30)", "1 full cycle (~1 min 30)", "1 ciclo completo (~1 min 30)"),
    "1 cycle complet (~2 min)": F("1 cycle complet (~2 min)", "1 full cycle (~2 min)", "1 ciclo completo (~2 min)"),
    "1 min": S("1", "minutes"),
    "1 min 30": F("1 min 30", "1 min 30", "1 min 30"),
    "2 min": S("2", "minutes"),
    "2.5 min séquence": S("2.5", "minutes"),
    "3 min": S("3", "minutes"),
    "3.5 min finishing": S("3.5", "minutes"),
    "3.5 min séquence": S("3.5", "minutes"),
    "4 min": S("4", "minutes"),
    "4 min finishing cutback": S("4", "minutes"),
    "4 min séquence": S("4", "minutes"),
    "4.5 min finishing": S("4.5", "minutes"),
    "5 min": S("5", "minutes"),
    "5 min séquence": S("5", "minutes"),
    "5.5 min séquence": S("5.5", "minutes"),
    "5.5 min séquence finishing": S("5.5", "minutes"),
    "6 min": S("6", "minutes"),
    "6 min finishing": S("6", "minutes"),
    "6 min séquence": S("6", "minutes"),
    "6.5 min finishing": S("6.5", "minutes"),
    "7 min": S("7", "minutes"),
    "8 min": S("8", "minutes"),
    "10 min": S("10", "minutes"),
    "12 min": S("12", "minutes"),
    "15 min": S("15", "minutes"),
    "18 min": S("18", "minutes"),
    "20 min": S("20", "minutes"),
    "20 min lecture + réflexion": F("20 min de lecture + réflexion", "20 min reading + reflection", "20 min de lectura + reflexión"),
    "3 min (~10 cycles)": F("3 min (~10 cycles)", "3 min (~10 cycles)", "3 min (~10 ciclos)"),
    "3 min (~10 cycles respiratoires)": F("3 min (~10 cycles respiratoires)", "3 min (~10 breath cycles)", "3 min (~10 ciclos respiratorios)"),
    "5 min (2 min Dirgha + 3 min Ujjayi)": F("5 min (2 min Dirgha + 3 min Ujjayi)", "5 min (2 min Dirgha + 3 min Ujjayi)", "5 min (2 min Dirgha + 3 min Ujjayi)"),
    "5 min (3 min Dirgha + 2 min Ujjayi)": F("5 min (3 min Dirgha + 2 min Ujjayi)", "5 min (3 min Dirgha + 2 min Ujjayi)", "5 min (3 min Dirgha + 2 min Ujjayi)"),
    "6 min (3 min Dirgha + 3 min Ujjayi)": F("6 min (3 min Dirgha + 3 min Ujjayi)", "6 min (3 min Dirgha + 3 min Ujjayi)", "6 min (3 min Dirgha + 3 min Ujjayi)"),
    # seconds
    "20 sec": S("20", "seconds"),
    "25 sec": S("25", "seconds"),
    "30 sec": S("30", "seconds"),
    "30 sec hold": S("30", "seconds"),
    "35 sec": S("35", "seconds"),
    "40 sec": S("40", "seconds"),
    "45 sec": S("45", "seconds"),
    "50 sec": S("50", "seconds"),
    "60 sec": S("60", "seconds"),
    "90 sec": S("90", "seconds"),
    "30-45 sec": S("30-45", "seconds"),
    "20 sec par côté": S("20", "seconds", qualifier="perSide"),
    "30 sec par côté": S("30", "seconds", qualifier="perSide"),
    "45 sec par côté": S("45", "seconds", qualifier="perSide"),
    "60 sec par côté": S("60", "seconds", qualifier="perSide"),
    "60s par côté": S("60", "seconds", qualifier="perSide"),
    "30 sec Ujjayi par côté": S("30", "seconds", style="ujjayi", qualifier="perSide"),
    "20-30s par essai": S("20-30", "seconds", qualifier="perAttempt"),
    "30s par essai": S("30", "seconds", qualifier="perAttempt"),
    "45s par essai": S("45", "seconds", qualifier="perAttempt"),
    "60s par essai": S("60", "seconds", qualifier="perAttempt"),
    "60 sec par posture par côté": F("60 s par posture et par côté", "60 s per pose and per side", "60 s por postura y por lado"),
    "60s tenue": F("60 s en tenue", "60 s hold", "60 s en mantenimiento"),
    "60s libre tenue": F("60 s, tenue libre", "60 s, free hold", "60 s, mantenimiento libre"),
    "90s libre tenue": F("90 s, tenue libre", "90 s, free hold", "90 s, mantenimiento libre"),
    "3-5 sec hold + descente contrôlée": F("3-5 s de tenue + descente contrôlée", "3-5 s hold + controlled lowering", "3-5 s de mantenimiento + descenso controlado"),
    # breaths
    "3 respirations": S("3", "breaths"),
    "5 respirations": S("5", "breaths"),
    "8 respirations": S("8", "breaths"),
    "9 respirations": S("9", "breaths"),
    "17 respirations": S("17", "breaths"),
    "9 respirations breath-led": S("9", "breaths", style="breathLed"),
    "17 respirations breath-led": S("17", "breaths", style="breathLed"),
    "5 respirations Ujjayi": S("5", "breaths", style="ujjayi"),
    "8 respirations Ujjayi": S("8", "breaths", style="ujjayi"),
    "10 respirations Ujjayi": S("10", "breaths", style="ujjayi"),
    "5 respirations par côté": S("5", "breaths", qualifier="perSide"),
    "8 respirations par côté": S("8", "breaths", qualifier="perSide"),
    "10 respirations par côté": S("10", "breaths", qualifier="perSide"),
    "5 respirations Ujjayi par côté": S("5", "breaths", style="ujjayi", qualifier="perSide"),
    "8 respirations Ujjayi par côté": S("8", "breaths", style="ujjayi", qualifier="perSide"),
    "10 respirations Ujjayi par côté": S("10", "breaths", style="ujjayi", qualifier="perSide"),
    "5 respirations par posture": S("5", "breaths", qualifier="perPose"),
    "5 respirations Ujjayi par posture": S("5", "breaths", style="ujjayi", qualifier="perPose"),
    "5 respirations par tenue": S("5", "breaths", qualifier="perHold"),
    "5 respirations par variante": S("5", "breaths", qualifier="perVariation"),
    "5 respirations chaque variante": S("5", "breaths", qualifier="perVariation"),
    "5 respirations Ujjayi par variante": S("5", "breaths", style="ujjayi", qualifier="perVariation"),
    "5 respirations chaque": S("5", "breaths", qualifier="perEach"),
    "5 respirations chacune": S("5", "breaths", qualifier="perEach"),
    # breaths — composites / double qualifier -> freeText
    "5 respirations + 9 roulis": F("5 respirations + 9 roulis", "5 breaths + 9 rolls", "5 respiraciones + 9 balanceos"),
    "5 respirations + Lolasana entre": F("5 respirations + Lolasana entre chaque", "5 breaths + Lolasana in between", "5 respiraciones + Lolasana entre cada una"),
    "5 respirations Ujjayi par côté par variante": F("5 respirations Ujjayi par côté et par variante", "5 Ujjayi breaths per side and per variation", "5 respiraciones Ujjayi por lado y por variación"),
    "5 respirations Ujjayi par posture / par côté": F("5 respirations Ujjayi par posture et par côté", "5 Ujjayi breaths per pose and per side", "5 respiraciones Ujjayi por postura y por lado"),
    "5 respirations Ujjayi par posture, vinyasa entre côtés": F("5 respirations Ujjayi par posture, vinyasa entre les côtés", "5 Ujjayi breaths per pose, vinyasa between sides", "5 respiraciones Ujjayi por postura, vinyasa entre lados"),
    "5 respirations chaque par côté": F("5 respirations chacune, par côté", "5 breaths each, per side", "5 respiraciones cada una, por lado"),
    "5 respirations chaque posture par côté": F("5 respirations par posture et par côté", "5 breaths per pose and per side", "5 respiraciones por postura y por lado"),
    "5 respirations chaque variante (avant + côté + dehri)": F("5 respirations par variante (avant + côté + dehri)", "5 breaths per variation (front + side + dehri)", "5 respiraciones por variación (frente + lado + dehri)"),
    "5 respirations par côté pour A et B": F("5 respirations par côté pour A et B", "5 breaths per side for A and B", "5 respiraciones por lado para A y B"),
    # pranayama composites -> freeText
    "30 respirations rapides + 1 Dirgha lente": F("30 respirations rapides + 1 Dirgha lente", "30 fast breaths + 1 slow Dirgha", "30 respiraciones rápidas + 1 Dirgha lenta"),
    "30 respirations rapides + 1 Dirgha entre cycles": F("30 respirations rapides + 1 Dirgha entre les cycles", "30 fast breaths + 1 Dirgha between cycles", "30 respiraciones rápidas + 1 Dirgha entre ciclos"),
    "30 expulsions actives + inspiration passive": F("30 expulsions actives + inspiration passive", "30 active exhales + passive inhale", "30 exhalaciones activas + inhalación pasiva"),
    # --- REPS (yoga) ---
    "2 cycles breath-led": S("2", "cycles", style="breathLed"),
    "3 cycles breath-led": S("3", "cycles", style="breathLed"),
    "3 cycles breath-led enchaînés": S("3", "cycles", style="breathLed"),
    "3 cycles complets breath-led": S("3", "cycles", style="breathLed"),
    "4 cycles breath-led": S("4", "cycles", style="breathLed"),
    "4 cycles breath-led enchaînés": S("4", "cycles", style="breathLed"),
    "5 cycles breath-led": S("5", "cycles", style="breathLed"),
    "5 cycles breath-led enchaînés": S("5", "cycles", style="breathLed"),
}

RUNNING = {
    # ====================== LOT 2 — RUNNING ======================
    # --- DURATIONS : minutes pleines ---
    "14 min": S("14", "minutes"),
    "22 min": S("22", "minutes"),
    "25 min": S("25", "minutes"),
    "30 min": S("30", "minutes"),
    "35 min": S("35", "minutes"),
    "40 min": S("40", "minutes"),
    "42 min": S("42", "minutes"),
    "50 min": S("50", "minutes"),
    "53 min": S("53", "minutes"),
    "55 min": S("55", "minutes"),
    "60 min": S("60", "minutes"),
    "65 min": S("65", "minutes"),
    "70 min": S("70", "minutes"),
    "75 min": S("75", "minutes"),
    "78 min": S("78", "minutes"),
    "82 min": S("82", "minutes"),
    "92 min": S("92", "minutes"),
    "102 min": S("102", "minutes"),
    "105 min": S("105", "minutes"),
    "117 min": S("117", "minutes"),
    "130 min": S("130", "minutes"),
    # --- DURATIONS : secondes ---
    "10 sec": S("10", "seconds"),
    "12 sec": S("12", "seconds"),
    "15 sec": S("15", "seconds"),
    "55 sec": S("55", "seconds"),
    # « 20 sec par côté » est déjà couvert par le bloc yoga (même valeur) → pas redéclaré ici.
    "35 sec par côté": S("35", "seconds", qualifier="perSide"),
    # --- DURATIONS : distance km ---
    "1 km": S("1", "kilometers"),
    "2 km": S("2", "kilometers"),
    "3 km": S("3", "kilometers"),
    "4 km": S("4", "kilometers"),
    "5 km": S("5", "kilometers"),
    "6 km": S("6", "kilometers"),
    "7 km": S("7", "kilometers"),
    "7.5 km": S("7.5", "kilometers"),
    "8 km": S("8", "kilometers"),
    "9 km": S("9", "kilometers"),
    "10 km": S("10", "kilometers"),
    "11 km": S("11", "kilometers"),
    "12 km": S("12", "kilometers"),
    "13 km": S("13", "kilometers"),
    "14 km": S("14", "kilometers"),
    "15 km": S("15", "kilometers"),
    "16 km": S("16", "kilometers"),
    "18 km": S("18", "kilometers"),
    "20 km": S("20", "kilometers"),
    "21 km": S("21", "kilometers"),
    "24 km": S("24", "kilometers"),
    "42,2 km": S("42.2", "kilometers"),
    # --- DURATIONS : distance mètres (variantes d'espacement source normalisées) ---
    "400 m": S("400", "meters"),
    "600 m": S("600", "meters"),
    "600m": S("600", "meters"),
    "800 m": S("800", "meters"),
    "800m": S("800", "meters"),
    "1000 m": S("1000", "meters"),
    "1000m": S("1000", "meters"),
    "1200m": S("1200", "meters"),
    # --- DURATIONS : distance + glose temps estimé -> freeText ---
    "600m (≈ 2 min 20 - 2 min 45 selon ton niveau)": F("600 m (≈ 2 min 20 - 2 min 45 selon ton niveau)", "600 m (≈ 2 min 20 - 2 min 45 depending on your level)", "600 m (≈ 2 min 20 - 2 min 45 según tu nivel)"),
    "800m (≈ 3 min - 3 min 40)": F("800 m (≈ 3 min - 3 min 40)", "800 m (≈ 3 min - 3 min 40)", "800 m (≈ 3 min - 3 min 40)"),
    "1 mile (≈ 6 min - 7 min 30)": F("1 mile (≈ 6 min - 7 min 30)", "1 mile (≈ 6 min - 7 min 30)", "1 milla (≈ 6 min - 7 min 30)"),
    "1000m (≈ 3 min 50 - 4 min 30)": F("1000 m (≈ 3 min 50 - 4 min 30)", "1000 m (≈ 3 min 50 - 4 min 30)", "1000 m (≈ 3 min 50 - 4 min 30)"),
    "2 km (≈ 8 min - 9 min 30)": F("2 km (≈ 8 min - 9 min 30)", "2 km (≈ 8 min - 9 min 30)", "2 km (≈ 8 min - 9 min 30)"),
    "1200m (≈ 4 min 40 - 5 min 30)": F("1200 m (≈ 4 min 40 - 5 min 30)", "1200 m (≈ 4 min 40 - 5 min 30)", "1200 m (≈ 4 min 40 - 5 min 30)"),
    # --- DURATIONS : descriptif / sélection -> freeText ---
    "105-120 min selon objectif": F("105-120 min selon ton objectif", "105-120 min depending on your goal", "105-120 min según tu objetivo"),
    "5 km à effort contrôlé (pas sprint maximal)": F("5 km à effort contrôlé (pas un sprint maximal)", "5 km at controlled effort (not an all-out sprint)", "5 km a esfuerzo controlado (no un sprint máximo)"),
    # --- DURATIONS : segment unique avec activité -> interval 1-segment ---
    "4 min course": I(seg("4", "minutes", "running")),
    "5 min course": I(seg("5", "minutes", "running")),
    "8 min course": I(seg("8", "minutes", "running")),
    "20 sec accélération progressive": I(seg("20", "seconds", "accelerationProgressive")),
    # --- DURATIONS : intervalles course/marche (minutes pleines -> minutes ;
    #     toute borne en « X min 30 » -> tout le bloc en secondes pour rester exact) ---
    "3 min course + 2 min marche": I(seg("3", "minutes", "running"), seg("2", "minutes", "walking")),
    "5 min course + 2 min marche": I(seg("5", "minutes", "running"), seg("2", "minutes", "walking")),
    "1 min 30 course + 2 min marche": F("1 min 30 de course + 2 min de marche", "1 min 30 running + 2 min walking", "1 min 30 de carrera + 2 min de caminata"),
    "1 min course lente + 1 min 30 marche rapide": F("1 min de course lente + 1 min 30 de marche rapide", "1 min slow running + 1 min 30 brisk walking", "1 min de carrera lenta + 1 min 30 de caminata rápida"),
    "1 min 30 course + 1 min 30 marche + 3 min course + 3 min marche": F("1 min 30 de course + 1 min 30 de marche + 3 min de course + 3 min de marche", "1 min 30 running + 1 min 30 walking + 3 min running + 3 min walking", "1 min 30 de carrera + 1 min 30 de caminata + 3 min de carrera + 3 min de caminata"),
    "100 m accélération progressive + 60 sec marche récupération": I(seg("100", "meters", "accelerationProgressive"), seg("60", "seconds", "walkingRecovery")),
    "60 m à allure cible 10K + 60 sec marche récupération": I(seg("60", "meters", "pace10K"), seg("60", "seconds", "walkingRecovery")),
    "1 min à allure 5K (RPE 8) + 1 min footing easy (facile (tu peux parler))": I(seg("1", "minutes", "pace5K"), seg("1", "minutes", "easyJog")),
    "1 min à allure 5K (RPE 8) + 1 min 30 footing easy (facile (tu peux parler))": F("1 min à allure 5K + 1 min 30 de footing tranquille", "1 min at 5K pace + 1 min 30 easy jogging", "1 min a ritmo 5K + 1 min 30 de trote suave"),
    "1 min 30 à allure 5K (RPE 8) + 1 min 30 footing easy (facile (tu peux parler))": F("1 min 30 à allure 5K + 1 min 30 de footing tranquille", "1 min 30 at 5K pace + 1 min 30 easy jogging", "1 min 30 a ritmo 5K + 1 min 30 de trote suave"),
    # --- REPS (running : renfo / éducatifs) ---
    "5": S("5", "reps"),
    "6": S("6", "reps"),
    "7": S("7", "reps"),
    "8": S("8", "reps"),
    "10": S("10", "reps"),
    "12": S("12", "reps"),
    "15": S("15", "reps"),
    "20": S("20", "reps"),
    "5-6": S("5-6", "reps"),
    "6-7": S("6-7", "reps"),
    "7-8": S("7-8", "reps"),
    "8 par côté": S("8", "reps", qualifier="perSide"),
    "10 par côté": S("10", "reps", qualifier="perSide"),
    "12 par côté": S("12", "reps", qualifier="perSide"),
    "15 par côté": S("15", "reps", qualifier="perSide"),
    "6 par jambe": S("6", "reps", qualifier="perLeg"),
    "8 par jambe": S("8", "reps", qualifier="perLeg"),
    "10 par jambe": S("10", "reps", qualifier="perLeg"),
    "12 par jambe": S("12", "reps", qualifier="perLeg"),
    "15 par jambe": S("15", "reps", qualifier="perLeg"),
    "16 par jambe": S("16", "reps", qualifier="perLeg"),
    "18 par jambe": S("18", "reps", qualifier="perLeg"),
}

# Table complète (union) + clés du seul Lot 2 (pour gen-migration ciblé sans toucher au yoga).
DOSE = {**YOGA, **RUNNING}
RUNNING_KEYS = list(RUNNING.keys())


def inject(ex, missing):
    if "dose" in ex:
        del ex["dose"]  # idempotent re-run
    src = ex.get("duration")
    if src is None:
        src = ex.get("reps")
    if src is None:
        return 0
    if src not in DOSE:
        missing.add(src)
        return 0
    ex["dose"] = copy.deepcopy(DOSE[src])
    return 1


def run_inject(pattern):
    missing = set(); added = 0; total = 0
    files = sorted(glob.glob(pattern))
    if not files:
        print(f"ABORT — aucun fichier ne matche {pattern!r} dans {os.getcwd()}"); sys.exit(1)
    parsed = {}; trailing = {}
    for p in files:
        raw = open(p, encoding='utf-8').read()
        trailing[p] = "\n" if raw.endswith("\n") else ""
        t = json.loads(raw); parsed[p] = t
        for w in t["weeks"]:
            for s in w["sessions"]:
                for ex in s.get("exercises", []):
                    total += 1; added += inject(ex, missing)
                for v in (s.get("variants") or []):
                    for ex in v.get("exercises", []):
                        total += 1; added += inject(ex, missing)
    if missing:
        print("ABORT — strings non mappées:")
        for m in sorted(missing): print("  MISSING|", m)
        sys.exit(1)
    for p in files:
        open(p, "w", encoding="utf-8").write(dumps(parsed[p]) + trailing[p])
    print(f"OK — dose injecté: {added}/{total} exos, sur {len(files)} fichiers. 0 string non mappée.")


# ---- gen-migration : émet le bloc Swift LegacyDoseMigration pour un sous-ensemble ----

def _swift_str(s):
    return json.dumps(s, ensure_ascii=False)

def _swift_dose(d):
    if "free_text" in d:
        ft = d["free_text"]
        return f'.freeText(LocalizedText(fr: {_swift_str(ft["fr"])}, en: {_swift_str(ft["en"])}, es: {_swift_str(ft["es"])}))'
    if "segments" in d:
        segs = []
        for sg in d["segments"]:
            segs.append(f'IntervalSegment(value: {_swift_str(sg["value"])}, unit: DoseUnit(rawValue: {_swift_str(sg["unit"])})!, activity: DoseActivity(rawValue: {_swift_str(sg["activity"])})!)')
        return f'.interval([{", ".join(segs)}])'
    parts = [f'value: {_swift_str(d["value"])}', f'unit: DoseUnit(rawValue: {_swift_str(d["unit"])})!']
    if d.get("qualifier"): parts.append(f'qualifier: DoseQualifier(rawValue: {_swift_str(d["qualifier"])})!')
    if d.get("style"): parts.append(f'style: DoseStyle(rawValue: {_swift_str(d["style"])})!')
    if d.get("modifier"): parts.append(f'modifier: DoseModifier(rawValue: {_swift_str(d["modifier"])})!')
    return f'.structured(StructuredDose({", ".join(parts)}))'

def gen_migration(keys):
    for k in keys:
        print(f'        {_swift_str(k)}: {_swift_dose(DOSE[k])},')


if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("usage: inject_dose.py inject '<glob>' | gen-migration <lot>"); sys.exit(1)
    cmd = sys.argv[1]
    if cmd == "inject":
        run_inject(sys.argv[2])
    elif cmd == "gen-migration":
        lot = sys.argv[2] if len(sys.argv) > 2 else "all"
        if lot == "running":
            gen_migration(RUNNING_KEYS)
        else:
            gen_migration(list(DOSE.keys()))
    else:
        print(f"commande inconnue: {cmd}"); sys.exit(1)
