import CoreLocation

nonisolated final class ADSBProvider: TargetProvider, Sendable {
    let providerID = "adsb.lol"
    let displayName = "ADS-B (adsb.lol)"
    let category = TargetCategory.air

    private let client: APIClient

    nonisolated init(client: APIClient = APIClient()) {
        self.client = client
    }

    nonisolated func fetchTargets(
        center: CLLocationCoordinate2D,
        radiusNM: Double
    ) async throws -> [Target] {
        let clampedRadius = min(radiusNM, 250)
        let urlString = "\(AppConstants.adsbBaseURL)/lat/\(center.latitude)/lon/\(center.longitude)/dist/\(Int(clampedRadius))"
        guard let url = URL(string: urlString) else {
            throw APIError.invalidURL(urlString)
        }

        let response = try await client.fetch(ADSBResponse.self, from: url)
        return (response.ac ?? []).compactMap { aircraft in
            Self.mapToTarget(aircraft, source: providerID)
        }
    }

    nonisolated func startPolling(
        center: CLLocationCoordinate2D,
        radiusNM: Double,
        onTargets: @Sendable ([Target]) -> Void
    ) async throws {
        while !Task.isCancelled {
            do {
                let targets = try await fetchTargets(center: center, radiusNM: radiusNM)
                onTargets(targets)
            } catch {
                print("[ADSBProvider] fetch error: \(error)")
            }
            try await Task.sleep(for: .seconds(AppConstants.pollIntervalSeconds))
        }
    }

    private nonisolated static func mapToTarget(
        _ ac: ADSBResponse.Aircraft,
        source: String
    ) -> Target? {
        guard let lat = ac.lat, let lon = ac.lon else { return nil }

        let isOnGround: Bool
        let altFeet: Int?
        switch ac.altBaro {
        case .ground:
            isOnGround = true
            altFeet = 0
        case .altitude(let ft):
            isOnGround = false
            altFeet = ft
        case nil:
            isOnGround = false
            altFeet = ac.altGeom
        }

        return Target(
            id: ac.hex.lowercased(),
            callsign: ac.flight?.trimmingCharacters(in: .whitespaces),
            registration: ac.r,
            typeDesignator: ac.t,
            category: .air,
            classification: classifyAircraft(ac),
            coordinate: CLLocationCoordinate2D(latitude: lat, longitude: lon),
            altitudeFeet: altFeet,
            isOnGround: isOnGround,
            heading: ac.track ?? ac.trueHeading ?? ac.magHeading,
            groundSpeedKnots: ac.gs,
            verticalRateFPM: ac.baroRate ?? ac.geomRate,
            previousCoordinate: nil,
            lastPositionTime: Date.now,
            squawk: ac.squawk,
            signalStrength: ac.rssi,
            lastSeen: Date.now,
            source: source
        )
    }

    // Basic heuristic classification — MilitaryClassifier (4-layer) replaces this in Phase 3
    private nonisolated static func classifyAircraft(
        _ ac: ADSBResponse.Aircraft
    ) -> TargetClassification {
        if let dbFlags = ac.dbFlags, dbFlags & 1 != 0 {
            return .military
        }
        return .unknown
    }
}
