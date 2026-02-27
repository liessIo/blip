import CoreLocation

nonisolated final class MockProvider: TargetProvider, Sendable {
    let providerID = "mock"
    let displayName = "Mock Data"
    let category = TargetCategory.air

    nonisolated func fetchTargets(
        center: CLLocationCoordinate2D,
        radiusNM: Double
    ) async throws -> [Target] {
        Self.sampleTargets
    }

    nonisolated func startPolling(
        center: CLLocationCoordinate2D,
        radiusNM: Double,
        onTargets: @Sendable ([Target]) -> Void
    ) async throws {
        while !Task.isCancelled {
            onTargets(Self.sampleTargets)
            try await Task.sleep(for: .seconds(5))
        }
    }

    static let sampleTargets: [Target] = [
        Target(
            id: "3c6752",
            callsign: "DLH1A",
            registration: "D-AIMA",
            typeDesignator: "A388",
            category: .air,
            classification: .civilian,
            coordinate: CLLocationCoordinate2D(latitude: 50.11, longitude: 8.68),
            altitudeFeet: 35000,
            isOnGround: false,
            heading: 270,
            groundSpeedKnots: 480,
            verticalRateFPM: 0,
            previousCoordinate: nil,
            lastPositionTime: .now,
            squawk: "1000",
            signalStrength: -3.5,
            lastSeen: .now,
            source: "mock"
        ),
        Target(
            id: "ae1234",
            callsign: "EVAC01",
            registration: nil,
            typeDesignator: "C17",
            category: .air,
            classification: .military,
            coordinate: CLLocationCoordinate2D(latitude: 50.05, longitude: 8.57),
            altitudeFeet: 28000,
            isOnGround: false,
            heading: 90,
            groundSpeedKnots: 420,
            verticalRateFPM: -500,
            previousCoordinate: nil,
            lastPositionTime: .now,
            squawk: "4501",
            signalStrength: -8.0,
            lastSeen: .now,
            source: "mock"
        ),
        Target(
            id: "4ca871",
            callsign: "RYR3AV",
            registration: "EI-DLV",
            typeDesignator: "B738",
            category: .air,
            classification: .civilian,
            coordinate: CLLocationCoordinate2D(latitude: 50.20, longitude: 8.80),
            altitudeFeet: 0,
            isOnGround: true,
            heading: 180,
            groundSpeedKnots: 0,
            verticalRateFPM: 0,
            previousCoordinate: nil,
            lastPositionTime: .now,
            squawk: "2000",
            signalStrength: -1.2,
            lastSeen: .now,
            source: "mock"
        ),
    ]
}
