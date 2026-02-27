nonisolated enum AltitudeValue: Codable, Sendable, Equatable {
    case altitude(Int)
    case ground

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let intValue = try? container.decode(Int.self) {
            self = .altitude(intValue)
        } else if let strValue = try? container.decode(String.self),
                  strValue == "ground" {
            self = .ground
        } else {
            self = .altitude(0)
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .altitude(let ft): try container.encode(ft)
        case .ground: try container.encode("ground")
        }
    }
}
