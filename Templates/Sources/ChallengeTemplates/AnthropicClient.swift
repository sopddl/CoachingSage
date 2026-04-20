import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

struct AnthropicClient {
    let apiKey: String
    let model: String
    let maxTokens: Int
    let maxRetries: Int

    init(apiKey: String, model: String = "claude-sonnet-4-6", maxTokens: Int = 64000, maxRetries: Int = 3) {
        self.apiKey = apiKey
        self.model = model
        self.maxTokens = maxTokens
        self.maxRetries = maxRetries
    }

    static let modelPricing: [String: (inputPer1M: Double, outputPer1M: Double)] = [
        "claude-sonnet-4-6": (inputPer1M: 3.00, outputPer1M: 15.00),
        "claude-haiku-4-5-20251001": (inputPer1M: 0.80, outputPer1M: 4.00),
        "claude-haiku-4-5": (inputPer1M: 0.80, outputPer1M: 4.00)
    ]

    static func estimatedCostUSD(model: String, inputTokens: Int, outputTokens: Int) -> Double {
        guard let pricing = modelPricing[model] else { return 0 }
        return Double(inputTokens) / 1_000_000.0 * pricing.inputPer1M
             + Double(outputTokens) / 1_000_000.0 * pricing.outputPer1M
    }

    struct Message: Codable { let role: String; let content: String }
    private struct Request: Codable {
        let model: String
        let max_tokens: Int
        let system: String
        let messages: [Message]
    }
    private struct Response: Codable {
        struct ContentBlock: Codable { let type: String; let text: String? }
        struct Usage: Codable { let input_tokens: Int; let output_tokens: Int }
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
        let retriesUsed: Int
    }

    /// Public entry point. Wraps `callOnce` with retry-on-transient-network-error logic.
    /// Backoff : 2^attempt seconds (1s → 2s → 4s → 8s …).
    func call(system: String, userMessage: String) async throws -> CallResult {
        var lastError: Error?
        for attempt in 0...maxRetries {
            do {
                var result = try await callOnce(system: system, userMessage: userMessage)
                result = CallResult(
                    text: result.text,
                    inputTokens: result.inputTokens,
                    outputTokens: result.outputTokens,
                    elapsedSeconds: result.elapsedSeconds,
                    stopReason: result.stopReason,
                    model: result.model,
                    estimatedCostUSD: result.estimatedCostUSD,
                    retriesUsed: attempt
                )
                return result
            } catch {
                lastError = error
                if !isTransientNetworkError(error) || attempt == maxRetries {
                    throw error
                }
                let delaySeconds = pow(2.0, Double(attempt))
                let attemptNum = attempt + 1
                FileHandle.standardError.write(Data(
                    "  [retry] \(describeError(error)) → attente \(delaySeconds)s avant tentative \(attemptNum + 1)/\(maxRetries + 1)\n".utf8
                ))
                try await Task.sleep(nanoseconds: UInt64(delaySeconds * 1_000_000_000))
            }
        }
        throw lastError ?? AnthropicError.noHTTPResponse
    }

    private func callOnce(system: String, userMessage: String) async throws -> CallResult {
        guard let url = URL(string: "https://api.anthropic.com/v1/messages") else {
            throw AnthropicError.invalidURL
        }

        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.setValue(apiKey, forHTTPHeaderField: "x-api-key")
        req.setValue("2023-06-01", forHTTPHeaderField: "anthropic-version")
        req.timeoutInterval = 600

        let body = Request(model: model, max_tokens: maxTokens, system: system,
                           messages: [Message(role: "user", content: userMessage)])
        req.httpBody = try JSONEncoder().encode(body)

        let start = Date()
        let (data, response) = try await URLSession.shared.data(for: req)
        let elapsed = Date().timeIntervalSince(start)

        guard let http = response as? HTTPURLResponse else { throw AnthropicError.noHTTPResponse }
        guard (200..<300).contains(http.statusCode) else {
            let body = String(data: data, encoding: .utf8) ?? "<no body>"
            throw AnthropicError.httpError(status: http.statusCode, body: body)
        }

        let decoded = try JSONDecoder().decode(Response.self, from: data)
        let text = decoded.content.compactMap { $0.text }.joined()
        let cost = Self.estimatedCostUSD(model: model,
                                         inputTokens: decoded.usage.input_tokens,
                                         outputTokens: decoded.usage.output_tokens)
        return CallResult(text: text,
                          inputTokens: decoded.usage.input_tokens,
                          outputTokens: decoded.usage.output_tokens,
                          elapsedSeconds: elapsed,
                          stopReason: decoded.stop_reason,
                          model: model,
                          estimatedCostUSD: cost,
                          retriesUsed: 0)
    }

    /// Returns true for transient network errors worth retrying.
    /// Covers timeout, connection lost, offline, unreachable, DNS, and HTTP 429/5xx from upstream.
    private func isTransientNetworkError(_ error: Error) -> Bool {
        let nsErr = error as NSError
        // URLError codes
        if nsErr.domain == NSURLErrorDomain {
            switch nsErr.code {
            case NSURLErrorTimedOut,               // -1001
                 NSURLErrorCannotConnectToHost,    // -1004
                 NSURLErrorNetworkConnectionLost,  // -1005
                 NSURLErrorNotConnectedToInternet, // -1009
                 NSURLErrorDNSLookupFailed,        // -1003 / cannotFindHost
                 NSURLErrorCannotFindHost,         // -1003
                 NSURLErrorResourceUnavailable:    // -1008
                return true
            default:
                return false
            }
        }
        // API-side transient HTTP statuses
        if case AnthropicError.httpError(let status, _) = error {
            return status == 408 || status == 429 || (500...599).contains(status)
        }
        return false
    }

    private func describeError(_ error: Error) -> String {
        let ns = error as NSError
        if ns.domain == NSURLErrorDomain { return "réseau \(ns.code) \(ns.localizedDescription)" }
        if case AnthropicError.httpError(let s, _) = error { return "HTTP \(s)" }
        return "\(error)"
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
        case .httpError(let s, let b): return "Anthropic HTTP \(s): \(b)"
        }
    }
}
