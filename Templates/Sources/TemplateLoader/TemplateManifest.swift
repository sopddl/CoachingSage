import Foundation
import CryptoKit

public struct TemplateManifest: Codable, Equatable {
    public let schemaVersion: Int
    public let generatedAt: Date
    public let templates: [Entry]

    public struct Entry: Codable, Equatable {
        public let id: String
        public let file: String
        public let sha256: String

        public init(id: String, file: String, sha256: String) {
            self.id = id
            self.file = file
            self.sha256 = sha256
        }
    }

    public init(schemaVersion: Int, generatedAt: Date, templates: [Entry]) {
        self.schemaVersion = schemaVersion
        self.generatedAt = generatedAt
        self.templates = templates
    }

    public static let currentSchemaVersion = 1
    public static let manifestFilename = "templates-manifest"
    public static let templatesSubdir = "Templates"
}

public enum TemplateChecksum {
    public static func sha256Hex(of data: Data) -> String {
        let digest = SHA256.hash(data: data)
        return digest.map { String(format: "%02x", $0) }.joined()
    }
}
