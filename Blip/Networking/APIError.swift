import Foundation

nonisolated enum APIError: Error, Sendable {
    case invalidResponse
    case httpError(statusCode: Int, data: Data)
    case decodingFailed(underlying: any Error)
    case invalidURL(String)
    case timeout
}

extension APIError: LocalizedError {
    nonisolated var errorDescription: String? {
        switch self {
        case .invalidResponse: "Invalid server response"
        case .httpError(let code, _): "HTTP \(code)"
        case .decodingFailed(let err): "Decoding failed: \(err.localizedDescription)"
        case .invalidURL(let url): "Invalid URL: \(url)"
        case .timeout: "Request timed out"
        }
    }
}
