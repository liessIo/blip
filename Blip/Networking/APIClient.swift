import Foundation

nonisolated final class APIClient: Sendable {
    let session: URLSession
    let decoder: JSONDecoder

    nonisolated init(timeoutSeconds: TimeInterval = AppConstants.sourceTimeoutSeconds) {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = timeoutSeconds
        config.timeoutIntervalForResource = timeoutSeconds
        config.waitsForConnectivity = false
        self.session = URLSession(configuration: config)
        self.decoder = JSONDecoder()
    }

    nonisolated func fetch<T: Decodable & Sendable>(
        _ type: T.Type,
        from url: URL
    ) async throws -> T {
        let (data, response) = try await session.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            throw APIError.httpError(statusCode: httpResponse.statusCode, data: data)
        }

        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw APIError.decodingFailed(underlying: error)
        }
    }
}
