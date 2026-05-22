// Views/Components/GlossaryDiscoveryTooltip.swift
// Story 3.17 Phase 1 — toast bottom subtil affiché à la première ouverture de
// SessionDetailView pour signaler à l'utilisateur que les mots soulignés sont
// tappables. Persisté via UserDefaults — une seule fois par compte/device.
//
// Auto-dismiss : 6 secondes OR tap utilisateur OR scroll (géré côté caller via
// reset binding) OR background app.
import SwiftUI

struct GlossaryDiscoveryTooltipModifier: ViewModifier {
    @Binding var isPresented: Bool
    var autoDismissAfter: TimeInterval = 6.0

    @State private var dismissTask: Task<Void, Never>?

    func body(content: Content) -> some View {
        content
            .overlay(alignment: .bottom) {
                if isPresented {
                    GlossaryDiscoveryTooltipView()
                        .padding(.horizontal, 16)
                        .padding(.bottom, 24)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        .onTapGesture {
                            dismiss()
                        }
                        .accessibilityIdentifier("coaching.session.glossary.tooltip.discovery")
                }
            }
            .animation(.easeOut(duration: 0.3), value: isPresented)
            .onChange(of: isPresented) { _, newValue in
                if newValue {
                    scheduleAutoDismiss()
                } else {
                    dismissTask?.cancel()
                    dismissTask = nil
                }
            }
            .onDisappear {
                dismissTask?.cancel()
                dismissTask = nil
            }
    }

    private func scheduleAutoDismiss() {
        dismissTask?.cancel()
        dismissTask = Task { @MainActor in
            try? await Task.sleep(nanoseconds: UInt64(autoDismissAfter * 1_000_000_000))
            guard !Task.isCancelled else { return }
            dismiss()
        }
    }

    @MainActor private func dismiss() {
        guard isPresented else { return }
        isPresented = false
        GlossaryDiscoveryTooltip.markShown()
    }
}

private struct GlossaryDiscoveryTooltipView: View {
    var body: some View {
        HStack(spacing: 10) {
            Text("coaching.session.glossary.tooltip.discovery")
                .font(.footnote.weight(.medium))
                .foregroundStyle(.white)
                .multilineTextAlignment(.leading)
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(Color.coachingPrimary.opacity(0.95))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .shadow(color: .black.opacity(0.18), radius: 8, x: 0, y: 3)
    }
}

/// API utility pour gérer la persistance UserDefaults du flag "déjà vu".
enum GlossaryDiscoveryTooltip {
    static let userDefaultsKey = "coaching.glossary.discovery.tooltip.shown"

    /// True si on doit présenter le tooltip à l'ouverture (jamais vu encore).
    /// Skip si `UI_TEST_SCENARIO` est set sauf pour le scenario glossaire
    /// dédié (qui veut justement capturer le toast visuellement).
    static func shouldPresent(userDefaults: UserDefaults = .standard) -> Bool {
        let scenario = ProcessInfo.processInfo.environment["UI_TEST_SCENARIO"]
        let glossaryReviewScenarios: Set<String> = [
            "ui_review_session_detail_glossary",
            "ui_review_session_detail_v2"
        ]
        if let scenario, !glossaryReviewScenarios.contains(scenario) {
            return false
        }
        return !userDefaults.bool(forKey: userDefaultsKey)
    }

    /// Marque le tooltip comme vu (persisté UserDefaults).
    static func markShown(userDefaults: UserDefaults = .standard) {
        userDefaults.set(true, forKey: userDefaultsKey)
    }

    /// Reset pour tests ou debug. Pas exposé en prod.
    #if DEBUG
    static func resetForTesting(userDefaults: UserDefaults = .standard) {
        userDefaults.removeObject(forKey: userDefaultsKey)
    }
    #endif
}

extension View {
    /// Modifier d'ajout du toast découvrabilité. Le caller contrôle `isPresented`
    /// et est responsable de l'init à `true` au bon moment (cf `.task` in
    /// SessionDetailView).
    func glossaryDiscoveryTooltip(isPresented: Binding<Bool>) -> some View {
        modifier(GlossaryDiscoveryTooltipModifier(isPresented: isPresented))
    }
}

#if DEBUG
#Preview("Tooltip — affiché") {
    @Previewable @State var shown = true
    return VStack {
        Text("SessionDetailView content...")
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(uiColor: .systemBackground))
    }
    .glossaryDiscoveryTooltip(isPresented: $shown)
}
#endif
