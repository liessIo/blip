import CoreLocation

nonisolated protocol TargetProvider: Sendable {
    var providerID: String { get }
    var displayName: String { get }
    var category: TargetCategory { get }

    func startPolling(
        center: CLLocationCoordinate2D,
        radiusNM: Double,
        onTargets: @Sendable ([Target]) -> Void
    ) async throws

    func fetchTargets(
        center: CLLocationCoordinate2D,
        radiusNM: Double
    ) async throws -> [Target]
}
