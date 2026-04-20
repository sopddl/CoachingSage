import Foundation

enum ApiKeyResolver {
    /// Resolves ANTHROPIC_API_KEY from (in order) :
    /// 1. an explicit `.env` path if provided
    /// 2. `.env` in the current working directory
    /// 3. `../Spike/Leon/.env` relative to cwd (the spike key is reused by default)
    /// 4. the process environment
    static func resolve(explicitEnvPath: String? = nil) -> String? {
        let candidates: [URL] = {
            var urls: [URL] = []
            if let p = explicitEnvPath { urls.append(URL(fileURLWithPath: p)) }
            let cwd = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
            urls.append(cwd.appendingPathComponent(".env"))
            urls.append(cwd.appendingPathComponent("../Spike/Leon/.env").standardized)
            return urls
        }()

        for url in candidates {
            if let key = readKey(from: url) {
                FileHandle.standardError.write(Data("[ApiKey] loaded from \(url.path) (len=\(key.count))\n".utf8))
                return key
            }
        }

        if let env = ProcessInfo.processInfo.environment["ANTHROPIC_API_KEY"], !env.isEmpty {
            FileHandle.standardError.write(Data("[ApiKey] loaded from process env (len=\(env.count))\n".utf8))
            return env
        }
        return nil
    }

    private static func readKey(from url: URL) -> String? {
        guard let contents = try? String(contentsOf: url, encoding: .utf8) else { return nil }
        for rawLine in contents.split(whereSeparator: { $0 == "\n" || $0 == "\r" }) {
            let trimmed = rawLine.trimmingCharacters(in: .whitespacesAndNewlines)
            if trimmed.hasPrefix("#") || trimmed.isEmpty { continue }
            guard let eq = trimmed.firstIndex(of: "=") else { continue }
            let key = String(trimmed[..<eq]).trimmingCharacters(in: .whitespacesAndNewlines)
            var value = String(trimmed[trimmed.index(after: eq)...]).trimmingCharacters(in: .whitespacesAndNewlines)
            if (value.hasPrefix("\"") && value.hasSuffix("\"")) ||
               (value.hasPrefix("'") && value.hasSuffix("'")) {
                value = String(value.dropFirst().dropLast())
            }
            if key == "ANTHROPIC_API_KEY", !value.isEmpty { return value }
        }
        return nil
    }
}
