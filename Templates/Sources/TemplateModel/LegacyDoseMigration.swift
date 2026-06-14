import Foundation

// Chantier structuration i18n du dosage (party 2026-06-14, Lot 1 yoga) — migration T3 (zéro dette).
//
// FICHIER GÉNÉRÉ depuis la table d'injection Python des templates yoga (source figée unique).
// NE PAS éditer à la main. Le filet `LegacyDoseMigrationTests` vérifie qu'il couvre exactement
// les mêmes strings que les templates bundlés.
//
// Rôle : reconstruire un `Dose` structuré depuis les strings legacy FR `duration`/`reps` des
// exercices PERSISTÉS avant le chantier (blob `AdaptedExercise` sans champ `dose`). Appliqué en
// FALLBACK display-time (`AdaptedExercise.effectiveDose`) — pas d'écriture SwiftData, pas de
// matching séance↔template, pas d'async. Le contenu NEUF porte déjà son `dose` (option A).
public enum LegacyDoseMigration {

    /// `Dose` reconstruit depuis les strings legacy (priorité `duration`, sinon `reps`).
    /// nil = string non reconnue → l'appelant garde le rendu legacy verbatim.
    public static func dose(duration: String?, reps: String?) -> Dose? {
        guard let key = duration ?? reps else { return nil }
        return table[key]
    }

    /// Toutes les clés FR couvertes (pour le filet de cohérence avec les templates).
    public static var coveredKeys: Set<String> { Set(table.keys) }

    static let table: [String: Dose] = [
        "1 cycle": .structured(StructuredDose(value: "1", unit: DoseUnit(rawValue: "cycles")!)),
        "1 cycle complet": .structured(StructuredDose(value: "1", unit: DoseUnit(rawValue: "cycles")!)),
        "1 cycle breath-led": .structured(StructuredDose(value: "1", unit: DoseUnit(rawValue: "cycles")!, style: DoseStyle(rawValue: "breathLed")!)),
        "1 cycle = 9 respirations breath-led": .freeText(LocalizedText(fr: "1 cycle = 9 respirations au rythme du souffle", en: "1 cycle = 9 breath-led breaths", es: "1 ciclo = 9 respiraciones al ritmo de la respiración")),
        "1 cycle = 17 respirations breath-led": .freeText(LocalizedText(fr: "1 cycle = 17 respirations au rythme du souffle", en: "1 cycle = 17 breath-led breaths", es: "1 ciclo = 17 respiraciones al ritmo de la respiración")),
        "1 cycle complet (~1 min 30)": .freeText(LocalizedText(fr: "1 cycle complet (~1 min 30)", en: "1 full cycle (~1 min 30)", es: "1 ciclo completo (~1 min 30)")),
        "1 cycle complet (~2 min)": .freeText(LocalizedText(fr: "1 cycle complet (~2 min)", en: "1 full cycle (~2 min)", es: "1 ciclo completo (~2 min)")),
        "1 min": .structured(StructuredDose(value: "1", unit: DoseUnit(rawValue: "minutes")!)),
        "1 min 30": .freeText(LocalizedText(fr: "1 min 30", en: "1 min 30", es: "1 min 30")),
        "2 min": .structured(StructuredDose(value: "2", unit: DoseUnit(rawValue: "minutes")!)),
        "2.5 min séquence": .structured(StructuredDose(value: "2.5", unit: DoseUnit(rawValue: "minutes")!)),
        "3 min": .structured(StructuredDose(value: "3", unit: DoseUnit(rawValue: "minutes")!)),
        "3.5 min finishing": .structured(StructuredDose(value: "3.5", unit: DoseUnit(rawValue: "minutes")!)),
        "3.5 min séquence": .structured(StructuredDose(value: "3.5", unit: DoseUnit(rawValue: "minutes")!)),
        "4 min": .structured(StructuredDose(value: "4", unit: DoseUnit(rawValue: "minutes")!)),
        "4 min finishing cutback": .structured(StructuredDose(value: "4", unit: DoseUnit(rawValue: "minutes")!)),
        "4 min séquence": .structured(StructuredDose(value: "4", unit: DoseUnit(rawValue: "minutes")!)),
        "4.5 min finishing": .structured(StructuredDose(value: "4.5", unit: DoseUnit(rawValue: "minutes")!)),
        "5 min": .structured(StructuredDose(value: "5", unit: DoseUnit(rawValue: "minutes")!)),
        "5 min séquence": .structured(StructuredDose(value: "5", unit: DoseUnit(rawValue: "minutes")!)),
        "5.5 min séquence": .structured(StructuredDose(value: "5.5", unit: DoseUnit(rawValue: "minutes")!)),
        "5.5 min séquence finishing": .structured(StructuredDose(value: "5.5", unit: DoseUnit(rawValue: "minutes")!)),
        "6 min": .structured(StructuredDose(value: "6", unit: DoseUnit(rawValue: "minutes")!)),
        "6 min finishing": .structured(StructuredDose(value: "6", unit: DoseUnit(rawValue: "minutes")!)),
        "6 min séquence": .structured(StructuredDose(value: "6", unit: DoseUnit(rawValue: "minutes")!)),
        "6.5 min finishing": .structured(StructuredDose(value: "6.5", unit: DoseUnit(rawValue: "minutes")!)),
        "7 min": .structured(StructuredDose(value: "7", unit: DoseUnit(rawValue: "minutes")!)),
        "8 min": .structured(StructuredDose(value: "8", unit: DoseUnit(rawValue: "minutes")!)),
        "10 min": .structured(StructuredDose(value: "10", unit: DoseUnit(rawValue: "minutes")!)),
        "12 min": .structured(StructuredDose(value: "12", unit: DoseUnit(rawValue: "minutes")!)),
        "15 min": .structured(StructuredDose(value: "15", unit: DoseUnit(rawValue: "minutes")!)),
        "18 min": .structured(StructuredDose(value: "18", unit: DoseUnit(rawValue: "minutes")!)),
        "20 min": .structured(StructuredDose(value: "20", unit: DoseUnit(rawValue: "minutes")!)),
        "20 min lecture + réflexion": .freeText(LocalizedText(fr: "20 min de lecture + réflexion", en: "20 min reading + reflection", es: "20 min de lectura + reflexión")),
        "3 min (~10 cycles)": .freeText(LocalizedText(fr: "3 min (~10 cycles)", en: "3 min (~10 cycles)", es: "3 min (~10 ciclos)")),
        "3 min (~10 cycles respiratoires)": .freeText(LocalizedText(fr: "3 min (~10 cycles respiratoires)", en: "3 min (~10 breath cycles)", es: "3 min (~10 ciclos respiratorios)")),
        "5 min (2 min Dirgha + 3 min Ujjayi)": .freeText(LocalizedText(fr: "5 min (2 min Dirgha + 3 min Ujjayi)", en: "5 min (2 min Dirgha + 3 min Ujjayi)", es: "5 min (2 min Dirgha + 3 min Ujjayi)")),
        "5 min (3 min Dirgha + 2 min Ujjayi)": .freeText(LocalizedText(fr: "5 min (3 min Dirgha + 2 min Ujjayi)", en: "5 min (3 min Dirgha + 2 min Ujjayi)", es: "5 min (3 min Dirgha + 2 min Ujjayi)")),
        "6 min (3 min Dirgha + 3 min Ujjayi)": .freeText(LocalizedText(fr: "6 min (3 min Dirgha + 3 min Ujjayi)", en: "6 min (3 min Dirgha + 3 min Ujjayi)", es: "6 min (3 min Dirgha + 3 min Ujjayi)")),
        "20 sec": .structured(StructuredDose(value: "20", unit: DoseUnit(rawValue: "seconds")!)),
        "25 sec": .structured(StructuredDose(value: "25", unit: DoseUnit(rawValue: "seconds")!)),
        "30 sec": .structured(StructuredDose(value: "30", unit: DoseUnit(rawValue: "seconds")!)),
        "30 sec hold": .structured(StructuredDose(value: "30", unit: DoseUnit(rawValue: "seconds")!)),
        "35 sec": .structured(StructuredDose(value: "35", unit: DoseUnit(rawValue: "seconds")!)),
        "40 sec": .structured(StructuredDose(value: "40", unit: DoseUnit(rawValue: "seconds")!)),
        "45 sec": .structured(StructuredDose(value: "45", unit: DoseUnit(rawValue: "seconds")!)),
        "50 sec": .structured(StructuredDose(value: "50", unit: DoseUnit(rawValue: "seconds")!)),
        "60 sec": .structured(StructuredDose(value: "60", unit: DoseUnit(rawValue: "seconds")!)),
        "90 sec": .structured(StructuredDose(value: "90", unit: DoseUnit(rawValue: "seconds")!)),
        "30-45 sec": .structured(StructuredDose(value: "30-45", unit: DoseUnit(rawValue: "seconds")!)),
        "20 sec par côté": .structured(StructuredDose(value: "20", unit: DoseUnit(rawValue: "seconds")!, qualifier: DoseQualifier(rawValue: "perSide")!)),
        "30 sec par côté": .structured(StructuredDose(value: "30", unit: DoseUnit(rawValue: "seconds")!, qualifier: DoseQualifier(rawValue: "perSide")!)),
        "45 sec par côté": .structured(StructuredDose(value: "45", unit: DoseUnit(rawValue: "seconds")!, qualifier: DoseQualifier(rawValue: "perSide")!)),
        "60 sec par côté": .structured(StructuredDose(value: "60", unit: DoseUnit(rawValue: "seconds")!, qualifier: DoseQualifier(rawValue: "perSide")!)),
        "60s par côté": .structured(StructuredDose(value: "60", unit: DoseUnit(rawValue: "seconds")!, qualifier: DoseQualifier(rawValue: "perSide")!)),
        "30 sec Ujjayi par côté": .structured(StructuredDose(value: "30", unit: DoseUnit(rawValue: "seconds")!, qualifier: DoseQualifier(rawValue: "perSide")!, style: DoseStyle(rawValue: "ujjayi")!)),
        "20-30s par essai": .structured(StructuredDose(value: "20-30", unit: DoseUnit(rawValue: "seconds")!, qualifier: DoseQualifier(rawValue: "perAttempt")!)),
        "30s par essai": .structured(StructuredDose(value: "30", unit: DoseUnit(rawValue: "seconds")!, qualifier: DoseQualifier(rawValue: "perAttempt")!)),
        "45s par essai": .structured(StructuredDose(value: "45", unit: DoseUnit(rawValue: "seconds")!, qualifier: DoseQualifier(rawValue: "perAttempt")!)),
        "60s par essai": .structured(StructuredDose(value: "60", unit: DoseUnit(rawValue: "seconds")!, qualifier: DoseQualifier(rawValue: "perAttempt")!)),
        "60 sec par posture par côté": .freeText(LocalizedText(fr: "60 s par posture et par côté", en: "60 s per pose and per side", es: "60 s por postura y por lado")),
        "60s tenue": .freeText(LocalizedText(fr: "60 s en tenue", en: "60 s hold", es: "60 s en mantenimiento")),
        "60s libre tenue": .freeText(LocalizedText(fr: "60 s, tenue libre", en: "60 s, free hold", es: "60 s, mantenimiento libre")),
        "90s libre tenue": .freeText(LocalizedText(fr: "90 s, tenue libre", en: "90 s, free hold", es: "90 s, mantenimiento libre")),
        "3-5 sec hold + descente contrôlée": .freeText(LocalizedText(fr: "3-5 s de tenue + descente contrôlée", en: "3-5 s hold + controlled lowering", es: "3-5 s de mantenimiento + descenso controlado")),
        "3 respirations": .structured(StructuredDose(value: "3", unit: DoseUnit(rawValue: "breaths")!)),
        "5 respirations": .structured(StructuredDose(value: "5", unit: DoseUnit(rawValue: "breaths")!)),
        "8 respirations": .structured(StructuredDose(value: "8", unit: DoseUnit(rawValue: "breaths")!)),
        "9 respirations": .structured(StructuredDose(value: "9", unit: DoseUnit(rawValue: "breaths")!)),
        "17 respirations": .structured(StructuredDose(value: "17", unit: DoseUnit(rawValue: "breaths")!)),
        "9 respirations breath-led": .structured(StructuredDose(value: "9", unit: DoseUnit(rawValue: "breaths")!, style: DoseStyle(rawValue: "breathLed")!)),
        "17 respirations breath-led": .structured(StructuredDose(value: "17", unit: DoseUnit(rawValue: "breaths")!, style: DoseStyle(rawValue: "breathLed")!)),
        "5 respirations Ujjayi": .structured(StructuredDose(value: "5", unit: DoseUnit(rawValue: "breaths")!, style: DoseStyle(rawValue: "ujjayi")!)),
        "8 respirations Ujjayi": .structured(StructuredDose(value: "8", unit: DoseUnit(rawValue: "breaths")!, style: DoseStyle(rawValue: "ujjayi")!)),
        "10 respirations Ujjayi": .structured(StructuredDose(value: "10", unit: DoseUnit(rawValue: "breaths")!, style: DoseStyle(rawValue: "ujjayi")!)),
        "5 respirations par côté": .structured(StructuredDose(value: "5", unit: DoseUnit(rawValue: "breaths")!, qualifier: DoseQualifier(rawValue: "perSide")!)),
        "8 respirations par côté": .structured(StructuredDose(value: "8", unit: DoseUnit(rawValue: "breaths")!, qualifier: DoseQualifier(rawValue: "perSide")!)),
        "10 respirations par côté": .structured(StructuredDose(value: "10", unit: DoseUnit(rawValue: "breaths")!, qualifier: DoseQualifier(rawValue: "perSide")!)),
        "5 respirations Ujjayi par côté": .structured(StructuredDose(value: "5", unit: DoseUnit(rawValue: "breaths")!, qualifier: DoseQualifier(rawValue: "perSide")!, style: DoseStyle(rawValue: "ujjayi")!)),
        "8 respirations Ujjayi par côté": .structured(StructuredDose(value: "8", unit: DoseUnit(rawValue: "breaths")!, qualifier: DoseQualifier(rawValue: "perSide")!, style: DoseStyle(rawValue: "ujjayi")!)),
        "10 respirations Ujjayi par côté": .structured(StructuredDose(value: "10", unit: DoseUnit(rawValue: "breaths")!, qualifier: DoseQualifier(rawValue: "perSide")!, style: DoseStyle(rawValue: "ujjayi")!)),
        "5 respirations par posture": .structured(StructuredDose(value: "5", unit: DoseUnit(rawValue: "breaths")!, qualifier: DoseQualifier(rawValue: "perPose")!)),
        "5 respirations Ujjayi par posture": .structured(StructuredDose(value: "5", unit: DoseUnit(rawValue: "breaths")!, qualifier: DoseQualifier(rawValue: "perPose")!, style: DoseStyle(rawValue: "ujjayi")!)),
        "5 respirations par tenue": .structured(StructuredDose(value: "5", unit: DoseUnit(rawValue: "breaths")!, qualifier: DoseQualifier(rawValue: "perHold")!)),
        "5 respirations par variante": .structured(StructuredDose(value: "5", unit: DoseUnit(rawValue: "breaths")!, qualifier: DoseQualifier(rawValue: "perVariation")!)),
        "5 respirations chaque variante": .structured(StructuredDose(value: "5", unit: DoseUnit(rawValue: "breaths")!, qualifier: DoseQualifier(rawValue: "perVariation")!)),
        "5 respirations Ujjayi par variante": .structured(StructuredDose(value: "5", unit: DoseUnit(rawValue: "breaths")!, qualifier: DoseQualifier(rawValue: "perVariation")!, style: DoseStyle(rawValue: "ujjayi")!)),
        "5 respirations chaque": .structured(StructuredDose(value: "5", unit: DoseUnit(rawValue: "breaths")!, qualifier: DoseQualifier(rawValue: "perEach")!)),
        "5 respirations chacune": .structured(StructuredDose(value: "5", unit: DoseUnit(rawValue: "breaths")!, qualifier: DoseQualifier(rawValue: "perEach")!)),
        "5 respirations + 9 roulis": .freeText(LocalizedText(fr: "5 respirations + 9 roulis", en: "5 breaths + 9 rolls", es: "5 respiraciones + 9 balanceos")),
        "5 respirations + Lolasana entre": .freeText(LocalizedText(fr: "5 respirations + Lolasana entre chaque", en: "5 breaths + Lolasana in between", es: "5 respiraciones + Lolasana entre cada una")),
        "5 respirations Ujjayi par côté par variante": .freeText(LocalizedText(fr: "5 respirations Ujjayi par côté et par variante", en: "5 Ujjayi breaths per side and per variation", es: "5 respiraciones Ujjayi por lado y por variación")),
        "5 respirations Ujjayi par posture / par côté": .freeText(LocalizedText(fr: "5 respirations Ujjayi par posture et par côté", en: "5 Ujjayi breaths per pose and per side", es: "5 respiraciones Ujjayi por postura y por lado")),
        "5 respirations Ujjayi par posture, vinyasa entre côtés": .freeText(LocalizedText(fr: "5 respirations Ujjayi par posture, vinyasa entre les côtés", en: "5 Ujjayi breaths per pose, vinyasa between sides", es: "5 respiraciones Ujjayi por postura, vinyasa entre lados")),
        "5 respirations chaque par côté": .freeText(LocalizedText(fr: "5 respirations chacune, par côté", en: "5 breaths each, per side", es: "5 respiraciones cada una, por lado")),
        "5 respirations chaque posture par côté": .freeText(LocalizedText(fr: "5 respirations par posture et par côté", en: "5 breaths per pose and per side", es: "5 respiraciones por postura y por lado")),
        "5 respirations chaque variante (avant + côté + dehri)": .freeText(LocalizedText(fr: "5 respirations par variante (avant + côté + dehri)", en: "5 breaths per variation (front + side + dehri)", es: "5 respiraciones por variación (frente + lado + dehri)")),
        "5 respirations par côté pour A et B": .freeText(LocalizedText(fr: "5 respirations par côté pour A et B", en: "5 breaths per side for A and B", es: "5 respiraciones por lado para A y B")),
        "30 respirations rapides + 1 Dirgha lente": .freeText(LocalizedText(fr: "30 respirations rapides + 1 Dirgha lente", en: "30 fast breaths + 1 slow Dirgha", es: "30 respiraciones rápidas + 1 Dirgha lenta")),
        "30 respirations rapides + 1 Dirgha entre cycles": .freeText(LocalizedText(fr: "30 respirations rapides + 1 Dirgha entre les cycles", en: "30 fast breaths + 1 Dirgha between cycles", es: "30 respiraciones rápidas + 1 Dirgha entre ciclos")),
        "30 expulsions actives + inspiration passive": .freeText(LocalizedText(fr: "30 expulsions actives + inspiration passive", en: "30 active exhales + passive inhale", es: "30 exhalaciones activas + inhalación pasiva")),
        "2 cycles breath-led": .structured(StructuredDose(value: "2", unit: DoseUnit(rawValue: "cycles")!, style: DoseStyle(rawValue: "breathLed")!)),
        "3 cycles breath-led": .structured(StructuredDose(value: "3", unit: DoseUnit(rawValue: "cycles")!, style: DoseStyle(rawValue: "breathLed")!)),
        "3 cycles breath-led enchaînés": .structured(StructuredDose(value: "3", unit: DoseUnit(rawValue: "cycles")!, style: DoseStyle(rawValue: "breathLed")!)),
        "3 cycles complets breath-led": .structured(StructuredDose(value: "3", unit: DoseUnit(rawValue: "cycles")!, style: DoseStyle(rawValue: "breathLed")!)),
        "4 cycles breath-led": .structured(StructuredDose(value: "4", unit: DoseUnit(rawValue: "cycles")!, style: DoseStyle(rawValue: "breathLed")!)),
        "4 cycles breath-led enchaînés": .structured(StructuredDose(value: "4", unit: DoseUnit(rawValue: "cycles")!, style: DoseStyle(rawValue: "breathLed")!)),
        "5 cycles breath-led": .structured(StructuredDose(value: "5", unit: DoseUnit(rawValue: "cycles")!, style: DoseStyle(rawValue: "breathLed")!)),
        "5 cycles breath-led enchaînés": .structured(StructuredDose(value: "5", unit: DoseUnit(rawValue: "cycles")!, style: DoseStyle(rawValue: "breathLed")!)),
    ]
}
