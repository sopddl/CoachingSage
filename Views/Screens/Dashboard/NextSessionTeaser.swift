// Views/Screens/Dashboard/NextSessionTeaser.swift
// Story 3.15 AC7 — teaser séance N+1 affiché toujours visible sous la séance
// focale (NextSessionCard). Hauteur réduite ~70pt, contenu : préfixe "Puis :"
// + nom séance + chevron.
//
// Cas de rendu :
//   - `teaserSession` non nil → ligne pleine cliquable
//   - `teaserSession` nil ET `hasFocal == true` → label discret "Dernière
//     séance de la semaine" (variante deadline qui bloque sur la semaine
//     courante, ou pénultième session globale)
//   - `hasFocal == false` → rien affiché (mais le caller n'a pas affiché la
//     focale non plus dans ce cas)
//
// Style : fond pâle (coachingCard) + bordure subtle + chevron, distingué
// visuellement de la card focale (qui est plus contrastée coach blue).
import SwiftUI

struct NextSessionTeaser: View {
    /// Locale in-app (injectée au root depuis `LanguageManager.currentLocale`).
    @Environment(\.locale) private var locale
    /// Session N+1 résolue par `NextSessionResolver.nextTwoSessions(for:now:).teaser?.session`.
    /// `nil` = pas de N+1 disponible.
    let teaserSession: PersistedSession?
    /// `true` quand la séance focale est affichée — sert à savoir si on doit
    /// montrer le label "Dernière séance de la semaine" en fallback.
    let hasFocal: Bool

    var body: some View {
        if let teaserSession {
            teaserRow(session: teaserSession)
        } else if hasFocal {
            lastOfWeekRow
        }
    }

    /// **Story 3.15 raffinement 2026-05-21** — display-only (pas de tap → push).
    /// Sophie : "les seance c'est pas un scroll comme j'ai demandé mais on
    /// bascule ds le programme". Le teaser est désormais en lecture pure :
    /// l'user voit la séance suivante mais ne navigue pas depuis ici. Pour
    /// agir, il scroll la page (geste vertical sur les cards en-dessous).
    private func teaserRow(session: PersistedSession) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 8) {
                Text("dashboard.next_session.teaser.prefix")
                    .font(.coachingCaption.weight(.semibold))
                    .foregroundStyle(Color.coachingTextSecondary)
                    .textCase(.uppercase)
                    .tracking(0.8)
                // **Story 3.15 v3 (Sophie 2026-05-21)** — coordonnée séance S·J
                // dans le préfixe pour identifier ce qu'est la séance suivante.
                Text(verbatim: coordinateLabel(session: session))
                    .font(.coachingCaption.weight(.semibold))
                    .foregroundStyle(Color.coachingPrimary)
                Spacer(minLength: 0)
            }
            Text(verbatim: session.name.resolved(locale))
                .font(.coachingBody)
                .foregroundStyle(Color.coachingTextPrimary)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(Color.coachingCard)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .accessibilityIdentifier("dashboard.next_session.teaser")
    }

    private func coordinateLabel(session: PersistedSession) -> String {
        String(
            format: NSLocalizedString("dashboard.active.next.coordinate.format", comment: ""),
            session.weekNumber,
            session.day
        )
    }

    private var lastOfWeekRow: some View {
        HStack(spacing: 8) {
            Image(systemName: "flag.checkered")
                .font(.footnote.weight(.medium))
                .foregroundStyle(Color.coachingTextSecondary)
            Text("dashboard.next_session.teaser.last_of_week")
                .font(.coachingCaption)
                .foregroundStyle(Color.coachingTextSecondary)
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(Color.coachingCard.opacity(0.6))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .accessibilityIdentifier("dashboard.next_session.teaser.lastOfWeek")
    }
}

/// **Story 3.15 v4 (Sophie 2026-05-21)** — row compacte d'une session à venir
/// dans la liste "Séances" sous la card focale. Pas de préfixe "PUIS" (Sophie :
/// « enleve le PUIS »). Badge sport déduit (heuristique pour Triathlon
/// multi-sport sur le nom de session, sinon sport du programme parent).
struct UpcomingSessionRow: View {
    @Environment(\.locale) private var locale
    let session: PersistedSession
    /// Sport du programme parent (running / cycling / triathlon / etc).
    /// Pour Triathlon, on déduit le sport spécifique de la session via
    /// `sportCodeForSession(:in:)`.
    let sportCode: String
    /// Story 3.35l — numéro de séance incrémental (affiché au-dessus du nom).
    var number: Int? = nil

    var body: some View {
        let effectiveSport = SessionSportInference.sportCode(for: session, programSportCode: sportCode)
        HStack(spacing: 10) {
            ZStack {
                RoundedRectangle(cornerRadius: 7, style: .continuous)
                    .strokeBorder(Color.coachingSport(forCode: effectiveSport), lineWidth: 1.5)
                Image(systemName: SportSymbol.symbol(forCode: effectiveSport))
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Color.coachingSport(forCode: effectiveSport))
            }
            .frame(width: 28, height: 28)

            VStack(alignment: .leading, spacing: 1) {
                if let number {
                    Text("coaching.adapter.session.number \(number)")
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(Color.coachingTextSecondary)
                }
                Text(verbatim: session.name.resolved(locale).sanitizedForDisplay)
                    .font(.subheadline)
                    .foregroundStyle(Color.coachingTextPrimary)
                    .lineLimit(1)
            }

            Spacer(minLength: 6)

            Text(verbatim: String(
                format: NSLocalizedString("dashboard.active.next.duration.format", comment: ""),
                session.durationMinutes
            ))
            .font(.caption)
            .foregroundStyle(Color.coachingTextSecondary)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color.coachingCard)
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        .accessibilityIdentifier("dashboard.upcoming.session.\(effectiveSport)")
    }
}

/// **Story 3.15 v4** — heuristique pour déduire le sport spécifique d'une
/// session d'un programme **multi-sport** (Triathlon). Pour les programmes
/// mono-sport (Running, Cycling, etc.), retourne directement le sport du
/// programme. Pour Triathlon, parse le `session.name` à la recherche de
/// keywords (FR + EN) → running / cycling / swimming.
///
/// Limitations connues (V1) :
///   - Fragile : si un template ne suit pas la convention "Run X / Bike X /
///     Swim X" dans le nom de session, le fallback retombe sur "triathlon".
///   - À remplacer par un champ `PersistedSession.sport` quand on enrichira
///     le data model (story future, demande migration SwiftData).
enum SessionSportInference {
    static func sportCode(for session: PersistedSession, programSportCode: String) -> String {
        sportCode(forSessionName: session.name.canonical, programSportCode: programSportCode)
    }

    /// Variante name+parent — utilisée par `AdaptedProgramView` / `SessionDetailView`
    /// qui manipulent des `AdaptedSession` (pas des `PersistedSession`). Story 3.15
    /// v7.2 (Sophie 2026-05-21) : avant ce fix, la liste sessions du programme
    /// triathlon affichait `figure.mixed.cardio` partout (sport parent), au lieu
    /// du symbole spécifique Swim/Bike/Run par session.
    static func sportCode(forSessionName name: String, programSportCode: String) -> String {
        guard programSportCode == "triathlon" else { return programSportCode }
        let lower = name.lowercased()
        // **Story 3.15 v5 fix (Sophie 2026-05-21)** — keywords strictement
        // sport-specific. Avant : "z2" / "daniels" / "fractionn" causaient
        // un faux match running pour "Bike FTP-Z2" (Z2 = zone d'intensité
        // utilisée tous sports). Ordre check : Bike → Swim → Run (Run en
        // dernier car ses keywords génériques sont rares maintenant).
        let bikeKeywords = ["bike", "vélo", "velo", "cycling", "cycle", "ftp", "rouleau"]
        let swimKeywords = ["swim", "natation", "nage", "crawl", "brasse"]
        let runKeywords = ["run", "running", "course", "footing"]
        if bikeKeywords.contains(where: { lower.contains($0) }) { return "cycling" }
        if swimKeywords.contains(where: { lower.contains($0) }) { return "swimming" }
        if runKeywords.contains(where: { lower.contains($0) }) { return "running" }
        return programSportCode
    }
}

/// **Story 3.15 v4** — central mapping sport code → SF Symbol. Évite la
/// duplication dans `ProgramCard`, `DormantProgramRow`, `UpcomingSessionRow`.
enum SportSymbol {
    static func symbol(forCode code: String) -> String {
        switch code {
        case "running": return "figure.run"
        case "cycling": return "figure.outdoor.cycle"
        case "swimming": return "figure.pool.swim"
        case "triathlon": return "figure.mixed.cardio"
        case "strengthTraining", "strength_training": return "dumbbell.fill"
        case "yoga": return "figure.yoga"
        case "hiit": return "bolt.heart.fill"
        case "hiking": return "figure.hiking"
        case "tennis": return "figure.tennis"
        case "football": return "soccerball"
        default: return "questionmark.circle"
        }
    }
}
