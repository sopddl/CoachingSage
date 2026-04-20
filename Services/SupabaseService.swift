// Services/SupabaseService.swift
// [COPIE IDENTIQUE] — synchroniser avec GardenSage et TailorSage.
import Supabase
import Foundation

final class SupabaseService {
    static let shared = SupabaseService()

    let client: SupabaseClient

    private init() {
        // En mode tests unitaires, le SDK Supabase ne doit pas s'initialiser
        // (pas de credentials disponibles, pas de réseau nécessaire).
        // Les tests utilisent les Mock*Repository — SupabaseService n'est jamais appelé.
        let env = ProcessInfo.processInfo.environment
        let isTesting = env["XCTestConfigurationFilePath"] != nil
                     || env["IS_UI_TESTING"] != nil
        if isTesting {
            client = SupabaseClient(
                supabaseURL: URL(string: "https://placeholder.supabase.co")!,
                supabaseKey: "placeholder-key-for-tests"
            )
            return
        }

        guard
            let host = Bundle.main.object(forInfoDictionaryKey: "SUPABASE_HOST") as? String,
            !host.isEmpty,
            let url = URL(string: "https://\(host)"),
            let anonKey = Bundle.main.object(forInfoDictionaryKey: "SUPABASE_ANON_KEY") as? String,
            !anonKey.isEmpty
        else {
            // Les credentials SUPABASE_HOST / SUPABASE_ANON_KEY sont absents ou vides.
            // Vérifier que Config-Debug.xcconfig contient les deux clés ET
            // que CoachingSage-Info.plist expose :
            //   SUPABASE_HOST     = $(SUPABASE_HOST)
            //   SUPABASE_ANON_KEY = $(SUPABASE_ANON_KEY)
            fatalError(
                "Credentials Supabase introuvables. " +
                "Vérifier Config-Debug.xcconfig et CoachingSage-Info.plist."
            )
        }
        client = SupabaseClient(
            supabaseURL: url,
            supabaseKey: anonKey,
            options: SupabaseClientOptions(
                auth: SupabaseClientOptions.AuthOptions(
                    emitLocalSessionAsInitialSession: true
                )
            )
        )
    }
}
