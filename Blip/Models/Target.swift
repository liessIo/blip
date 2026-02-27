import CoreLocation

nonisolated struct Target: Identifiable, Sendable, Hashable {
    let id: String
    var callsign: String?
    var registration: String?
    var typeDesignator: String?

    var category: TargetCategory
    var classification: TargetClassification

    var coordinate: CLLocationCoordinate2D?
    var altitudeFeet: Int?
    var isOnGround: Bool

    var heading: Double?
    var groundSpeedKnots: Double?
    var verticalRateFPM: Int?

    var previousCoordinate: CLLocationCoordinate2D?
    var lastPositionTime: Date?

    var squawk: String?
    var signalStrength: Double?
    var lastSeen: Date
    var source: String

    var age: TimeInterval {
        Date.now.timeIntervalSince(lastSeen)
    }

    var opacity: Double {
        let seconds = age
        if seconds < 15 { return 1.0 }
        if seconds > 120 { return 0.0 }
        return max(0.3, 1.0 - (seconds - 15) / 105.0)
    }

    var displayName: String {
        callsign?.trimmingCharacters(in: .whitespaces) ?? registration ?? id.uppercased()
    }

    nonisolated func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: Target, rhs: Target) -> Bool {
        lhs.id == rhs.id
    }
}

extension CLLocationCoordinate2D: @retroactive Hashable {
    nonisolated public func hash(into hasher: inout Hasher) {
        hasher.combine(latitude)
        hasher.combine(longitude)
    }

    public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
}
