// Coaching/Dashboard/EmptyDashboardState.swift
// Story 3.22-F-bis — état du mode "vide" du dashboard, dérivé du combo
// (coachingProfile, bootstrappedDormants). Pilote les 3 variantes
// d'`EmptyDashboardView` (title/hint/CTA conditionnel).
//
// Conditions de bascule (calculées dans `SessionDashboardViewModel.emptyState`) :
// - `.noProfile`           : coachingProfile == nil → onboarding pas fini
// - `.noPrograms`          : profile != nil && !bootstrappedDormants → cas normal
//                            "user fraîchement onboardé, 0 programme créé"
// - `.crossDeviceMissing`  : profile != nil && bootstrappedDormants==true
//                            ET 0 programme local → cross-device (Story 3.21 Bug F
//                            non résolu : flag global Supabase sync mais
//                            AdaptedProgramRecord local-first, pas sync).
import Foundation

public enum EmptyDashboardState: Sendable, Equatable {
    /// L'utilisatrice n'a pas (encore) complété son CoachingProfile (onboarding
    /// non finalisé). Le bootstrap n'a jamais pu jouer. Affichage uniquement
    /// pédagogique : invite à compléter le profil. Pas de CTA action puisque
    /// l'app devrait normalement forcer l'onboarding au cold launch — cas edge.
    case noProfile

    /// Cas normal post-onboarding sans aucun programme : invite à en créer un.
    /// CTA primary "Crée mon premier programme" ouvre `SportPickerSheet`.
    case noPrograms

    /// Cross-device : le flag `bootstrappedDormants` est `true` sur Supabase
    /// (sync OK) mais le store SwiftData local est vierge (l'utilisatrice
    /// vient d'installer l'app sur un nouvel iPhone, p.ex.). `AdaptedProgramRecord`
    /// est local-first donc PAS sync entre devices. Message dédié pour ne pas
    /// faire croire à un bug bootstrap. CTA "Créer ici" reste actionable.
    case crossDeviceMissing
}
