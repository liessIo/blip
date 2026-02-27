import Foundation

nonisolated enum AppConstants: Sendable {
    static let adsbBaseURL = "https://api.adsb.lol/v2"
    static let defaultRadiusNM: Double = 50
    static let maxTargetsInMemory = 2000
    static let maxAnnotations = 500
    static let pollIntervalSeconds: TimeInterval = 5.0
    static let staleThresholdSeconds: TimeInterval = 120
    static let debounceMilliseconds = 300
    static let sourceTimeoutSeconds: TimeInterval = 2.0
}
