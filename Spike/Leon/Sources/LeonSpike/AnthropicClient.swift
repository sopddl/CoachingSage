import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

/// Minimal Anthropic Messages API client for the Léon spike.
/// No streaming, no retries, no caching — we want honest "cold" measurements for NFR1.
struct AnthropicClient {
    let apiKey: String
    let model: String
    let maxTokens: Int

    init(apiKey: String, model: String = "claude-sonnet-4-6", maxTokens: Int = 8192) {
        self.apiKey = apiKey
        self.model = model
        self.maxTokens = maxTokens
    }

    /// USD cost per 1M tokens (input, output) by model.
    /// Source : Anthropic pricing 2026-04.
    static let modelPricing: [String: (inputPer1M: Double, outputPer1M: Double)] = [
        "claude-sonnet-4-6": (inputPer1M: 3.00, outputPer1M: 15.00),
        "claude-haiku-4-5-20251001": (inputPer1M: 0.80, outputPer1M: 4.00),
        "claude-haiku-4-5": (inputPer1M: 0.80, outputPer1M: 4.00)
    ]

    static func estimatedCostUSD(model: String, inputTokens: Int, outputTokens: Int) -> Double {
        guard let pricing = modelPricing[model] else { return 0 }
        let inputCost = Double(inputTokens) / 1_000_000.0 * pricing.inputPer1M
        let outputCost = Double(outputTokens) / 1_000_000.0 * pricing.outputPer1M
        return inputCost + outputCost
    }

    struct Message: Codable {
        let role: String
        let content: String
    }

    private struct Request: Codable {
        let model: String
        let max_tokens: Int
        let system: String
        let messages: [Message]
    }

    private struct Response: Codable {
        struct ContentBlock: Codable {
            let type: String
            let text: String?
        }
        struct Usage: Codable {
            let input_tokens: Int
            let output_tokens: Int
        }
        let content: [ContentBlock]
        let usage: Usage
        let stop_reason: String?
    }

    struct CallResult {
        let text: String
        let inputTokens: Int
        let outputTokens: Int
        let elapsedSeconds: Double
        let stopReason: String?
        let model: String
        let estimatedCostUSD: Double
    }

    func call(system: String, userMessage: String) async throws -> CallResult {
        guard let url = URL(string: "https://api.anthropic.com/v1/messages") else {
            throw AnthropicError.invalidURL
        }

        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.setValue(apiKey, forHTTPHeaderField: "x-api-key")
        req.setValue("2023-06-01", forHTTPHeaderField: "anthropic-version")
        req.timeoutInterval = 180

        let body = Request(
            model: model,
            max_tokens: maxTokens,
            system: system,
            messages: [Message(role: "user", content: userMessage)]
        )
        req.httpBody = try JSONEncoder().encode(body)

        let start = Date()
        let (data, response) = try await URLSession.shared.data(for: req)
        let elapsed = Date().timeIntervalSince(start)

        guard let http = response as? HTTPURLResponse else {
            throw AnthropicError.noHTTPResponse
        }
        guard (200..<300).contains(http.statusCode) else {
            let body = String(data: data, encoding: .utf8) ?? "<no body>"
            throw AnthropicError.httpError(status: http.statusCode, body: body)
        }

        let decoded = try JSONDecoder().decode(Response.self, from: data)
        let text = decoded.content.compactMap { $0.text }.joined()
        let cost = Self.estimatedCostUSD(
            model: model,
            inputTokens: decoded.usage.input_tokens,
            outputTokens: decoded.usage.output_tokens
        )

        return CallResult(
            text: text,
            inputTokens: decoded.usage.input_tokens,
            outputTokens: decoded.usage.output_tokens,
            elapsedSeconds: elapsed,
            stopReason: decoded.stop_reason,
            model: model,
            estimatedCostUSD: cost
        )
    }
}

enum AnthropicError: Error, CustomStringConvertible {
    case invalidURL
    case noHTTPResponse
    case httpError(status: Int, body: String)

    var description: String {
        switch self {
        case .invalidURL: return "Invalid Anthropic API URL"
        case .noHTTPResponse: return "No HTTP response from Anthropic"
        case .httpError(let status, let body):
            return "Anthropic HTTP \(status): \(body)"
        }
    }
}
