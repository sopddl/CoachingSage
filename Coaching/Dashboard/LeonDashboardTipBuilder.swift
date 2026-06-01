// Coaching/Dashboard/LeonDashboardTipBuilder.swift
// Story 3.29 — conseil contextuel de Léon affiché sur le dashboard Séances,
// dans la bande sous la liste séances (remplace le vide « moche » du
// `maxHeight: .infinity`). Hybride party 2026-06-01 : la voix coach (Léon) est
// TOUJOURS ancrée sur une donnée réelle (série, séances restantes, retard,
// type de la prochaine séance) → jamais de message « fortune-cookie » creux.
//
// Décision logique vs i18n : le builder est PUR et locale-free (testable sur la
// seule logique de priorité). La résolution du texte localisé vit dans
// `LeonTip.message(locale:)`, qui suit le pattern i18n-safe de la maison (clés
// statiques + `String.localized(_:locale:)`, jamais de `LocalizedStringKey`
// interpolée — cf hotfix 2026-05-12 `AdaptedProgramView i18n`).
import Foundation
import TemplateModel

/// Conseil contextuel de Léon. La variante est choisie par
/// `LeonDashboardTipBuilder.build` selon l'état réel du programme sélectionné
/// + les stats hebdo globales.
enum LeonTip: Equatable {
    /// Une séance d'une semaine antérieure attend (mode deadline en retard).
    case late(nextType: SessionType)
    /// Série de `days` jours consécutifs (`days ≥ streakThreshold`).
    case streak(days: Int, nextType: SessionType)
    /// Toutes les séances de la semaine courante sont faites.
    case weekCompleted
    /// Programme entièrement terminé (transitoire avant auto-archive).
    case programCompleted
    /// Il reste `count` séances cette semaine.
    case sessionsLeft(count: Int, nextType: SessionType)
    /// ~Mi-parcours du programme (≥ 50 % des séances totales faites).
    case halfway
    /// Filet générique encourageant (jamais de carte vide).
    case generic
}

struct LeonDashboardTipBuilder {
    /// Seuil minimal de jours consécutifs pour féliciter la série.
    static let streakThreshold = 3

    /// Choisit UN conseil par ordre de priorité.
    ///
    /// - `summary` : programme **sélectionné** dans le carrousel (retard,
    ///   semaine, prochaine séance).
    /// - `stats`   : stats hebdo **globales** (tous programmes actifs) — la
    ///   série n'est pas scopée au seul programme sélectionné, elle reflète la
    ///   régularité réelle de l'utilisateur.
    ///
    /// Ordre (validé Sophie 2026-06-01) : retard → série → programme fini →
    /// semaine bouclée → séances restantes → mi-parcours → filet générique.
    /// `programCompleted` est testé avant `weekCompleted` car « programme fini »
    /// implique « semaine bouclée » (sinon la célébration de fin serait masquée).
    static func build(summary: ProgramSummary, stats: WeeklyStats) -> LeonTip {
        let nextType = summary.nextSession?.type

        // 1. Séance en retard — appel à l'action en douceur.
        if summary.nextSessionIsLate, let nextType {
            return .late(nextType: nextType)
        }
        // 2. Série active (≥ 3 jours consécutifs) — motivation régularité.
        //    Requiert une prochaine séance (sinon on tombe sur prog fini en 3).
        if stats.streakDays >= streakThreshold, let nextType {
            return .streak(days: stats.streakDays, nextType: nextType)
        }
        // 3. Programme terminé (célébration). Avant `weekCompleted` car l'un
        //    implique l'autre.
        if summary.isProgramCompleted {
            return .programCompleted
        }
        // 4. Semaine bouclée (toutes les séances de la semaine faites).
        if summary.isWeekCompleted {
            return .weekCompleted
        }
        // 5. Séances restantes cette semaine.
        let sessionsLeft = max(0, summary.weekTotalSessions - summary.weekCompletedSessions)
        if sessionsLeft > 0, let nextType {
            return .sessionsLeft(count: sessionsLeft, nextType: nextType)
        }
        // 6. Mi-parcours (~50 % du programme).
        if summary.totalSessions > 0 {
            let fraction = Double(summary.totalSessionsCompleted) / Double(summary.totalSessions)
            if fraction >= 0.5 {
                return .halfway
            }
        }
        // 7. Filet générique — jamais de carte vide.
        return .generic
    }
}

// MARK: - i18n (résolution au render, pattern locale-strict de la maison)

extension LeonTip {
    /// Message localisé prêt à afficher. Les `%@` sont des **labels** (type de
    /// séance, après « : ») et non des mots insérés en milieu de phrase → évite
    /// les accords d'article/genre côté i18n. Le type de séance réutilise les
    /// clés `session.type.*` existantes (Story 3.15).
    func message(locale: Locale) -> String {
        switch self {
        case let .late(nextType):
            return String(
                format: String.localized("dashboard.leon.tip.late.format", locale: locale),
                Self.typeName(nextType, locale: locale)
            )
        case let .streak(days, nextType):
            return String(
                format: String.localized("dashboard.leon.tip.streak.format", locale: locale),
                days,
                Self.typeName(nextType, locale: locale)
            )
        case .weekCompleted:
            return String.localized("dashboard.leon.tip.weekCompleted", locale: locale)
        case .programCompleted:
            return String.localized("dashboard.leon.tip.programCompleted", locale: locale)
        case let .sessionsLeft(count, nextType):
            let key: String.LocalizationValue = count == 1
                ? "dashboard.leon.tip.sessionsLeft.one.format"
                : "dashboard.leon.tip.sessionsLeft.many.format"
            // count == 1 → format à 1 argument (%@) ; sinon 2 arguments (%d, %@).
            if count == 1 {
                return String(
                    format: String.localized(key, locale: locale),
                    Self.typeName(nextType, locale: locale)
                )
            }
            return String(
                format: String.localized(key, locale: locale),
                count,
                Self.typeName(nextType, locale: locale)
            )
        case .halfway:
            return String.localized("dashboard.leon.tip.halfway", locale: locale)
        case .generic:
            return String.localized("dashboard.leon.tip.generic", locale: locale)
        }
    }

    /// Nom localisé du type de séance via les clés statiques `session.type.*`
    /// (switch exhaustif = anti `LocalizedStringKey("foo.\(bar)")`).
    private static func typeName(_ type: SessionType, locale: Locale) -> String {
        switch type {
        case .endurance: return String.localized("session.type.endurance", locale: locale)
        case .interval:  return String.localized("session.type.interval", locale: locale)
        case .technique: return String.localized("session.type.technique", locale: locale)
        case .strength:  return String.localized("session.type.strength", locale: locale)
        case .mixed:     return String.localized("session.type.mixed", locale: locale)
        case .mobility:  return String.localized("session.type.mobility", locale: locale)
        case .rest:      return String.localized("session.type.rest", locale: locale)
        case .other:     return String.localized("session.type.other", locale: locale)
        }
    }
}
