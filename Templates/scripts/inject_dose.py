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

def seg(value, unit, activity=None):
    d = {"value": value, "unit": unit}
    if activity:
        d["activity"] = activity
    return d

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
    "4 min finishing semaine allégée": S("4", "minutes"),
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
    "8 min tempo + 5 min endurance facile récupération": F("8 min tempo + 5 min d'endurance facile en récupération", "8 min tempo + 5 min easy recovery", "8 min tempo + 5 min de recuperacióneración fácil"),
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

HIKING = {
    # ====================== LOT 5 — HIKING ======================
    # DOCTRINE rando : marche/D+/sac/montée+descente = composites NON exprimables en structuré
    # (terrain, dénivelé D+, charge sac, gradient, RPE inline) -> freeText traduit fidèlement
    # (lossless). « RPE »/« tempo »/« endurance » = vocabulaire volontaire gardé tel quel (3 langues).
    # « D+ » (dénivelé positif, notation FR) -> « elevation gain »/« desnivel » en EN/ES (pas une
    # fuite : le concept est traduit). Renfo (reps/secondes par série/jambe/lettre/côté) = structuré.
    # Heures (sorties longues) : FR garde la convention « 4 h » / « 4 h 30 » (espaces), EN/ES
    # collent « 4h » / « 4h30 » (« 4 h 30 » est une convention FR qui lit mal hors-FR — décision
    # Sophie 2026-06-16). Toujours freeText universel, aucune fuite (chiffres + « h »).
    "4 h": F("4 h", "4h", "4h"),
    "4 h 30": F("4 h 30", "4h30", "4h30"),
    "6 h": F("6 h", "6h", "6h"),
    "6 h 30": F("6 h 30", "6h30", "6h30"),
    "7 h": F("7 h", "7h", "7h"),
    "7 h 30": F("7 h 30", "7h30", "7h30"),
    "8 h": F("8 h", "8h", "8h"),
    "8 h 30": F("8 h 30", "8h30", "8h30"),
    "9 h": F("9 h", "9h", "9h"),
    "9 h 30": F("9 h 30", "9h30", "9h30"),
    "10 h": F("10 h", "10h", "10h"),
    "11 h": F("11 h", "11h", "11h"),
    # --- MINUTES nues -> structuré ---
    "240 min": S("240", "minutes"),
    "275 min": S("275", "minutes"),
    "330 min": S("330", "minutes"),
    "360 min": S("360", "minutes"),
    "390 min": S("390", "minutes"),
    # --- MARCHE / D+ / SAC : composite freeText traduit ---
    "60 min marche / D+ 100 m / sac 8 kg": F("60 min de marche / D+ 100 m / sac 8 kg", "60 min walk / 100 m elevation gain / 8 kg pack", "60 min de caminata / 100 m de desnivel / mochila 8 kg"),
    "70 min marche / D+ 180 m / sac 5 kg": F("70 min de marche / D+ 180 m / sac 5 kg", "70 min walk / 180 m elevation gain / 5 kg pack", "70 min de caminata / 180 m de desnivel / mochila 5 kg"),
    "75 min marche / D+ 150 m / sac 4 kg": F("75 min de marche / D+ 150 m / sac 4 kg", "75 min walk / 150 m elevation gain / 4 kg pack", "75 min de caminata / 150 m de desnivel / mochila 4 kg"),
    "85 min marche / D+ 200 m / sac 5 kg": F("85 min de marche / D+ 200 m / sac 5 kg", "85 min walk / 200 m elevation gain / 5 kg pack", "85 min de caminata / 200 m de desnivel / mochila 5 kg"),
    "90 min marche / D+ 250 m / sac 6 kg": F("90 min de marche / D+ 250 m / sac 6 kg", "90 min walk / 250 m elevation gain / 6 kg pack", "90 min de caminata / 250 m de desnivel / mochila 6 kg"),
    "100 min marche / D+ 280 m / sac 6 kg": F("100 min de marche / D+ 280 m / sac 6 kg", "100 min walk / 280 m elevation gain / 6 kg pack", "100 min de caminata / 280 m de desnivel / mochila 6 kg"),
    "100 min marche / D+ 300 m / sac 5 kg": F("100 min de marche / D+ 300 m / sac 5 kg", "100 min walk / 300 m elevation gain / 5 kg pack", "100 min de caminata / 300 m de desnivel / mochila 5 kg"),
    "105 min marche / D+ 250 m / sac 4 kg": F("105 min de marche / D+ 250 m / sac 4 kg", "105 min walk / 250 m elevation gain / 4 kg pack", "105 min de caminata / 250 m de desnivel / mochila 4 kg"),
    "110 min marche / D+ 320 m / sac 7 kg": F("110 min de marche / D+ 320 m / sac 7 kg", "110 min walk / 320 m elevation gain / 7 kg pack", "110 min de caminata / 320 m de desnivel / mochila 7 kg"),
    "120 min marche / D+ 350 m / sac 7 kg": F("120 min de marche / D+ 350 m / sac 7 kg", "120 min walk / 350 m elevation gain / 7 kg pack", "120 min de caminata / 350 m de desnivel / mochila 7 kg"),
    "130 min marche / D+ 350 m / sac 5 kg": F("130 min de marche / D+ 350 m / sac 5 kg", "130 min walk / 350 m elevation gain / 5 kg pack", "130 min de caminata / 350 m de desnivel / mochila 5 kg"),
    "130 min marche / D+ 380 m / sac 8 kg": F("130 min de marche / D+ 380 m / sac 8 kg", "130 min walk / 380 m elevation gain / 8 kg pack", "130 min de caminata / 380 m de desnivel / mochila 8 kg"),
    "150 min marche / D+ 450 m / sac 6 kg": F("150 min de marche / D+ 450 m / sac 6 kg", "150 min walk / 450 m elevation gain / 6 kg pack", "150 min de caminata / 450 m de desnivel / mochila 6 kg"),
    "160 min marche / D+ 530 m / sac 6 kg": F("160 min de marche / D+ 530 m / sac 6 kg", "160 min walk / 530 m elevation gain / 6 kg pack", "160 min de caminata / 530 m de desnivel / mochila 6 kg"),
    "180 min marche / D+ 570 m / sac 6 kg": F("180 min de marche / D+ 570 m / sac 6 kg", "180 min walk / 570 m elevation gain / 6 kg pack", "180 min de caminata / 570 m de desnivel / mochila 6 kg"),
    "200 min marche / D+ 680 m / sac 7 kg": F("200 min de marche / D+ 680 m / sac 7 kg", "200 min walk / 680 m elevation gain / 7 kg pack", "200 min de caminata / 680 m de desnivel / mochila 7 kg"),
    "220 min marche / D+ 850 m / sac 7 kg": F("220 min de marche / D+ 850 m / sac 7 kg", "220 min walk / 850 m elevation gain / 7 kg pack", "220 min de caminata / 850 m de desnivel / mochila 7 kg"),
    "240 min marche / D+ 950 m / sac 8 kg": F("240 min de marche / D+ 950 m / sac 8 kg", "240 min walk / 950 m elevation gain / 8 kg pack", "240 min de caminata / 950 m de desnivel / mochila 8 kg"),
    "5 h marche / D+ 1000 m / sac 8 kg": F("5 h de marche / D+ 1000 m / sac 8 kg", "5 h walk / 1000 m elevation gain / 8 kg pack", "5 h de caminata / 1000 m de desnivel / mochila 8 kg"),
    # --- « X min total dont Y m D+ cumulé » -> freeText ---
    "45 min total dont 200 m D+ cumulé": F("45 min au total dont 200 m D+ cumulé", "45 min total incl. 200 m cumulative elevation gain", "45 min en total con 200 m de desnivel acumulado"),
    "50 min total dont 250 m D+ cumulé": F("50 min au total dont 250 m D+ cumulé", "50 min total incl. 250 m cumulative elevation gain", "50 min en total con 250 m de desnivel acumulado"),
    "60 min total dont 280 m D+ cumulé": F("60 min au total dont 280 m D+ cumulé", "60 min total incl. 280 m cumulative elevation gain", "60 min en total con 280 m de desnivel acumulado"),
    "70 min total dont 350 m D+ cumulé": F("70 min au total dont 350 m D+ cumulé", "70 min total incl. 350 m cumulative elevation gain", "70 min en total con 350 m de desnivel acumulado"),
    "75 min total dont 400 m D+ cumulé": F("75 min au total dont 400 m D+ cumulé", "75 min total incl. 400 m cumulative elevation gain", "75 min en total con 400 m de desnivel acumulado"),
    "105 min total dont 550 m D+ cumulé": F("105 min au total dont 550 m D+ cumulé", "105 min total incl. 550 m cumulative elevation gain", "105 min en total con 550 m de desnivel acumulado"),
    "120 min total dont 500 m D+ cumulé": F("120 min au total dont 500 m D+ cumulé", "120 min total incl. 500 m cumulative elevation gain", "120 min en total con 500 m de desnivel acumulado"),
    "90 min total dont 500 m D+ cumulé": F("90 min au total dont 500 m D+ cumulé", "90 min total incl. 500 m cumulative elevation gain", "90 min en total con 500 m de desnivel acumulado"),
    # --- MONTÉE tempo continue (gradient/sac) -> freeText ---
    "30 min montée continue tempo sac 7 kg": F("30 min de montée continue tempo, sac 7 kg", "30 min steady tempo climb, 7 kg pack", "30 min de subida continua tempo, mochila 7 kg"),
    "40 min montée continue tempo sac 7 kg": F("40 min de montée continue tempo, sac 7 kg", "40 min steady tempo climb, 7 kg pack", "40 min de subida continua tempo, mochila 7 kg"),
    "45 min montée continue tempo sac 8 kg": F("45 min de montée continue tempo, sac 8 kg", "45 min steady tempo climb, 8 kg pack", "45 min de subida continua tempo, mochila 8 kg"),
    "25 min montée tempo gradient 8-10% sac 12 kg": F("25 min de montée tempo, pente 8-10 %, sac 12 kg", "25 min tempo climb, 8-10% grade, 12 kg pack", "25 min de subida tempo, pendiente 8-10 %, mochila 12 kg"),
    "40 min montée tempo gradient 10% sac 15 kg": F("40 min de montée tempo, pente 10 %, sac 15 kg", "40 min tempo climb, 10% grade, 15 kg pack", "40 min de subida tempo, pendiente 10 %, mochila 15 kg"),
    "50 min montée tempo gradient 10% sac 14 kg": F("50 min de montée tempo, pente 10 %, sac 14 kg", "50 min tempo climb, 10% grade, 14 kg pack", "50 min de subida tempo, pendiente 10 %, mochila 14 kg"),
    "50 min montée tempo gradient 10% sac 17 kg": F("50 min de montée tempo, pente 10 %, sac 17 kg", "50 min tempo climb, 10% grade, 17 kg pack", "50 min de subida tempo, pendiente 10 %, mochila 17 kg"),
    "60 min montée tempo gradient 10-12% sac 13 kg": F("60 min de montée tempo, pente 10-12 %, sac 13 kg", "60 min tempo climb, 10-12% grade, 13 kg pack", "60 min de subida tempo, pendiente 10-12 %, mochila 13 kg"),
    "70 min montée tempo gradient 10-15% sac 14 kg": F("70 min de montée tempo, pente 10-15 %, sac 14 kg", "70 min tempo climb, 10-15% grade, 14 kg pack", "70 min de subida tempo, pendiente 10-15 %, mochila 14 kg"),
    "75 min montée tempo gradient 10-15% sac 15 kg": F("75 min de montée tempo, pente 10-15 %, sac 15 kg", "75 min tempo climb, 10-15% grade, 15 kg pack", "75 min de subida tempo, pendiente 10-15 %, mochila 15 kg"),
    "75 min montée tempo gradient 10-15% sac 18 kg": F("75 min de montée tempo, pente 10-15 %, sac 18 kg", "75 min tempo climb, 10-15% grade, 18 kg pack", "75 min de subida tempo, pendiente 10-15 %, mochila 18 kg"),
    "75 min montée tempo gradient 10-15% sac 20 kg": F("75 min de montée tempo, pente 10-15 %, sac 20 kg", "75 min tempo climb, 10-15% grade, 20 kg pack", "75 min de subida tempo, pendiente 10-15 %, mochila 20 kg"),
    "80 min montée tempo gradient 10-15% sac 16 kg": F("80 min de montée tempo, pente 10-15 %, sac 16 kg", "80 min tempo climb, 10-15% grade, 16 kg pack", "80 min de subida tempo, pendiente 10-15 %, mochila 16 kg"),
    "90 min montée tempo gradient 10-15% sac 18 kg": F("90 min de montée tempo, pente 10-15 %, sac 18 kg", "90 min tempo climb, 10-15% grade, 18 kg pack", "90 min de subida tempo, pendiente 10-15 %, mochila 18 kg"),
    "20 min montée gradient 5-8% endurance facile à tempo": F("20 min de montée, pente 5-8 %, endurance facile à tempo", "20 min climb, 5-8% grade, easy endurance to tempo", "20 min de subida, pendiente 5-8 %, resistencia suave a tempo"),
    # --- DESCENTE / MARCHE plate -> freeText ---
    "15 min descente technique": F("15 min de descente technique", "15 min technical downhill", "15 min de bajada técnica"),
    "20 min descente": F("20 min de descente", "20 min downhill", "20 min de bajada"),
    "30 min marche plate très facile": F("30 min de marche plate très facile", "30 min flat walk, very easy", "30 min de caminata llana muy fácil"),
    # --- INTERVALLES montée/descente (RPE/gradient/sac inline) -> freeText fidèle ---
    "4 min montée RPE 6 + 3 min descente très facile": F("4 min de montée RPE 6 + 3 min de descente très facile", "4 min uphill RPE 6 + 3 min very easy downhill", "4 min de subida RPE 6 + 3 min de bajada muy fácil"),
    "5 min montée RPE 5-6 + 4 min descente très facile": F("5 min de montée RPE 5-6 + 4 min de descente très facile", "5 min uphill RPE 5-6 + 4 min very easy downhill", "5 min de subida RPE 5-6 + 4 min de bajada muy fácil"),
    "5 min montée RPE 6-7 + 4 min récup descente très facile": F("5 min de montée RPE 6-7 + 4 min de récup en descente très facile", "5 min uphill RPE 6-7 + 4 min recovery on very easy downhill", "5 min de subida RPE 6-7 + 4 min de recuperacióneración en bajada muy fácil"),
    "6 min montée RPE 6-7 + 4 min récup descente très facile": F("6 min de montée RPE 6-7 + 4 min de récup en descente très facile", "6 min uphill RPE 6-7 + 4 min recovery on very easy downhill", "6 min de subida RPE 6-7 + 4 min de recuperacióneración en bajada muy fácil"),
    "8 min montée RPE 6-7 + 5 min récup descente très facile": F("8 min de montée RPE 6-7 + 5 min de récup en descente très facile", "8 min uphill RPE 6-7 + 5 min recovery on very easy downhill", "8 min de subida RPE 6-7 + 5 min de recuperacióneración en bajada muy fácil"),
    "5 min descente technique + 3 min remontée très facile": F("5 min de descente technique + 3 min de remontée très facile", "5 min technical downhill + 3 min very easy climb back", "5 min de bajada técnica + 3 min de resubida muy fácil"),
    "10 min montée RPE 8-9 gradient 15% sac 17 kg + 8 min descente très facile": F("10 min de montée RPE 8-9, pente 15 %, sac 17 kg + 8 min de descente très facile", "10 min uphill RPE 8-9, 15% grade, 17 kg pack + 8 min very easy downhill", "10 min de subida RPE 8-9, pendiente 15 %, mochila 17 kg + 8 min de bajada muy fácil"),
    "10 min montée RPE 8-9 gradient 15-18% sac 15 kg + 7 min descente très facile": F("10 min de montée RPE 8-9, pente 15-18 %, sac 15 kg + 7 min de descente très facile", "10 min uphill RPE 8-9, 15-18% grade, 15 kg pack + 7 min very easy downhill", "10 min de subida RPE 8-9, pendiente 15-18 %, mochila 15 kg + 7 min de bajada muy fácil"),
    "10 min montée RPE 8-9 gradient 15-20% sac 20 kg + 8 min descente très facile": F("10 min de montée RPE 8-9, pente 15-20 %, sac 20 kg + 8 min de descente très facile", "10 min uphill RPE 8-9, 15-20% grade, 20 kg pack + 8 min very easy downhill", "10 min de subida RPE 8-9, pendiente 15-20 %, mochila 20 kg + 8 min de bajada muy fácil"),
    "8 min montée RPE 8-9 gradient 15-18% sac 15 kg + 8 min descente très facile récup": F("8 min de montée RPE 8-9, pente 15-18 %, sac 15 kg + 8 min de descente très facile en récup", "8 min uphill RPE 8-9, 15-18% grade, 15 kg pack + 8 min very easy downhill recovery", "8 min de subida RPE 8-9, pendiente 15-18 %, mochila 15 kg + 8 min de bajada muy fácil en recuperación"),
    "6 min montée tempo gradient 8-12% + 4 min descente très facile récup": F("6 min de montée tempo, pente 8-12 % + 4 min de descente très facile en récup", "6 min tempo climb, 8-12% grade + 4 min very easy downhill recovery", "6 min de subida tempo, pendiente 8-12 % + 4 min de bajada muy fácil en recuperación"),
    "6 min montée tempo gradient 8-12% sac 11 kg + 4 min descente très facile": F("6 min de montée tempo, pente 8-12 %, sac 11 kg + 4 min de descente très facile", "6 min tempo climb, 8-12% grade, 11 kg pack + 4 min very easy downhill", "6 min de subida tempo, pendiente 8-12 %, mochila 11 kg + 4 min de bajada muy fácil"),
    "8 min montée tempo gradient 8-12% sac 11 kg + 5 min descente très facile": F("8 min de montée tempo, pente 8-12 %, sac 11 kg + 5 min de descente très facile", "8 min tempo climb, 8-12% grade, 11 kg pack + 5 min very easy downhill", "8 min de subida tempo, pendiente 8-12 %, mochila 11 kg + 5 min de bajada muy fácil"),
    "8 min montée tempo gradient 10-12% sac 12 kg + 5 min descente très facile": F("8 min de montée tempo, pente 10-12 %, sac 12 kg + 5 min de descente très facile", "8 min tempo climb, 10-12% grade, 12 kg pack + 5 min very easy downhill", "8 min de subida tempo, pendiente 10-12 %, mochila 12 kg + 5 min de bajada muy fácil"),
    "8 min montée tempo gradient 10-12% sac 13 kg + 5 min descente très facile": F("8 min de montée tempo, pente 10-12 %, sac 13 kg + 5 min de descente très facile", "8 min tempo climb, 10-12% grade, 13 kg pack + 5 min very easy downhill", "8 min de subida tempo, pendiente 10-12 %, mochila 13 kg + 5 min de bajada muy fácil"),
    # --- RENFO (reps/secondes) -> structuré ---
    "16": S("16", "reps"),
    "18": S("18", "reps"),
    "5 par série": S("5", "reps", "perSet"),
    "6 par série": S("6", "reps", "perSet"),
    "8 par série": S("8", "reps", "perSet"),
    "10 par série": S("10", "reps", "perSet"),
    "12 par série": S("12", "reps", "perSet"),
    "8 par lettre": S("8", "reps", "perLetter"),
    "14 par jambe": S("14", "reps", "perLeg"),
    "8-10 par jambe": S("8-10", "reps", "perLeg"),
    "30 sec par jambe": S("30", "seconds", "perLeg"),
    "35 sec par jambe": S("35", "seconds", "perLeg"),
    "40 sec par jambe": S("40", "seconds", "perLeg"),
    "40 sec par côté": S("40", "seconds", "perSide"),
    "10 lifts par côté": S("10", "reps", "perSide"),
    # --- RENFO composites -> freeText ---
    "12 par côté + 60 sec planche": F("12 par côté + 60 s de planche", "12 per side + 60 s plank", "12 por lado + 60 s de plancha"),
    "60 sec planche + 12 Pallof/côté": F("60 s de planche + 12 Pallof par côté", "60 s plank + 12 Pallof per side", "60 s de plancha + 12 Pallof por lado"),
    "60 sec planche + 45 sec/côté": F("60 s de planche + 45 s par côté", "60 s plank + 45 s per side", "60 s de plancha + 45 s por lado"),
}

HIIT = {
    # ====================== LOT 6 — HIIT ======================
    # DOCTRINE HIIT : intervalle work/rest = Dose.interval (DoseActivity work/rest, extension pilote-
    # sport, party). « X min par round » = structuré perRound. Secondes/reps nues = structuré.
    # Composites de gainage/renfo (planche + side plank + dead bug, calf+tibialis…) = freeText : les
    # noms d'exos internationaux de salle (dead bug, bird dog, hollow, V-ups, Pallof, copenhagen,
    # Nordic, split squat, hip thrust, farmer carry, sled, face pull, scapular, tibialis, calf) sont
    # GARDÉS tels quels (anglicismes dominants en salle, 3 langues — cf. swimming crawl/pull-buoy) ;
    # seuls les mots de structure (planche/ventrale/latérale, /côté, /jambe, genoux, sec…) sont traduits.
    # --- INTERVALLES work/rest -> Dose.interval ---
    "20 sec work + 10 sec rest": I(seg("20", "seconds", "work"), seg("10", "seconds", "rest")),
    "30 sec work + 30 sec rest": I(seg("30", "seconds", "work"), seg("30", "seconds", "rest")),
    "30 sec work + 60 sec rest": I(seg("30", "seconds", "work"), seg("60", "seconds", "rest")),
    "40 sec work + 20 sec rest": I(seg("40", "seconds", "work"), seg("20", "seconds", "rest")),
    # --- PAR ROUND / SECONDES / REPS nues -> structuré ---
    "1 min par round": S("1", "minutes", "perRound"),
    "1 min par round (work + repos auto-régulé)": F("1 min par round (effort + repos auto-géré)", "1 min per round (work + self-paced rest)", "1 min por ronda (trabajo + descanso autorregulado)"),
    "10 min par bloc": F("10 min par bloc", "10 min per block", "10 min por bloque"),
    "120 sec": S("120", "seconds"),
    "180 sec": S("180", "seconds"),
    "240 sec": S("240", "seconds"),
    "300 sec": S("300", "seconds"),
    "3": S("3", "reps"),
    "4": S("4", "reps"),
    "3 par côté": S("3", "reps", "perSide"),
    "10 par bras": S("10", "reps", "perArm"),
    "5 par bras": S("5", "reps", "perArm"),
    # --- PRE-SÉANCE ---
    "1 min lecture avant séance": F("1 min de lecture avant la séance", "1 min reading before the session", "1 min de lectura antes de la sesión"),
    # --- CARRIES / SLED -> freeText ---
    "20 m par push": F("20 m par poussée", "20 m per push", "20 m por empuje"),
    "20 m sled + 20 m farmer carry": F("20 m de sled + 20 m de farmer carry", "20 m sled + 20 m farmer carry", "20 m de sled + 20 m de farmer carry"),
    # --- RENFO membres (calf/tibialis/scapular/Y) -> freeText (noms gardés, /jambe traduit) ---
    "12 calf/jambe + 15 tibialis/jambe": F("12 calf raises par jambe + 15 tibialis raises par jambe", "12 calf raises per leg + 15 tibialis raises per leg", "12 calf raises por pierna + 15 tibialis raises por pierna"),
    "12 calf/jambe + 15 tibialis/jambe + 12 scapular": F("12 calf raises par jambe + 15 tibialis raises par jambe + 12 scapular pull-ups", "12 calf raises per leg + 15 tibialis raises per leg + 12 scapular pull-ups", "12 calf raises por pierna + 15 tibialis raises por pierna + 12 scapular pull-ups"),
    "15 calf/jambe + 18 tibialis/jambe": F("15 calf raises par jambe + 18 tibialis raises par jambe", "15 calf raises per leg + 18 tibialis raises per leg", "15 calf raises por pierna + 18 tibialis raises por pierna"),
    "12 scapular + 12 Y-raise": F("12 scapular pull-ups + 12 Y-raise", "12 scapular pull-ups + 12 Y-raise", "12 scapular pull-ups + 12 Y-raise"),
    "12 Y + 12 face pull": F("12 Y + 12 face pull", "12 Y + 12 face pull", "12 Y + 12 face pull"),
    "15 tibialis + 12 scapular pull-up": F("15 tibialis raises + 12 scapular pull-ups", "15 tibialis raises + 12 scapular pull-ups", "15 tibialis raises + 12 scapular pull-ups"),
    "12 squat + 8 push-up genoux": F("12 squats + 8 push-up sur genoux", "12 squats + 8 knee push-ups", "12 squats + 8 push-up de rodillas"),
    # --- GAINAGE composites (planche/ventrale/latérale + dead bug/bird dog/hollow/V-ups) -> freeText ---
    "30 sec dead bug + 30 sec bird dog": F("30 s de dead bug + 30 s de bird dog", "30 s dead bug + 30 s bird dog", "30 s de dead bug + 30 s de bird dog"),
    "30 sec hollow + 30 sec V-ups": F("30 s de hollow + 30 s de V-ups", "30 s hollow + 30 s V-ups", "30 s de hollow + 30 s de V-ups"),
    "30 sec hollow rocks + 30 sec V-ups": F("30 s de hollow rocks + 30 s de V-ups", "30 s hollow rocks + 30 s V-ups", "30 s de hollow rocks + 30 s de V-ups"),
    "30 sec hollow rocks + 30 sec dead bug": F("30 s de hollow rocks + 30 s de dead bug", "30 s hollow rocks + 30 s dead bug", "30 s de hollow rocks + 30 s de dead bug"),
    "30 sec ventrale + 20 sec latérale/côté": F("30 s de planche ventrale + 20 s de planche latérale par côté", "30 s front plank + 20 s side plank per side", "30 s de plancha frontal + 20 s de plancha lateral por lado"),
    "45 sec ventrale + 30 sec latérale/côté": F("45 s de planche ventrale + 30 s de planche latérale par côté", "45 s front plank + 30 s side plank per side", "45 s de plancha frontal + 30 s de plancha lateral por lado"),
    "60 sec ventrale + 30 sec latérale/côté": F("60 s de planche ventrale + 30 s de planche latérale par côté", "60 s front plank + 30 s side plank per side", "60 s de plancha frontal + 30 s de plancha lateral por lado"),
    "60 sec ventrale + 45 sec latérale/côté": F("60 s de planche ventrale + 45 s de planche latérale par côté", "60 s front plank + 45 s side plank per side", "60 s de plancha frontal + 45 s de plancha lateral por lado"),
    "45 sec planche + 30 sec dead bug + 30 sec bird dog": F("45 s de planche + 30 s de dead bug + 30 s de bird dog", "45 s plank + 30 s dead bug + 30 s bird dog", "45 s de plancha + 30 s de dead bug + 30 s de bird dog"),
    "45 sec planche + 30 sec dead bug/côté": F("45 s de planche + 30 s de dead bug par côté", "45 s plank + 30 s dead bug per side", "45 s de plancha + 30 s de dead bug por lado"),
    "45 sec planche + 30 sec side plank/côté": F("45 s de planche + 30 s de planche latérale par côté", "45 s plank + 30 s side plank per side", "45 s de plancha + 30 s de plancha lateral por lado"),
    "45 sec planche + 30 sec side/côté + 30 sec dead bug": F("45 s de planche + 30 s de planche latérale par côté + 30 s de dead bug", "45 s plank + 30 s side plank per side + 30 s dead bug", "45 s de plancha + 30 s de plancha lateral por lado + 30 s de dead bug"),
    "50 sec planche + 30 sec side plank/côté": F("50 s de planche + 30 s de planche latérale par côté", "50 s plank + 30 s side plank per side", "50 s de plancha + 30 s de plancha lateral por lado"),
    "60 sec planche + 30 sec dead bug/côté": F("60 s de planche + 30 s de dead bug par côté", "60 s plank + 30 s dead bug per side", "60 s de plancha + 30 s de dead bug por lado"),
    "60 sec planche + 30 sec side/côté": F("60 s de planche + 30 s de planche latérale par côté", "60 s plank + 30 s side plank per side", "60 s de plancha + 30 s de plancha lateral por lado"),
    "60 sec planche + 35 sec side plank/côté": F("60 s de planche + 35 s de planche latérale par côté", "60 s plank + 35 s side plank per side", "60 s de plancha + 35 s de plancha lateral por lado"),
    "60 sec planche + 40 sec side plank/côté": F("60 s de planche + 40 s de planche latérale par côté", "60 s plank + 40 s side plank per side", "60 s de plancha + 40 s de plancha lateral por lado"),
    "75 sec planche + 30 sec dead bug/côté": F("75 s de planche + 30 s de dead bug par côté", "75 s plank + 30 s dead bug per side", "75 s de plancha + 30 s de dead bug por lado"),
    "75 sec planche + 45 sec side/côté": F("75 s de planche + 45 s de planche latérale par côté", "75 s plank + 45 s side plank per side", "75 s de plancha + 45 s de plancha lateral por lado"),
    "75 sec planche + 45 sec side/côté + 12 dead bug/côté": F("75 s de planche + 45 s de planche latérale par côté + 12 dead bug par côté", "75 s plank + 45 s side plank per side + 12 dead bug per side", "75 s de plancha + 45 s de plancha lateral por lado + 12 dead bug por lado"),
    "90 sec planche + 30 sec dead bug/côté": F("90 s de planche + 30 s de dead bug par côté", "90 s plank + 30 s dead bug per side", "90 s de plancha + 30 s de dead bug por lado"),
    "90 sec planche + 45 sec side/côté + 15 dead bug/côté": F("90 s de planche + 45 s de planche latérale par côté + 15 dead bug par côté", "90 s plank + 45 s side plank per side + 15 dead bug per side", "90 s de plancha + 45 s de plancha lateral por lado + 15 dead bug por lado"),
    "15 reps tibialis + 60 sec planche + 30 sec side/côté": F("15 tibialis raises + 60 s de planche + 30 s de planche latérale par côté", "15 tibialis raises + 60 s plank + 30 s side plank per side", "15 tibialis raises + 60 s de plancha + 30 s de plancha lateral por lado"),
    "15 tibialis/jambe + 60 sec planche": F("15 tibialis raises par jambe + 60 s de planche", "15 tibialis raises per leg + 60 s plank", "15 tibialis raises por pierna + 60 s de plancha"),
    "15 tibialis/jambe + 60 sec planche + 30 sec side/côté": F("15 tibialis raises par jambe + 60 s de planche + 30 s de planche latérale par côté", "15 tibialis raises per leg + 60 s plank + 30 s side plank per side", "15 tibialis raises por pierna + 60 s de plancha + 30 s de plancha lateral por lado"),
    "10 hip thrust + 30 sec copenhagen/côté": F("10 hip thrust + 30 s de Copenhagen par côté", "10 hip thrust + 30 s Copenhagen per side", "10 hip thrust + 30 s de Copenhagen por lado"),
    "5 Nordic + 8 split squat/jambe DB 12 kg": F("5 Nordic + 8 split squat par jambe, haltères 12 kg", "5 Nordic + 8 split squat per leg, 12 kg dumbbells", "5 Nordic + 8 split squat por pierna, mancuernas 12 kg"),
    "5 Nordic + 8 split squat/jambe DB 14 kg": F("5 Nordic + 8 split squat par jambe, haltères 14 kg", "5 Nordic + 8 split squat per leg, 14 kg dumbbells", "5 Nordic + 8 split squat por pierna, mancuernas 14 kg"),
}

STRENGTH = {
    # ====================== LOT 7 — STRENGTH (muscu) ======================
    # Passe DÉDIÉE (interaction party muscu reps-héros/côté) : les reps muscu restent
    # le HÉROS de l'affichage Minuté (chiffre = value, latéralité = qualifier rendus
    # séparément par la vue) ; le DoseFormatter.string sert le chip metricsRow + l'overview.
    # NB : seules les 24 strings NEUVES sont ici — les bare reps / sec / sec par côté
    # déjà mappés par les lots précédents (« 12 », « 10 par côté », « 60 sec »…) restent
    # dans LEUR section (pas de doublon de clé dans le dict Swift de LegacyDoseMigration).
    # --- REPS (plages structurées) ---
    "8-10": S("8-10", "reps"),
    "8-12": S("8-12", "reps"),
    "10-12": S("10-12", "reps"),
    "10-15": S("10-15", "reps"),
    "12-15": S("12-15", "reps"),
    "6-10": S("6-10", "reps"),
    "4-5": S("4-5", "reps"),
    "3-5": S("3-5", "reps"),
    # --- REPS unilatérales structurées ---
    "8-10 par côté": S("8-10", "reps", qualifier="perSide"),
    "5 par épaule": S("5", "reps", qualifier="perShoulder"),
    # --- HOLDS exprimés dans le champ reps (→ secondes, le timer/bigTime fait foi) ---
    "75 sec": S("75", "seconds"),
    "50 sec par côté": S("50", "seconds", qualifier="perSide"),
    # --- SCHÉMAS par série / AMRAP / max → freeText (T2 : pas de gabarit value+unit) ---
    # Pur numérique : fr=en=es (aucun mot FR → aucune fuite), juste l'espacement normalisé.
    "5,6,8,8": F("5, 6, 8, 8", "5, 6, 8, 8", "5, 6, 8, 8"),
    "3,5,6,6": F("3, 5, 6, 6", "3, 5, 6, 6", "3, 5, 6, 6"),
    # AMRAP glosé (passe #3 « jargon affiché ») : FR « (max de reps) », ES « (máximo de reps) »,
    # EN non glosé (terme natif, EN hors-périmètre du filet jargon). Le neutre `reps` reste clé sans
    # glose ; la glose localisée vit dans le dose freeText (source unique). Corrige la fuite ES en FR/EN
    # introduite par l'édition manuelle passe #3 (resync pipeline dose+migration).
    "5, 5, 5, 5+ AMRAP": F("5, 5, 5, 5+ AMRAP (max de reps)", "5, 5, 5, 5+ AMRAP", "5, 5, 5, 5+ AMRAP (máximo de reps)"),
    "5, 3, 1+ AMRAP": F("5, 3, 1+ AMRAP (max de reps)", "5, 3, 1+ AMRAP", "5, 3, 1+ AMRAP (máximo de reps)"),
    "3, 3, 3, 3+ AMRAP": F("3, 3, 3, 3+ AMRAP (max de reps)", "3, 3, 3, 3+ AMRAP", "3, 3, 3, 3+ AMRAP (máximo de reps)"),
    "5,6,8,AMRAP": F("5, 6, 8, AMRAP (max de reps)", "5, 6, 8, AMRAP", "5, 6, 8, AMRAP (máximo de reps)"),
    "3,5,6,AMRAP": F("3, 5, 6, AMRAP (max de reps)", "3, 5, 6, AMRAP", "3, 5, 6, AMRAP (máximo de reps)"),
    "AMRAP 1 set": F("AMRAP (max de reps) — 1 série", "AMRAP — 1 set", "AMRAP (máximo de reps) — 1 serie"),
    "1 (3 attempts max)": F("1 (3 essais max)", "1 (3 attempts max)", "1 (3 intentos máx.)"),
    "max": F("max", "max", "máx."),
    "max propre": F("max propre", "clean max", "máx. limpias"),
    "8 de chaque exercice": F("8 de chaque exercice", "8 of each exercise", "8 de cada ejercicio"),
    "10 de chaque exercice": F("10 de chaque exercice", "10 of each exercise", "10 de cada ejercicio"),
}

TENNISFOOT = {
    # ====================== LOT 8 — TENNIS + FOOTBALL ======================
    # Sports de drill : comptages propres (services/passes/frappes/séquences) STRUCTURÉS
    # (unités serves/passes/strikes/sequences — décision Sophie 2026-06-15), intervalles
    # PLATS effort+récup STRUCTURÉS via Dose.interval (activités drill cross/jeu/pattern/
    # tie-break/long de ligne/sprint + récup/récup marche). Tout le reste — composites avec
    # sous-spec (« 5 T + 5 ext »), renfo de salle (vocab international gardé), intervalles
    # IMBRIQUÉS (« 8 × (… + …) » — 2 niveaux que le modèle interval 1-niveau n'exprime pas),
    # match/jeu effectif/heures — en freeText traduit (lossless). Intensité (RPE/au seuil/
    # ALL OUT) DROPPÉE (portée par target_zone, pipeline zones). NB : seules les clés NEUVES
    # sont ici (bare reps/sec/min + perSide/perLeg/perArm/perLetter déjà mappés par les lots
    # précédents → pas de doublon de clé dans le dict Swift de LegacyDoseMigration).

    # --- DURÉE simple neuve ---
    "13 min": S("13", "minutes"),

    # --- REPS structurées (bare + plages neuves) ---
    "22": S("22", "reps"),
    "5 reps": S("5", "reps"),
    "15 reps": S("15", "reps"),
    "8 répétitions": S("8", "reps"),
    "6-8 reps": S("6-8", "reps"),
    "8-10 reps": S("8-10", "reps"),
    "8-12 reps": S("8-12", "reps"),

    # --- REPS unilatérales structurées ---
    "5 par côté": S("5", "reps", qualifier="perSide"),
    "6 par côté": S("6", "reps", qualifier="perSide"),
    "5 reps par jambe": S("5", "reps", qualifier="perLeg"),
    "8 reps par jambe": S("8", "reps", qualifier="perLeg"),
    "10 reps par jambe": S("10", "reps", qualifier="perLeg"),
    "8 / jambe": S("8", "reps", qualifier="perLeg"),
    "8/jambe": S("8", "reps", qualifier="perLeg"),
    "10 / jambe": S("10", "reps", qualifier="perLeg"),
    "5-8 par jambe": S("5-8", "reps", qualifier="perLeg"),
    "8-10/jambe": S("8-10", "reps", qualifier="perLeg"),
    "10-15 par jambe": S("10-15", "reps", qualifier="perLeg"),
    "8-10 reps par jambe": S("8-10", "reps", qualifier="perLeg"),
    "10-15 reps par jambe": S("10-15", "reps", qualifier="perLeg"),
    "12-15 reps par jambe": S("12-15", "reps", qualifier="perLeg"),
    "8 / pied": S("8", "reps", qualifier="perFoot"),
    "15 par bras": S("15", "reps", qualifier="perArm"),
    "15 par lettre": S("15", "reps", qualifier="perLetter"),
    "30 sec / jambe": S("30", "seconds", qualifier="perLeg"),

    # --- COMPTAGES SPORT structurés (services / séquences / passes / frappes) ---
    "6 services": S("6", "serves"),
    "8 services": S("8", "serves"),
    "10 services": S("10", "serves"),
    "12 services": S("12", "serves"),
    "15 services": S("15", "serves"),
    "6 services par série": S("6", "serves", qualifier="perSet"),
    "8 services par série": S("8", "serves", qualifier="perSet"),
    "10 services par série": S("10", "serves", qualifier="perSet"),
    "12 services par série": S("12", "serves", qualifier="perSet"),
    "15 services par série": S("15", "serves", qualifier="perSet"),
    "8 séquences": S("8", "sequences"),
    "10 séquences": S("10", "sequences"),
    "8 passes": S("8", "passes"),
    "10 passes": S("10", "passes"),
    "8 passes par pied": S("8", "passes", qualifier="perFoot"),
    "15 passes par pied": S("15", "passes", qualifier="perFoot"),
    "8 frappes": S("8", "strikes"),
    "10 frappes": S("10", "strikes"),
    "6 frappes par pied": S("6", "strikes", qualifier="perFoot"),
    "8 frappes par pied": S("8", "strikes", qualifier="perFoot"),
    "10 frappes par pied": S("10", "strikes", qualifier="perFoot"),
    "15 frappes par pied": S("15", "strikes", qualifier="perFoot"),

    # --- INTERVALLES PLATS effort+récup (Dose.interval) ---
    # Tennis — cross
    "3 min cross + 90 sec récup": I(seg("3", "minutes", "crossCourt"), seg("90", "seconds", "rest")),
    "4 min cross + 90 sec récup": I(seg("4", "minutes", "crossCourt"), seg("90", "seconds", "rest")),
    "5 min cross + 90 sec récup": I(seg("5", "minutes", "crossCourt"), seg("90", "seconds", "rest")),
    "6 min cross + 90 sec récup": I(seg("6", "minutes", "crossCourt"), seg("90", "seconds", "rest")),
    "5 min cross + 75 sec récup": I(seg("5", "minutes", "crossCourt"), seg("75", "seconds", "rest")),
    "5 min cross + 2 min récup": I(seg("5", "minutes", "crossCourt"), seg("2", "minutes", "rest")),
    "5 min cross + 90 sec récup marche": I(seg("5", "minutes", "crossCourt"), seg("90", "seconds", "walkingRecovery")),
    "4 min cross + 2 min récup marche": I(seg("4", "minutes", "crossCourt"), seg("2", "minutes", "walkingRecovery")),
    "5 min cross + 2 min récup marche": I(seg("5", "minutes", "crossCourt"), seg("2", "minutes", "walkingRecovery")),
    "6 min cross + 2 min récup marche": I(seg("6", "minutes", "crossCourt"), seg("2", "minutes", "walkingRecovery")),
    # Tennis — séquence
    "5 min séquence + 90 sec récup": I(seg("5", "minutes", "sequenceDrill"), seg("90", "seconds", "rest")),
    "6 min séquence + 90 sec récup": I(seg("6", "minutes", "sequenceDrill"), seg("90", "seconds", "rest")),
    # Tennis — pattern
    "4 min pattern + 90 sec récup": I(seg("4", "minutes", "patternDrill"), seg("90", "seconds", "rest")),
    "5 min pattern + 90 sec récup": I(seg("5", "minutes", "patternDrill"), seg("90", "seconds", "rest")),
    # Tennis — long de ligne
    "5 min long de ligne + 90 sec récup": I(seg("5", "minutes", "downTheLine"), seg("90", "seconds", "rest")),
    "4 min long de ligne + 2 min récup marche": I(seg("4", "minutes", "downTheLine"), seg("2", "minutes", "walkingRecovery")),
    # Tennis — jeu
    "8 min jeu + 2 min récup": I(seg("8", "minutes", "game"), seg("2", "minutes", "rest")),
    "8 min jeu + 3 min récup": I(seg("8", "minutes", "game"), seg("3", "minutes", "rest")),
    "6 min jeu + 3 min récup": I(seg("6", "minutes", "game"), seg("3", "minutes", "rest")),
    # Tennis — tie-break
    "10 min tie-break + 3 min récup": I(seg("10", "minutes", "tieBreak"), seg("3", "minutes", "rest")),
    # Tennis — frappes minutées
    "2 min frappes + 1 min récup marche": I(seg("2", "minutes", "strikesDrill"), seg("1", "minutes", "walkingRecovery")),
    "5 min frappes + 2 min récup marche": I(seg("5", "minutes", "strikesDrill"), seg("2", "minutes", "walkingRecovery")),
    "6 min frappes + 2 min récup marche": I(seg("6", "minutes", "strikesDrill"), seg("2", "minutes", "walkingRecovery")),
    # Tennis — frappes comptées (segment sans activité)
    "15 frappes + 1 min récup marche": I(seg("15", "strikes"), seg("1", "minutes", "walkingRecovery")),
    "20 frappes + 1 min récup marche": I(seg("20", "strikes"), seg("1", "minutes", "walkingRecovery")),
    "30 frappes + 1 min récup marche": I(seg("30", "strikes"), seg("1", "minutes", "walkingRecovery")),
    "50 frappes + 90 sec récup marche": I(seg("50", "strikes"), seg("90", "seconds", "walkingRecovery")),
    # Tennis — sprint (temps)
    "30 sec sprint + 90 sec récup": I(seg("30", "seconds", "sprint"), seg("90", "seconds", "rest")),
    "45 sec sprint + 90 sec récup": I(seg("45", "seconds", "sprint"), seg("90", "seconds", "rest")),
    "45 sec sprint + 90 sec récup marche": I(seg("45", "seconds", "sprint"), seg("90", "seconds", "walkingRecovery")),
    "60 sec sprint + 90 sec récup": I(seg("60", "seconds", "sprint"), seg("90", "seconds", "rest")),
    "60 sec sprint + 90 sec récup marche": I(seg("60", "seconds", "sprint"), seg("90", "seconds", "walkingRecovery")),
    "60 sec sprint + 120 sec récup marche": I(seg("60", "seconds", "sprint"), seg("120", "seconds", "walkingRecovery")),
    # Tennis — sprint (distance)
    "15 m sprint + 30 sec récup": I(seg("15", "meters", "sprint"), seg("30", "seconds", "rest")),
    "15 m sprint + 30 sec récup marche": I(seg("15", "meters", "sprint"), seg("30", "seconds", "walkingRecovery")),
    "20 m sprint + 30 sec récup": I(seg("20", "meters", "sprint"), seg("30", "seconds", "rest")),
    "20 m sprint + 30 sec récup marche": I(seg("20", "meters", "sprint"), seg("30", "seconds", "walkingRecovery")),
    "15-20 m sprint + 30 sec récup marche": I(seg("15-20", "meters", "sprint"), seg("30", "seconds", "walkingRecovery")),
    "1 sprint 15 m": I(seg("15", "meters", "sprint")),
    "1 sprint 20 m + 40 sec récup": I(seg("20", "meters", "sprint"), seg("40", "seconds", "rest")),
    # Tennis — effort nu + récup (segment sans activité)
    "4 min + 90 sec récup": I(seg("4", "minutes"), seg("90", "seconds", "rest")),
    "5 min + 90 sec récup": I(seg("5", "minutes"), seg("90", "seconds", "rest")),
    "6 min + 90 sec récup": I(seg("6", "minutes"), seg("90", "seconds", "rest")),
    "5 min + 90 sec récup marche": I(seg("5", "minutes"), seg("90", "seconds", "walkingRecovery")),
    "45 sec + 120 sec récup marche": I(seg("45", "seconds"), seg("120", "seconds", "walkingRecovery")),
    # Football — ON/OFF
    "3 min ON + 2 min OFF": I(seg("3", "minutes", "work"), seg("2", "minutes", "rest")),
    "3-4 min ON / 2 min OFF": I(seg("3-4", "minutes", "work"), seg("2", "minutes", "rest")),
    "4-5 min ON / 2 min OFF": I(seg("4-5", "minutes", "work"), seg("2", "minutes", "rest")),
    "5-6 min ON / 2 min OFF": I(seg("5-6", "minutes", "work"), seg("2", "minutes", "rest")),
    # Football — jeu
    "5 min jeu + 90 sec récup": I(seg("5", "minutes", "game"), seg("90", "seconds", "rest")),
    "5 min jeu + 90 sec récup marche": I(seg("5", "minutes", "game"), seg("90", "seconds", "walkingRecovery")),
    "6 min jeu + 90 sec récup": I(seg("6", "minutes", "game"), seg("90", "seconds", "rest")),
    "6 min jeu + 90 sec récup marche": I(seg("6", "minutes", "game"), seg("90", "seconds", "walkingRecovery")),
    "6 min jeu + 2 min récup": I(seg("6", "minutes", "game"), seg("2", "minutes", "rest")),
    "6 min jeu + 2 min récup marche": I(seg("6", "minutes", "game"), seg("2", "minutes", "walkingRecovery")),
    "6 min jeu + 3 min récup marche": I(seg("6", "minutes", "game"), seg("3", "minutes", "walkingRecovery")),
    "4 min jeu + 2 min récup marche": I(seg("4", "minutes", "game"), seg("2", "minutes", "walkingRecovery")),
    "8 min jeu + 3 min récup marche": I(seg("8", "minutes", "game"), seg("3", "minutes", "walkingRecovery")),
    # Football — course/marche (intensité Z3-Z4/modérée DROPPÉE, portée par target_zone)
    "30 sec course Z3-Z4 + 30 sec marche": I(seg("30", "seconds", "running"), seg("30", "seconds", "walking")),
    "30 sec course modérée + 30 sec marche": I(seg("30", "seconds", "running"), seg("30", "seconds", "walking")),

    # --- INTERVALLES IMBRIQUÉS (2 niveaux) → freeText (modèle interval = 1 niveau) ---
    "8 × (30s course tempo à au seuil + 30s marche)": F("8 × (30 s de course au seuil + 30 s de marche)", "8 × (30 s threshold run + 30 s walk)", "8 × (30 s de carrera a umbral + 30 s de caminata)"),
    "10 cycles x 30 sec course au seuil / 30 sec marche": F("10 cycles × (30 s de course au seuil / 30 s de marche)", "10 cycles × (30 s threshold run / 30 s walk)", "10 ciclos × (30 s de carrera a umbral / 30 s de caminata)"),
    "12 cycles x 15 sec course au seuil / 15 sec marche": F("12 cycles × (15 s de course au seuil / 15 s de marche)", "12 cycles × (15 s threshold run / 15 s walk)", "12 ciclos × (15 s de carrera a umbral / 15 s de caminata)"),
    "8 x 30 m sprint / recup 25 sec entre reps": F("8 × (30 m sprint + 25 s de récup entre reps)", "8 × (30 m sprint + 25 s rest between reps)", "8 × (30 m sprint + 25 s de recuperación entre reps)"),
    "6 x 30 m sprint / recup 25 sec entre reps": F("6 × (30 m sprint + 25 s de récup entre reps)", "6 × (30 m sprint + 25 s rest between reps)", "6 × (30 m sprint + 25 s de recuperación entre reps)"),
    "10 x 30 m sprint / recup 25 sec entre reps": F("10 × (30 m sprint + 25 s de récup entre reps)", "10 × (30 m sprint + 25 s rest between reps)", "10 × (30 m sprint + 25 s de recuperación entre reps)"),
    "6 x 25 m sprint / recup 25 sec": F("6 × (25 m sprint + 25 s de récup)", "6 × (25 m sprint + 25 s rest)", "6 × (25 m sprint + 25 s de recuperación)"),
    "6 × (30 m sprint + 25 sec récup marche)": F("6 × (30 m sprint + 25 s de récup en marchant)", "6 × (30 m sprint + 25 s walking recovery)", "6 × (30 m sprint + 25 s de recuperacióneración caminando)"),
    "6 × (30 m sprint ALL OUT + 25 sec récup marche)": F("6 × (30 m sprint + 25 s de récup en marchant)", "6 × (30 m sprint + 25 s walking recovery)", "6 × (30 m sprint + 25 s de recuperacióneración caminando)"),
    "8 × 30s ON / 30s OFF + 3 min récup entre séries": F("8 × (30 s d'effort / 30 s de récup) + 3 min de récup entre séries", "8 × (30 s work / 30 s rest) + 3 min rest between sets", "8 × (30 s de trabajo / 30 s de descanso) + 3 min de descanso entre series"),
    "5 strides x 30 m progressive 80-90 pct": F("5 lignes droites × 30 m en accélération progressive (80-90 %)", "5 strides × 30 m progressive (80-90%)", "5 rectas × 30 m en aceleración progresiva (80-90%)"),
    "6 stations × 30 sec + 15 sec transition": F("6 stations × 30 s + 15 s de transition", "6 stations × 30 s + 15 s transition", "6 estaciones × 30 s + 15 s de transición"),
    "6 stations 30 sec + 20 sec récup": F("6 stations × 30 s + 20 s de récup", "6 stations × 30 s + 20 s rest", "6 estaciones × 30 s + 20 s de recuperación"),
    "1 set 6 jeux + 5 min récup entre sets": F("1 set de 6 jeux + 5 min de récup entre sets", "1 set of 6 games + 5 min rest between sets", "1 set de 6 juegos + 5 min de recuperación entre sets"),
    "1 série + 2 min récup marche": F("1 série + 2 min de récup en marchant", "1 set + 2 min walking recovery", "1 serie + 2 min de recuperacióneración caminando"),
    "1 série de 11 points + 2 min récup": F("1 série de 11 points + 2 min de récup", "1 set of 11 points + 2 min rest", "1 serie de 11 puntos + 2 min de recuperación"),
    "1 tie-break 4 points + 2 min récup": F("1 tie-break en 4 points + 2 min de récup", "1 tie-break to 4 points + 2 min rest", "1 tie-break a 4 puntos + 2 min de recuperación"),

    # --- PASSAGES / ALLERS-RETOURS / PATTERNS / ENCHAÎNEMENTS → freeText ---
    "1 passage A/R": F("1 aller-retour", "1 round trip", "1 ida y vuelta"),
    "1 passage A/R chaque": F("1 aller-retour chacun", "1 round trip each", "1 ida y vuelta cada uno"),
    "1 passage A/R chaque pattern": F("1 aller-retour par pattern", "1 round trip per pattern", "1 ida y vuelta por patrón"),
    "1 passage A/R lent": F("1 aller-retour lent", "1 slow round trip", "1 ida y vuelta lenta"),
    "1 passage A/R par pattern": F("1 aller-retour par pattern", "1 round trip per pattern", "1 ida y vuelta por patrón"),
    "1 passage in-out": F("1 passage in-out", "1 in-out run", "1 pasada in-out"),
    "1 passage chronométré + 1 retour libre": F("1 passage chronométré + 1 retour libre", "1 timed run + 1 free return", "1 pasada cronometrada + 1 vuelta libre"),
    "1 passage chronométré aller + 1 retour libre": F("1 passage chronométré à l'aller + 1 retour libre", "1 timed run out + 1 free return", "1 pasada cronometrada de ida + 1 vuelta libre"),
    "1 passage de chaque": F("1 passage de chaque", "1 run of each", "1 pasada de cada"),
    "1 passage de chaque pattern": F("1 passage de chaque pattern", "1 run of each pattern", "1 pasada de cada patrón"),
    "2 passages": F("2 passages", "2 runs", "2 pasadas"),
    "2 passages A/R": F("2 allers-retours", "2 round trips", "2 idas y vueltas"),
    "2 passages aller-retour": F("2 allers-retours", "2 round trips", "2 idas y vueltas"),
    "5 passages": F("5 passages", "5 runs", "5 pasadas"),
    "2 allers-retours": F("2 allers-retours", "2 round trips", "2 idas y vueltas"),
    "4 allers-retours 6 m": F("4 allers-retours de 6 m", "4 round trips of 6 m", "4 idas y vueltas de 6 m"),
    "3 allers-retours 8 m de chaque pattern": F("3 allers-retours de 8 m par pattern", "3 round trips of 8 m per pattern", "3 idas y vueltas de 8 m por patrón"),
    "20 m aller + récup retour marche 30 sec": F("20 m à l'aller + 30 s de récup en marchant au retour", "20 m out + 30 s walking recovery back", "20 m de ida + 30 s de recuperacióneración caminando a la vuelta"),
    "4 patterns": F("4 patterns", "4 patterns", "4 patrones"),
    "5 patterns": F("5 patterns", "5 patterns", "5 patrones"),
    "5 enchaînements": F("5 enchaînements", "5 combinations", "5 encadenamientos"),
    "6 enchaînements": F("6 enchaînements", "6 combinations", "6 encadenamientos"),
    "8 enchaînements": F("8 enchaînements", "8 combinations", "8 encadenamientos"),

    # --- DIVERS sport comptés → freeText ---
    "8 cycles": F("8 cycles", "8 cycles", "8 ciclos"),
    "20 impacts": F("20 impacts", "20 impacts", "20 impactos"),
    "10 lancers + 10 trophées": F("10 lancers + 10 positions trophée", "10 throws + 10 trophy positions", "10 lanzamientos + 10 posiciones trofeo"),
    "5 contacts cible": F("5 contacts cible", "5 target contacts", "5 contactos con diana"),
    "6 têtes": F("6 têtes", "6 headers", "6 cabezazos"),
    "10 contrôles par pied": F("10 contrôles par pied", "10 controls per foot", "10 controles por pie"),
    "20 + 5 sec hold haut x 3": F("20 reps + tenue 5 s en haut × 3", "20 reps + 5 s hold at top × 3", "20 reps + 5 s en tensión arriba × 3"),
    "15 reps + tenu 30 sec": F("15 reps + tenue 30 s", "15 reps + 30 s hold", "15 reps + 30 s de tensión"),

    # --- SERVICES composites (sous-spec) → freeText ---
    "10 services (3 normal + 7 break point pression)": F("10 services (3 normaux + 7 sous pression de balle de break)", "10 serves (3 normal + 7 break-point pressure)", "10 servicios (3 normales + 7 con presión de break)"),
    "10 services (3 plat + 3 slice + 4 kick)": F("10 services (3 à plat + 3 slicés + 4 kickés)", "10 serves (3 flat + 3 slice + 4 kick)", "10 servicios (3 planos + 3 cortados + 4 liftados)"),
    "10 services (5 1ère T + 5 2e kick)": F("10 services (5 premières au T + 5 secondes kickées)", "10 serves (5 first down the T + 5 second kick)", "10 servicios (5 primeros al centro + 5 segundos liftados)"),
    "10 services (5 T + 5 ext) + 5 kick": F("10 services (5 au T + 5 extérieurs) + 5 kickés", "10 serves (5 down the T + 5 wide) + 5 kick", "10 servicios (5 al centro + 5 abiertos) + 5 liftados"),
    "10 services (5 T + 5 extérieur)": F("10 services (5 au T + 5 extérieurs)", "10 serves (5 down the T + 5 wide)", "10 servicios (5 al centro + 5 abiertos)"),
    "20 services (10 plat + 10 slice ou kick)": F("20 services (10 à plat + 10 slicés ou kickés)", "20 serves (10 flat + 10 slice or kick)", "20 servicios (10 planos + 10 cortados o liftados)"),
    "12 services par carré": F("12 services par carré de service", "12 serves per service box", "12 servicios por cuadro de saque"),
    "8 services par carré": F("8 services par carré de service", "8 serves per service box", "8 servicios por cuadro de saque"),
    "8 services light": F("8 services en souplesse", "8 easy serves", "8 servicios suaves"),
    "8 services + 1er coup": F("8 services + 1er coup", "8 serves + first shot", "8 servicios + primer golpe"),
    "8 services + 2 coups": F("8 services + 2 coups", "8 serves + 2 shots", "8 servicios + 2 golpes"),

    # --- SÉQUENCES composites → freeText ---
    "8 séquences (1 volée FH + 1 volée BH + 1 smash)": F("8 séquences (1 volée de coup droit + 1 volée de revers + 1 smash)", "8 sequences (1 forehand volley + 1 backhand volley + 1 smash)", "8 secuencias (1 volea de derecha + 1 volea de revés + 1 smash)"),
    "10 séquences (5 break point + 5 balle de set)": F("10 séquences (5 balles de break + 5 balles de set)", "10 sequences (5 break points + 5 set points)", "10 secuencias (5 puntos de break + 5 puntos de set)"),
    "10 séquences (5 normal + 5 break point pression)": F("10 séquences (5 normales + 5 sous pression de break)", "10 sequences (5 normal + 5 break-point pressure)", "10 secuencias (5 normales + 5 con presión de break)"),
    "10 séquences (5 service + 5 retour pression)": F("10 séquences (5 au service + 5 en retour sous pression)", "10 sequences (5 serving + 5 returning under pressure)", "10 secuencias (5 al saque + 5 al resto con presión)"),
    "10 séquences (5 service + 5 retour)": F("10 séquences (5 au service + 5 en retour)", "10 sequences (5 serving + 5 returning)", "10 secuencias (5 al saque + 5 al resto)"),

    # --- FRAPPES composites → freeText ---
    "10 frappes (6 pied fort + 4 pied faible)": F("10 frappes (6 du pied fort + 4 du pied faible)", "10 shots (6 strong foot + 4 weak foot)", "10 golpes (6 con pie bueno + 4 con pie malo)"),
    "6 frappes (3 par pied)": F("6 frappes (3 par pied)", "6 shots (3 per foot)", "6 golpes (3 por pie)"),
    "8 frappes (4 par pied)": F("8 frappes (4 par pied)", "8 shots (4 per foot)", "8 golpes (4 por pie)"),
    "6 frappes pied alterné + 5 têtes": F("6 frappes en alternant les pieds + 5 têtes", "6 alternating-foot shots + 5 headers", "6 golpes alternando pie + 5 cabezazos"),
    "6 puissance + 6 placée par pied": F("6 en puissance + 6 placées par pied", "6 power + 6 placed per foot", "6 de potencia + 6 colocadas por pie"),
    "5 frappes + sprint filet": F("5 frappes + sprint au filet", "5 shots + sprint to the net", "5 golpes + sprint a la red"),
    "30 sec rapide + 30 sec marche": F("30 s rapide + 30 s de marche", "30 s fast + 30 s walk", "30 s rápido + 30 s de caminata"),

    # --- PASSES / CORNERS composites → freeText ---
    "20 passes par pied (40 total)": F("20 passes par pied (40 au total)", "20 passes per foot (40 total)", "20 pases por pie (40 en total)"),
    "5 corners + 5 coups francs": F("5 corners + 5 coups francs", "5 corners + 5 free kicks", "5 córners + 5 tiros libres"),
    "6 corners + 6 coups francs": F("6 corners + 6 coups francs", "6 corners + 6 free kicks", "6 córners + 6 tiros libres"),

    # --- RENFO de salle (vocab international gardé, structure traduite) → freeText ---
    "10 reps chaque": F("10 reps chacun", "10 reps each", "10 reps cada uno"),
    "12 reps chaque": F("12 reps chacun", "12 reps each", "12 reps cada uno"),
    "12 par mouvement": F("12 par mouvement", "12 per movement", "12 por movimiento"),
    "8-10 reps contrôlées": F("8-10 reps contrôlées", "8-10 controlled reps", "8-10 reps controladas"),
    "6 + 6 (3/côté)": F("6 + 6 (3 par côté)", "6 + 6 (3 per side)", "6 + 6 (3 por lado)"),
    "8 + 6/côté": F("8 + 6 par côté", "8 + 6 per side", "8 + 6 por lado"),
    "12 / 10 par côté": F("12 / 10 par côté", "12 / 10 per side", "12 / 10 por lado"),
    "12 / 10/côté / 30 sec/côté": F("12 / 10 par côté / 30 s par côté", "12 / 10 per side / 30 s per side", "12 / 10 por lado / 30 s por lado"),
    "10 par lettre / 10 par bras": F("10 par lettre / 10 par bras", "10 per letter / 10 per arm", "10 por letra / 10 por brazo"),
    "10 par lettre / 10 par bras / 10 reps": F("10 par lettre / 10 par bras / 10 reps", "10 per letter / 10 per arm / 10 reps", "10 por letra / 10 por brazo / 10 reps"),
    "12 par lettre / 12 par bras": F("12 par lettre / 12 par bras", "12 per letter / 12 per arm", "12 por letra / 12 por brazo"),
    "12 par bras / 12 reps": F("12 par bras / 12 reps", "12 per arm / 12 reps", "12 por brazo / 12 reps"),
    "10 par lettre + 8 scaption": F("10 par lettre + 8 scaption", "10 per letter + 8 scaption", "10 por letra + 8 scaption"),
    "12 par lettre + 10 scaption": F("12 par lettre + 10 scaption", "12 per letter + 10 scaption", "12 por letra + 10 scaption"),
    "12 Y-T-W + 12 ER": F("12 Y-T-W + 12 rotations externes", "12 Y-T-W + 12 external rotations", "12 Y-T-W + 12 rotaciones externas"),
    "12 Y-T-W + 12 ER + 10 Pallof/côté": F("12 Y-T-W + 12 rotations externes + 10 Pallof par côté", "12 Y-T-W + 12 external rotations + 10 Pallof per side", "12 Y-T-W + 12 rotaciones externas + 10 Pallof por lado"),
    "12 ER + 10 Pallof par côté": F("12 rotations externes + 10 Pallof par côté", "12 external rotations + 10 Pallof per side", "12 rotaciones externas + 10 Pallof por lado"),
    "10 Pallof + 12 bird-dog par côté": F("10 Pallof + 12 bird-dog par côté", "10 Pallof + 12 bird-dog per side", "10 Pallof + 12 bird-dog por lado"),
    "12 Pallof + 30 sec side plank par côté": F("12 Pallof + 30 s de planche latérale par côté", "12 Pallof + 30 s side plank per side", "12 Pallof + 30 s de plancha lateral por lado"),
    "12 Pallof / 10 bird-dog par côté": F("12 Pallof / 10 bird-dog par côté", "12 Pallof / 10 bird-dog per side", "12 Pallof / 10 bird-dog por lado"),
    "12 Pallof / 30 sec side plank par côté": F("12 Pallof / 30 s de planche latérale par côté", "12 Pallof / 30 s side plank per side", "12 Pallof / 30 s de plancha lateral por lado"),
    "12 Pallof / 10 bird-dog / 30 sec side plank par côté": F("12 Pallof / 10 bird-dog / 30 s de planche latérale par côté", "12 Pallof / 10 bird-dog / 30 s side plank per side", "12 Pallof / 10 bird-dog / 30 s de plancha lateral por lado"),
    "12 reps/cote Pallof + 30 sec side plank rotation/cote": F("12 Pallof par côté + 30 s de planche latérale avec rotation par côté", "12 Pallof per side + 30 s side plank rotation per side", "12 Pallof por lado + 30 s de plancha lateral con rotación por lado"),
    "10 hip thrust + 25 sec plank/côté": F("10 hip thrust + 25 s de planche par côté", "10 hip thrust + 25 s plank per side", "10 hip thrust + 25 s de plancha por lado"),
    "10 split squat + 12 hip thrust par jambe": F("10 split squat + 12 hip thrust par jambe", "10 split squat + 12 hip thrust per leg", "10 split squat + 12 hip thrust por pierna"),
    "8 split squat + 10 hip thrust par jambe": F("8 split squat + 10 hip thrust par jambe", "8 split squat + 10 hip thrust per leg", "8 split squat + 10 hip thrust por pierna"),
    "10 split squat / jambe + 10 hip thrust / jambe": F("10 split squat par jambe + 10 hip thrust par jambe", "10 split squat per leg + 10 hip thrust per leg", "10 split squat por pierna + 10 hip thrust por pierna"),
    "10 split squat / jambe + 8 hip thrust / jambe": F("10 split squat par jambe + 8 hip thrust par jambe", "10 split squat per leg + 8 hip thrust per leg", "10 split squat por pierna + 8 hip thrust por pierna"),
    "8 split squat / jambe + 8 hip thrust / jambe": F("8 split squat par jambe + 8 hip thrust par jambe", "8 split squat per leg + 8 hip thrust per leg", "8 split squat por pierna + 8 hip thrust por pierna"),
    "10 split squat / jambe + 10 Pallof/côté": F("10 split squat par jambe + 10 Pallof par côté", "10 split squat per leg + 10 Pallof per side", "10 split squat por pierna + 10 Pallof por lado"),
    "8 throws / côté + 8 split squat / jambe": F("8 lancers par côté + 8 split squat par jambe", "8 throws per side + 8 split squat per leg", "8 lanzamientos por lado + 8 split squat por pierna"),
    "8 rotational/côté + 6 overhead slam": F("8 rotational throw par côté + 6 overhead slam", "8 rotational throws per side + 6 overhead slam", "8 lanzamientos rotacionales por lado + 6 overhead slam"),
    "8 slam + 6 rotational/côté": F("8 slam + 6 rotational throw par côté", "8 slams + 6 rotational throws per side", "8 slams + 6 lanzamientos rotacionales por lado"),
    "12 bipodal + 6 unilatéral / jambe": F("12 sur deux jambes + 6 sur une jambe par jambe", "12 two-legged + 6 single-leg per leg", "12 bipodal + 6 a una pierna por pierna"),
    "15 bipodal + 6 unilatéral / jambe": F("15 sur deux jambes + 6 sur une jambe par jambe", "15 two-legged + 6 single-leg per leg", "15 bipodal + 6 a una pierna por pierna"),
    "12 bridge + 10 bird-dog / côté": F("12 bridge + 10 bird-dog par côté", "12 bridge + 10 bird-dog per side", "12 bridge + 10 bird-dog por lado"),
    "12 bridge + 8 bird-dog / côté": F("12 bridge + 8 bird-dog par côté", "12 bridge + 8 bird-dog per side", "12 bridge + 8 bird-dog por lado"),
    "30 sec / jambe + 12 glute bridge bipodal": F("30 s par jambe + 12 glute bridge sur deux jambes", "30 s per leg + 12 two-legged glute bridge", "30 s por pierna + 12 glute bridge bipodal"),
    "45 sec plank + 10 reps/cote bird-dog": F("45 s de planche + 10 bird-dog par côté", "45 s plank + 10 bird-dog per side", "45 s de plancha + 10 bird-dog por lado"),
    "30 sec plank + 20 sec side plank / côté": F("30 s de planche + 20 s de planche latérale par côté", "30 s plank + 20 s side plank per side", "30 s de plancha + 20 s de plancha lateral por lado"),
    "40 sec plank + 25 sec side plank / côté": F("40 s de planche + 25 s de planche latérale par côté", "40 s plank + 25 s side plank per side", "40 s de plancha + 25 s de plancha lateral por lado"),
    "45 sec plank + 30 sec side plank / côté": F("45 s de planche + 30 s de planche latérale par côté", "45 s plank + 30 s side plank per side", "45 s de plancha + 30 s de plancha lateral por lado"),
    "45 sec plank + 30 sec side plank / côté + 10 bird-dog / côté": F("45 s de planche + 30 s de planche latérale par côté + 10 bird-dog par côté", "45 s plank + 30 s side plank per side + 10 bird-dog per side", "45 s de plancha + 30 s de plancha lateral por lado + 10 bird-dog por lado"),
    "60 sec plank + 40 sec side plank / côté + 12 bird-dog / côté": F("60 s de planche + 40 s de planche latérale par côté + 12 bird-dog par côté", "60 s plank + 40 s side plank per side + 12 bird-dog per side", "60 s de plancha + 40 s de plancha lateral por lado + 12 bird-dog por lado"),
    "5 box jump + 5 lateral bound (3 droite + 2 gauche)": F("5 box jump + 5 lateral bound (3 à droite + 2 à gauche)", "5 box jump + 5 lateral bound (3 right + 2 left)", "5 box jump + 5 lateral bound (3 derecha + 2 izquierda)"),
    "5 box jumps + 5 lateral bounds/cote": F("5 box jump + 5 lateral bound par côté", "5 box jumps + 5 lateral bounds per side", "5 box jumps + 5 lateral bounds por lado"),
    "6 box jump + 6 lateral bound (3/côté)": F("6 box jump + 6 lateral bound (3 par côté)", "6 box jump + 6 lateral bound (3 per side)", "6 box jump + 6 lateral bound (3 por lado)"),
    "5 lateral bound/côté + 4 box jump": F("5 lateral bound par côté + 4 box jump", "5 lateral bound per side + 4 box jump", "5 lateral bound por lado + 4 box jump"),
    "6 lateral bound/côté + 5 box jump": F("6 lateral bound par côté + 5 box jump", "6 lateral bound per side + 5 box jump", "6 lateral bound por lado + 5 box jump"),
    "5/cote lateral + 5 broad jumps": F("5 sauts latéraux par côté + 5 sauts en longueur", "5 lateral jumps per side + 5 broad jumps", "5 saltos laterales por lado + 5 saltos de longitud"),
    "6 lateral par côté + 8 vertical": F("6 sauts latéraux par côté + 8 sauts verticaux", "6 lateral jumps per side + 8 vertical jumps", "6 saltos laterales por lado + 8 saltos verticales"),
    "8 vertical + 5 lateral par côté": F("8 sauts verticaux + 5 sauts latéraux par côté", "8 vertical jumps + 5 lateral jumps per side", "8 saltos verticales + 5 saltos laterales por lado"),

    # --- ÉQUILIBRE unipodal football (yeux ouverts/fermés) → freeText ---
    "30 sec / jambe yeux ouverts": F("30 s par jambe yeux ouverts", "30 s per leg eyes open", "30 s por pierna con ojos abiertos"),
    "30 sec / jambe yeux fermés": F("30 s par jambe yeux fermés", "30 s per leg eyes closed", "30 s por pierna con ojos cerrados"),
    "30 sec / jambe yeux fermés ou ballon": F("30 s par jambe yeux fermés ou avec ballon", "30 s per leg eyes closed or with ball", "30 s por pierna con ojos cerrados o con balón"),
    "30 sec par jambe (15 sec yeux ouverts + 15 sec yeux fermés)": F("30 s par jambe (15 s yeux ouverts + 15 s yeux fermés)", "30 s per leg (15 s eyes open + 15 s eyes closed)", "30 s por pierna (15 s ojos abiertos + 15 s ojos cerrados)"),
    "20 sec par jambe levée": F("20 s par jambe levée", "20 s per raised leg", "20 s por pierna elevada"),
    "25 sec par jambe levée": F("25 s par jambe levée", "25 s per raised leg", "25 s por pierna elevada"),
    "30 sec par jambe levée": F("30 s par jambe levée", "30 s per raised leg", "30 s por pierna elevada"),
    "30 sec par jambe levée alternée": F("30 s par jambe levée en alternance", "30 s per raised leg, alternating", "30 s por pierna elevada alternando"),
    "35 sec par jambe levée alternée": F("35 s par jambe levée en alternance", "35 s per raised leg, alternating", "35 s por pierna elevada alternando"),

    # --- TEMPS DE JEU EFFECTIF / MATCH / REVUE → freeText (heures/format universels) ---
    "12 min effectif": F("12 min effectif", "12 min effective", "12 min efectivos"),
    "15 min effectif": F("15 min effectif", "15 min effective", "15 min efectivos"),
    "20 min effectif": F("20 min effectif", "20 min effective", "20 min efectivos"),
    "30 min effectif": F("30 min effectif", "30 min effective", "30 min efectivos"),
    "35 min effectif": F("35 min effectif", "35 min effective", "35 min efectivos"),
    "5 min effectif/set": F("5 min effectif / set", "5 min effective / set", "5 min efectivos / set"),
    "45 min jeu effectif": F("45 min de jeu effectif", "45 min effective play", "45 min de juego efectivo"),
    "60 min jeu effectif": F("60 min de jeu effectif", "60 min effective play", "60 min de juego efectivo"),
    "70 min jeu effectif": F("70 min de jeu effectif", "70 min effective play", "70 min de juego efectivo"),
    "80 min jeu effectif": F("80 min de jeu effectif", "80 min effective play", "80 min de juego efectivo"),
    "90 min jeu effectif": F("90 min de jeu effectif", "90 min effective play", "90 min de juego efectivo"),
    "90 min (2 x 45 min)": F("90 min (2 × 45 min)", "90 min (2 × 45 min)", "90 min (2 × 45 min)"),
    "10 min review (peut etre fait apres seance)": F("10 min de revue (à faire après la séance si besoin)", "10 min review (can be done after the session)", "10 min de revisión (se puede hacer después de la sesión)"),
    "match (60-150 min selon format)": F("match (60-150 min selon le format)", "match (60-150 min depending on format)", "partido (60-150 min según el formato)"),
    "match (60-150 min selon format 2 sets ou 3 sets gagnants)": F("match (60-150 min selon le format : 2 ou 3 sets gagnants)", "match (60-150 min depending on format: best of 3 or 5 sets)", "partido (60-150 min según el formato: al mejor de 3 o 5 sets)"),
    "match (60-180 min selon format et niveau)": F("match (60-180 min selon le format et le niveau)", "match (60-180 min depending on format and level)", "partido (60-180 min según el formato y el nivel)"),
}

# Table complète (union) + clés par lot (pour gen-migration ciblé sans toucher aux lots précédents).
DOSE = {**YOGA, **RUNNING, **CYCLING, **SWIMMING, **HIKING, **HIIT, **STRENGTH, **TENNISFOOT}
RUNNING_KEYS = list(RUNNING.keys())
CYCLING_KEYS = list(CYCLING.keys())
SWIMMING_KEYS = list(SWIMMING.keys())
HIKING_KEYS = list(HIKING.keys())
HIIT_KEYS = list(HIIT.keys())
STRENGTH_KEYS = list(STRENGTH.keys())
TENNISFOOT_KEYS = list(TENNISFOOT.keys())


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
            act = (f', activity: DoseActivity(rawValue: {_swift_str(sg["activity"])})!' if sg.get("activity") else "")
            segs.append(f'IntervalSegment(value: {_swift_str(sg["value"])}, unit: DoseUnit(rawValue: {_swift_str(sg["unit"])})!{act})')
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
        elif lot == "hiking":
            gen_migration(HIKING_KEYS)
        elif lot == "hiit":
            gen_migration(HIIT_KEYS)
        elif lot == "strength":
            gen_migration(STRENGTH_KEYS)
        elif lot == "tennisfoot":
            gen_migration(TENNISFOOT_KEYS)
        else:
            gen_migration(list(DOSE.keys()))
    else:
        print(f"commande inconnue: {cmd}"); sys.exit(1)
