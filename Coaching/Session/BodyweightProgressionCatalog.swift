// Coaching/Session/BodyweightProgressionCatalog.swift
// Chantier charge muscu V2 — TRANCHE 4 (D-C/V-2). Échelle de VARIANTES par pattern pour
// les exos au poids du corps (où « charge » n'a pas de sens) : la progression se fait par
// variante (plus facile → plus dur), indexée par le niveau relatif caché (T2). JAMAIS de kg.
// Données inline FR/EN/ES (pas de clés xcstrings → rien de cassé à afficher).
import Foundation
import TemplateModel

public enum BodyweightProgressionCatalog {

    /// Variantes du plus FACILE au plus DUR. Pattern absent = pas de catalogue → fallback
    /// consigne reps/tempo générique (V-2 : jamais de coquille vide).
    static let ladders: [ExercisePattern: [LocalizedText]] = [
        .pushHorizontal: [
            LocalizedText(fr: "sur les genoux", en: "on your knees", es: "de rodillas"),
            LocalizedText(fr: "complet, corps gainé", en: "full, braced body", es: "completo, cuerpo firme"),
            LocalizedText(fr: "pieds surélevés", en: "feet elevated", es: "pies elevados"),
        ],
        .pullVertical: [
            LocalizedText(fr: "assisté (élastique ou pieds au sol)", en: "assisted (band or feet down)", es: "asistido (banda o pies en el suelo)"),
            LocalizedText(fr: "complet", en: "full", es: "completo"),
            LocalizedText(fr: "lent à la descente", en: "slow on the way down", es: "lento al bajar"),
        ],
        .squat: [
            LocalizedText(fr: "assisté ou partiel", en: "assisted or partial", es: "asistido o parcial"),
            LocalizedText(fr: "complet", en: "full depth", es: "completo"),
            LocalizedText(fr: "sauté ou sur une jambe", en: "jump or single-leg", es: "con salto o a una pierna"),
        ],
        .lunge: [
            LocalizedText(fr: "statique, appui léger", en: "static, light support", es: "estática, apoyo ligero"),
            LocalizedText(fr: "alternée", en: "alternating", es: "alternada"),
            LocalizedText(fr: "sautée", en: "jumping", es: "con salto"),
        ],
        .core: [
            LocalizedText(fr: "genoux au sol / tenue courte", en: "knees down / short hold", es: "rodillas en el suelo / aguante corto"),
            LocalizedText(fr: "complet", en: "full", es: "completo"),
            LocalizedText(fr: "avec mouvement contrôlé", en: "with controlled movement", es: "con movimiento controlado"),
        ],
        .hipThrust: [
            LocalizedText(fr: "pont fessier deux jambes", en: "two-leg glute bridge", es: "puente de glúteos a dos piernas"),
            LocalizedText(fr: "une jambe", en: "single-leg", es: "a una pierna"),
            LocalizedText(fr: "tenue en haut 2 s", en: "2 s hold at the top", es: "aguante arriba 2 s"),
        ],
        .calfRaise: [
            LocalizedText(fr: "deux jambes", en: "two legs", es: "a dos piernas"),
            LocalizedText(fr: "une jambe", en: "single-leg", es: "a una pierna"),
            LocalizedText(fr: "lent, amplitude complète", en: "slow, full range", es: "lento, rango completo"),
        ],
        .plyo: [
            LocalizedText(fr: "montée sans saut", en: "step up, no jump", es: "subida sin salto"),
            LocalizedText(fr: "saut contrôlé", en: "controlled jump", es: "salto controlado"),
            LocalizedText(fr: "saut ample, réception douce", en: "big jump, soft landing", es: "salto amplio, aterrizaje suave"),
        ],
    ]

    /// Variante conseillée pour un niveau caché (1...5). nil = pas de catalogue pour ce pattern.
    public static func variant(for pattern: ExercisePattern, level: Int) -> LocalizedText? {
        guard let ladder = ladders[pattern], !ladder.isEmpty else { return nil }
        let clamped = ExerciseLevelBounds.clamp(level)
        // Mappe 1...5 → index 0...count-1.
        let span = Double(ladder.count - 1)
        let idx = Int((Double(clamped - 1) / 4.0 * span).rounded())
        return ladder[Swift.min(ladder.count - 1, Swift.max(0, idx))]
    }
}
