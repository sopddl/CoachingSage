// Coaching/Regen/Level+Regression.swift
// Story 3.4 Phase B.2 — helper de rétrogradage de niveau pour le cas `.restart`
// (pause longue ≥ 2 sem, doctrine ACSM detraining).
//
// Le `WeeklyRegenApplicationService` rétrograde le `level` de
// `AdaptedProgramRecord` d'un cran quand `VolumeAdjustment.requiresRebuild == true`,
// pour aligner la suite du programme sur la réalité physiologique (perte VO2max
// 4-15% après 2-8 semaines off — cf. Mujika & Padilla 2000, ACSM 11e ch. 8).
//
// Mapping (un seul cran, conservateur — ne pas écraser un user qui reprend
// après 3 sem de vacances) :
//   competitive  → regular
//   regular      → recreational
//   recreational → beginner
//   beginner     → beginner   (plancher, déjà en bas)
import TemplateModel

extension Level {
    /// Niveau rétrogradé d'un cran pour la reprise post-pause longue.
    /// `beginner` est son propre image (plancher).
    public func regressedForRestart() -> Level {
        switch self {
        case .competitive:  return .regular
        case .regular:      return .recreational
        case .recreational: return .beginner
        case .beginner:     return .beginner
        }
    }
}
