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
# Lots livrés : yoga (Lot 1, 2026-06-14) · running (Lot 2) · cycling (Lot 3) · swimming (Lot 4, 2026-06-15).

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

CYCLING = {
    # ====================== LOT 3 — CYCLING ======================
    # Repeat mécanique du running : durées/distances/intervalles, pas de conflit reps-héros.
    # Seules les clés NOUVELLES sont déclarées ici (yoga+running couvrent déjà 30 sec, 10, 45 sec…).
    #
    # --- DURATIONS : minutes pleines ---
    "33 min": S("33", "minutes"),
    "45 min": S("45", "minutes"),
    "47 min": S("47", "minutes"),
    "64 min": S("64", "minutes"),
    "68 min": S("68", "minutes"),
    "72 min": S("72", "minutes"),
    "77 min": S("77", "minutes"),
    "80 min": S("80", "minutes"),
    "85 min": S("85", "minutes"),
    "90 min": S("90", "minutes"),
    "95 min": S("95", "minutes"),
    "100 min": S("100", "minutes"),
    "110 min": S("110", "minutes"),
    "120 min": S("120", "minutes"),
    "125 min": S("125", "minutes"),
    "135 min": S("135", "minutes"),
    "140 min": S("140", "minutes"),
    "145 min": S("145", "minutes"),
    "150 min": S("150", "minutes"),
    "153 min": S("153", "minutes"),
    "155 min": S("155", "minutes"),
    "160 min": S("160", "minutes"),
    "170 min": S("170", "minutes"),
    "180 min": S("180", "minutes"),
    "190 min": S("190", "minutes"),
    "195 min": S("195", "minutes"),
    "200 min": S("200", "minutes"),
    "210 min": S("210", "minutes"),
    "220 min": S("220", "minutes"),
    "225 min": S("225", "minutes"),
    "230 min": S("230", "minutes"),
    "235 min": S("235", "minutes"),
    "250 min": S("250", "minutes"),
    "255 min": S("255", "minutes"),
    "265 min": S("265", "minutes"),
    "270 min": S("270", "minutes"),
    "290 min": S("290", "minutes"),
    "300 min": S("300", "minutes"),
    # --- DURATIONS : plages / approximatif (value String garde « ~ » et la plage) ---
    "300-330 min": S("300-330", "minutes"),
    "~150 min": S("~150", "minutes"),
    "~65 min": S("~65", "minutes"),
    # --- DURATIONS : glose d'intensité redondante DROPPÉE (target_zone=Sweet-Spot la porte,
    #     + nom d'exo « Allure soutenue ») → plain minutes, cohérent avec le drop running des « (RPE 8) » ---
    "5 min tempo soutenu": S("5", "minutes"),
    "8 min tempo soutenu": S("8", "minutes"),
    "10 min tempo soutenu": S("10", "minutes"),
    "12 min tempo soutenu": S("12", "minutes"),
    "15 min tempo soutenu": S("15", "minutes"),
    "20 min tempo soutenu": S("20", "minutes"),
    # --- DURATIONS/REPS structuré avec qualificateur (renfo de fin de sortie) ---
    "25 sec par côté": S("25", "seconds", qualifier="perSide"),
    "60 sec par jambe": S("60", "seconds", qualifier="perLeg"),
    "40 sec par position": S("40", "seconds", qualifier="perPosition"),
    "6-8": S("6-8", "reps"),
    # --- DURATIONS : distance + glose temps estimé -> freeText (km/min universels : fr=en=es) ---
    "25 km / ~55 min": F("25 km / ~55 min", "25 km / ~55 min", "25 km / ~55 min"),
    "25 km / ~60 min": F("25 km / ~60 min", "25 km / ~60 min", "25 km / ~60 min"),
    "28 km / ~55 min": F("28 km / ~55 min", "28 km / ~55 min", "28 km / ~55 min"),
    "28 km / ~65 min": F("28 km / ~65 min", "28 km / ~65 min", "28 km / ~65 min"),
    "30 km / ~70 min": F("30 km / ~70 min", "30 km / ~70 min", "30 km / ~70 min"),
    "32 km / ~75 min": F("32 km / ~75 min", "32 km / ~75 min", "32 km / ~75 min"),
    "35 km / ~70 min": F("35 km / ~70 min", "35 km / ~70 min", "35 km / ~70 min"),
    "35 km / ~80 min": F("35 km / ~80 min", "35 km / ~80 min", "35 km / ~80 min"),
    "40 km / ~85 min": F("40 km / ~85 min", "40 km / ~85 min", "40 km / ~85 min"),
    "45 km / ~95 min": F("45 km / ~95 min", "45 km / ~95 min", "45 km / ~95 min"),
    "50 km / ~105 min": F("50 km / ~105 min", "50 km / ~105 min", "50 km / ~105 min"),
    "52 km / ~108 min": F("52 km / ~108 min", "52 km / ~108 min", "52 km / ~108 min"),
    "60 km / ~125 min": F("60 km / ~125 min", "60 km / ~125 min", "60 km / ~125 min"),
    "62 km / ~110 min": F("62 km / ~110 min", "62 km / ~110 min", "62 km / ~110 min"),
    "62 km / ~130 min": F("62 km / ~130 min", "62 km / ~130 min", "62 km / ~130 min"),
    "65 km / ~115 min": F("65 km / ~115 min", "65 km / ~115 min", "65 km / ~115 min"),
    "65 km / ~135 min": F("65 km / ~135 min", "65 km / ~135 min", "65 km / ~135 min"),
    "72 km / ~150 min": F("72 km / ~150 min", "72 km / ~150 min", "72 km / ~150 min"),
    "78 km / ~165 min": F("78 km / ~165 min", "78 km / ~165 min", "78 km / ~165 min"),
    "80 km / ~180 min": F("80 km / ~180 min", "80 km / ~180 min", "80 km / ~180 min"),
    "82 km / ~175 min": F("82 km / ~175 min", "82 km / ~175 min", "82 km / ~175 min"),
    # --- DURATIONS : descriptif/terrain/cadence -> freeText (mots à traduire : D+, montée, endurance…) ---
    "180-220 km / 3000+ m D+": F("180-220 km / 3000+ m D+", "180-220 km / 3000+ m elevation gain", "180-220 km / 3000+ m de desnivel"),
    "2 min en montée": F("2 min en montée", "2 min uphill", "2 min en subida"),
    "2 min à 100-105 rpm": F("2 min à 100-105 rpm", "2 min at 100-105 rpm", "2 min a 100-105 rpm"),
    "3 min à 100-105 rpm en endurance facile": F("3 min à 100-105 rpm en endurance facile", "3 min at 100-105 rpm, easy endurance", "3 min a 100-105 rpm, resistencia fácil"),
    "3 min à 95-100 rpm + 3 min à 85 rpm": F("3 min à 95-100 rpm + 3 min à 85 rpm", "3 min at 95-100 rpm + 3 min at 85 rpm", "3 min a 95-100 rpm + 3 min a 85 rpm"),
    "8 min tempo + 5 min endurance facile récupération": F("8 min tempo + 5 min d'endurance facile en récupération", "8 min tempo + 5 min easy recovery", "8 min tempo + 5 min de recuperación fácil"),
    "8 par côté + 30 sec planche dorsale": F("8 par côté + 30 s de planche dorsale", "8 per side + 30 s reverse plank", "8 por lado + 30 s de plancha invertida"),
    "Journée entière": F("Journée entière", "Full day", "Jornada completa"),
}

SWIMMING = {
    # ====================== LOT 4 — SWIMMING ======================
    # Repeat mécanique : distance (mètres) dominante. Seules les clés NOUVELLES ici.
    # DOCTRINE : glose d'intensité/allure/« continu » SANS nage spécifiée DROPPÉE → distance nue
    # (intensité portée par target_zone EN1/2/3·SP1/2/3·CSS·REC, rendue en sensation par le
    # pipeline zones passe #1 ; cohérent avec passe #1 « cacher le code coach »). Dès qu'une NAGE
    # (crawl/dos), un ÉDUCATIF, une RÉCUP explicite, du matériel ou un offset d'allure précis
    # apparaît → freeText traduit (lossless : la nage n'est PAS dans le nom).
    #
    # --- DISTANCES pures (mètres) ---
    "25 m": S("25", "meters"),
    "50 m": S("50", "meters"),
    "75 m": S("75", "meters"),
    "100 m": S("100", "meters"),
    "150 m": S("150", "meters"),
    "175 m": S("175", "meters"),
    "200 m": S("200", "meters"),
    "250 m": S("250", "meters"),
    "300 m": S("300", "meters"),
    "500 m": S("500", "meters"),
    "1200 m": S("1200", "meters"),
    "1300 m": S("1300", "meters"),
    "1500 m": S("1500", "meters"),
    "1800 m": S("1800", "meters"),
    "2000 m": S("2000", "meters"),
    "2200 m": S("2200", "meters"),
    "2300 m": S("2300", "meters"),
    "2400 m": S("2400", "meters"),
    "2500 m": S("2500", "meters"),
    "2600 m": S("2600", "meters"),
    "2700 m": S("2700", "meters"),
    "3000 m": S("3000", "meters"),
    "3200 m": S("3200", "meters"),
    "3300 m": S("3300", "meters"),
    # --- DISTANCE + glose intensité/allure/« continu » SANS nage → DROPPÉE (zone porte l'intensité) ---
    "100 m endurance haute": S("100", "meters"),     # EN3
    "150 m endurance haute": S("150", "meters"),     # EN3
    "200 m endurance haute": S("200", "meters"),     # EN3
    "50 m rapide": S("50", "meters"),                # SP1
    "25 m très rapide": S("25", "meters"),           # SP2
    "25 m sprint vitesse max": S("25", "meters"),    # SP3
    "25 m vitesse libre 80-90%": S("25", "meters"),  # SP2
    "400 m à allure régulière": S("400", "meters"),  # EN2
    "1000 m à allure régulière": S("1000", "meters"),# EN1
    "500 m à allure seuil pace": S("500", "meters"), # CSS pace (sans offset chiffré)
    "400 m continu": S("400", "meters"),
    "500 m continu": S("500", "meters"),
    "600 m continu": S("600", "meters"),
    "700 m continu": S("700", "meters"),
    "800 m continu": S("800", "meters"),
    "1000 m continu": S("1000", "meters"),
    "1300 m continu": S("1300", "meters"),
    # --- REPS renfo à sec (gate sport empêche tout conflit muscu reps-héros) ---
    "10 reps": S("10", "reps"),
    "12 reps": S("12", "reps"),
    "14": S("14", "reps"),
    "12 par bras": S("12", "reps", qualifier="perArm"),
    "14 par côté": S("14", "reps", qualifier="perSide"),
    "12 reps par côté": S("12", "reps", qualifier="perSide"),
    "15 reps par côté": S("15", "reps", qualifier="perSide"),
    "10 par lettre": S("10", "reps", qualifier="perLetter"),
    "12 par lettre": S("12", "reps", qualifier="perLetter"),
    "10 reps par lettre": S("10", "reps", qualifier="perLetter"),
    "12 reps par lettre": S("12", "reps", qualifier="perLetter"),
    "8 par lettre (Y, T, W)": S("8", "reps", qualifier="perLetter"),  # glose (Y,T,W) dans le nom → droppée
    # --- FREETEXT : nage spécifiée / éducatif / récup explicite / matériel / offset allure / composite ---
    "25 m crawl lent": F("25 m crawl lent", "25 m easy freestyle", "25 m crol suave"),
    "200 m crawl lent": F("200 m crawl lent", "200 m easy freestyle", "200 m crol suave"),
    "200 m crawl endurance facile": F("200 m crawl, endurance facile", "200 m freestyle, easy endurance", "200 m crol, resistencia fácil"),
    "100 m dos crawl très lent": F("100 m dos très lent", "100 m very easy backstroke", "100 m espalda muy suave"),
    "150 m dos lent": F("150 m dos lent", "150 m easy backstroke", "150 m espalda suave"),
    "200 m dos lent": F("200 m dos lent", "200 m easy backstroke", "200 m espalda suave"),
    "100 m crawl lent compteur cycles": F("100 m crawl lent, comptage des cycles", "100 m easy freestyle, stroke count", "100 m crol suave, conteo de brazadas"),
    "150 m crawl lent compteur cycles": F("150 m crawl lent, comptage des cycles", "150 m easy freestyle, stroke count", "150 m crol suave, conteo de brazadas"),
    "100 m crawl + 20 s récup": F("100 m crawl + 20 s de récup", "100 m freestyle + 20 s rest", "100 m crol + 20 s de descanso"),
    "100 m crawl bilatérale 1/3 + 25 s récup": F("100 m crawl, respiration bilatérale 1/3 + 25 s de récup", "100 m freestyle, bilateral breathing 1/3 + 25 s rest", "100 m crol, respiración bilateral 1/3 + 25 s de descanso"),
    "100 m crawl endurance haute + 45 s récup": F("100 m crawl, endurance haute + 45 s de récup", "100 m freestyle, high endurance + 45 s rest", "100 m crol, resistencia alta + 45 s de descanso"),
    "100 m crawl endurance soutenue + 20 s récup": F("100 m crawl, endurance soutenue + 20 s de récup", "100 m freestyle, sustained endurance + 20 s rest", "100 m crol, resistencia sostenida + 20 s de descanso"),
    "100 m crawl endurance soutenue + 25 s récup": F("100 m crawl, endurance soutenue + 25 s de récup", "100 m freestyle, sustained endurance + 25 s rest", "100 m crol, resistencia sostenida + 25 s de descanso"),
    "200 m crawl endurance facile récup 60 s": F("200 m crawl, endurance facile, récup 60 s", "200 m freestyle, easy endurance, 60 s rest", "200 m crol, resistencia fácil, 60 s de descanso"),
    "50 m crawl avec pull-buoy entre les jambes + 20 s récup": F("50 m crawl avec pull-buoy + 20 s de récup", "50 m freestyle with pull-buoy + 20 s rest", "50 m crol con pull-buoy + 20 s de descanso"),
    "100 m à allure seuil+3s/100m": F("100 m à allure seuil + 3 s/100 m", "100 m at threshold pace + 3 s/100 m", "100 m a ritmo umbral + 3 s/100 m"),
    "100 m à allure seuil+5s/100m": F("100 m à allure seuil + 5 s/100 m", "100 m at threshold pace + 5 s/100 m", "100 m a ritmo umbral + 5 s/100 m"),
    "200 m à allure seuil+2s/100m": F("200 m à allure seuil + 2 s/100 m", "200 m at threshold pace + 2 s/100 m", "200 m a ritmo umbral + 2 s/100 m"),
    "1 poussée + glisse 5 m": F("1 poussée au mur + glisse 5 m", "1 wall push-off + 5 m glide", "1 impulso en la pared + 5 m de deslizamiento"),
    "1 poussée + glisse 8 m": F("1 poussée au mur + glisse 8 m", "1 wall push-off + 8 m glide", "1 impulso en la pared + 8 m de deslizamiento"),
    "1 poussée + glisse max": F("1 poussée au mur + glisse maximale", "1 wall push-off + max glide", "1 impulso en la pared + deslizamiento máximo"),
    "10 m glissé apnée": F("10 m en glisse, apnée", "10 m glide, breath-hold", "10 m de deslizamiento, en apnea"),
    "10 sec expiration": F("10 s d'expiration", "10 s exhale", "10 s de exhalación"),
    "10 sec flottaison + 5 m glisse": F("10 s de flottaison + 5 m de glisse", "10 s float + 5 m glide", "10 s de flotación + 5 m de deslizamiento"),
    "15 m avancée": F("15 m de godille vers l'avant", "15 m sculling forward", "15 m de godella hacia adelante"),
    "10 cycles lents": F("10 cycles lents", "10 slow cycles", "10 ciclos lentos"),
    "25 m côté favori": F("25 m côté favori", "25 m favourite side", "25 m lado favorito"),
    "25 m (alterner côté favori et côté faible)": F("25 m (alterner côté favori et côté faible)", "25 m (alternate favourite and weak side)", "25 m (alternar lado favorito y lado débil)"),
    "25 m (alterner côtés)": F("25 m (alterner les côtés)", "25 m (alternate sides)", "25 m (alternar lados)"),
    "25 m bras tendus devant figures-8 lentes (pull-buoy entre les jambes)": F("25 m bras tendus devant, figures en 8 lentes (pull-buoy)", "25 m arms extended forward, slow figure-8s (pull-buoy)", "25 m brazos extendidos al frente, ochos lentos (pull-buoy)"),
    "25 m drill + 25 m crawl endurance facile (50 m total par série)": F("25 m éducatif + 25 m crawl facile (50 m par série)", "25 m drill + 25 m easy freestyle (50 m per set)", "25 m de técnica + 25 m crol suave (50 m por serie)"),
    "50 m rapide, récup 90 s entre 50 m, récup 4 min entre séries de 4": F("50 m rapide, récup 90 s entre les 50 m, récup 4 min entre les séries de 4", "50 m fast, 90 s rest between 50 m, 4 min rest between sets of 4", "50 m rápido, 90 s de descanso entre los 50 m, 4 min entre series de 4"),
    "3500 m continu OU 30 × 100 m à allure seuil récup 10 s (3000 m qualité)": F("3500 m en continu OU 30 × 100 m à allure seuil, récup 10 s (3000 m qualité)", "3500 m continuous OR 30 × 100 m at threshold pace, 10 s rest (3000 m quality)", "3500 m continuo O 30 × 100 m a ritmo umbral, 10 s de descanso (3000 m de calidad)"),
    "Auto-évaluation post-séance": F("Auto-évaluation post-séance", "Post-session self-assessment", "Autoevaluación post-sesión"),
}

# Table complète (union) + clés par lot (pour gen-migration ciblé sans toucher aux lots précédents).
DOSE = {**YOGA, **RUNNING, **CYCLING, **SWIMMING}
RUNNING_KEYS = list(RUNNING.keys())
CYCLING_KEYS = list(CYCLING.keys())
SWIMMING_KEYS = list(SWIMMING.keys())


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
        elif lot == "cycling":
            gen_migration(CYCLING_KEYS)
        elif lot == "swimming":
            gen_migration(SWIMMING_KEYS)
        else:
            gen_migration(list(DOSE.keys()))
    else:
        print(f"commande inconnue: {cmd}"); sys.exit(1)
