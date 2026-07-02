// Coaching/Adapter/Rules/YogaPoseRole.swift
// Chantier densité B (2026-07-02) — porté tel quel de la branche archive
// `chantier/densite-adaptation-seance-yoga` (42f996d), doctrine validée 2026-06-21.
//
// Classifie le RÔLE doctrinal d'une posture pour borner la densification yoga (L2/L3).
// Détection par mots-clés sur `originalName` (= match_key SANSKRIT), même principe que
// `YogaVoiceScripts`/`YogaIllustration.poseKind`. Une posture non reconnue → `.active`
// (densifiable avec garde-fous), JAMAIS sacro-sainte par défaut : on ne fige que ce
// qu'on identifie explicitement comme régulateur.
import Foundation

/// Rôle doctrinal d'une posture, qui décide de son éligibilité à la densification.
public enum YogaPoseRole: Equatable, Sendable {
    /// Relaxation finale (savasana). Sacro-sainte : jamais allongée/raccourcie/dupliquée,
    /// reste au DERNIER rang (down-regulator parasympathique, plancher 5 min).
    case finalRelaxation
    /// Respiration d'ouverture (pranayama). Sacro-sainte : durée du bloc figée.
    case openingBreath
    /// Posture de repos régulatrice (balasana). Plancher 30 s, jamais raccourcie pour
    /// densifier (couper le repos = HIIT déguisé). Intercalée entre deux tours.
    case rest
    /// Assise méditative de centrage (sukhasana). Pas d'allongement de tenue (≠ gainage),
    /// mais fait partie du bloc actif répété.
    case seatedMeditative
    /// Posture active tenue. Éligible à l'allongement de tenue (borné) + au tour répété.
    case active

    /// Vrai si la posture ne doit JAMAIS être touchée par un transform (durée figée).
    public var isSacred: Bool {
        self == .finalRelaxation || self == .openingBreath
    }

    /// Classifie depuis le nom technique sanskrit (`AdaptedExercise.originalName`), avec
    /// repli sur le nom affiché. Ordre des tests = du plus spécifique au plus générique.
    public static func classify(originalName: String?, displayName: String?) -> YogaPoseRole {
        let hay = [(originalName ?? ""), (displayName ?? "")].joined(separator: " ").lowercased()

        // Relaxation finale — Savasana.
        if hay.contains("savasana") || hay.contains("cadavre") || hay.contains("relaxation") {
            return .finalRelaxation
        }
        // Respiration d'ouverture — Pranayama / dirgha / ujjayi.
        if hay.contains("pranayama") || hay.contains("dirgha") || hay.contains("ujjayi")
            || hay.contains("respiration") || hay.contains("souffle") {
            return .openingBreath
        }
        // Repos — Balasana (enfant).
        if hay.contains("balasana") || hay.contains("enfant") || hay.contains("child") {
            return .rest
        }
        // Assise méditative — Sukhasana (tailleur / posture facile).
        if hay.contains("sukhasana") || hay.contains("tailleur") || hay.contains("easy pose") {
            return .seatedMeditative
        }
        return .active
    }
}
