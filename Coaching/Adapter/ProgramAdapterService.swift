// Coaching/Adapter/ProgramAdapterService.swift
// Story 3.3a — wiring entre les @Model SwiftData (`CoachingSportProfile`,
// `CoachingProfile`) et les façades pures de l'adapter (`AdapterSportProfile`,
// `AdapterCoachingProfile`). Permet à un appelant runtime de passer ses
// entités SwiftData sans connaître le détail interne de l'adapter.
//
// **Branchement runtime** : le seul appelant prévu dans Story 3.3a est
// `AdaptedProgramView` via un parent qui dispose d'un `ProgramTemplate`
// (sélectionné par Story 3.2) + `CoachingSportProfile` + `CoachingProfile`.
// L'écran de sélection de template est livré en Story 3.2 — d'ici là,
// le service est instanciable et testable mais non câblé dans la nav.
import Foundation
import TemplateModel

@MainActor
final class ProgramAdapterService {
    private let adapter: ProgramAdapter

    init(adapter: ProgramAdapter = ProgramAdapter()) {
        self.adapter = adapter
    }

    /// Adapte un `ProgramTemplate` au profil utilisateur. 100% local, sync,
    /// 0 token, 0 réseau. Si l'algo ne sait pas patcher proprement (contrainte
    /// sans alternative), `result.requiresAIAssist == true` et l'UI peut
    /// proposer Léon Story 3.3b.
    func adapt(
        template: ProgramTemplate,
        sportProfile: CoachingSportProfile,
        coachingProfile: CoachingProfile
    ) -> AdaptedProgram {
        adapter.adapt(
            template: template,
            sportProfile: sportProfile.adapterFacade,
            coachingProfile: coachingProfile.adapterFacade
        )
    }
}

// MARK: - Bridges SwiftData → AdapterFacade

extension CoachingSportProfile {
    var adapterFacade: AdapterSportProfile {
        AdapterSportProfile(
            constraints: constraints,
            equipment: equipment,
            frequencyPerWeek: frequencyPerWeek,
            sessionDurationMinutes: sessionDurationMinutes
        )
    }
}

extension CoachingProfile {
    var adapterFacade: AdapterCoachingProfile {
        AdapterCoachingProfile(requiresMedicalClearance: requiresMedicalClearance)
    }
}
