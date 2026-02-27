nonisolated struct ADSBResponse: Codable, Sendable {
    let ac: [Aircraft]?
    let msg: String?
    let now: Int64?
    let total: Int?
    let ctime: Int64?
    let ptime: Int?

    nonisolated struct Aircraft: Codable, Sendable {
        // Identity
        let hex: String
        let type: String?
        let flight: String?
        let r: String?
        let t: String?

        // Position
        let lat: Double?
        let lon: Double?
        let seenPos: Double?

        // Altitude
        let altBaro: AltitudeValue?
        let altGeom: Int?

        // Speed
        let gs: Double?
        let ias: Int?
        let tas: Int?
        let mach: Double?

        // Heading / Track
        let track: Double?
        let trackRate: Double?
        let magHeading: Double?
        let trueHeading: Double?
        let roll: Double?

        // Vertical Rate
        let baroRate: Int?
        let geomRate: Int?

        // Squawk / Status
        let squawk: String?
        let emergency: String?
        let category: String?
        let alert: Int?
        let spi: Int?

        // Navigation
        let navQnh: Double?
        let navAltitudeMcp: Int?
        let navAltitudeFms: Int?
        let navHeading: Double?

        // Signal / Quality
        let nic: Int?
        let rc: Int?
        let version: Int?
        let nicBaro: Int?
        let nacP: Int?
        let nacV: Int?
        let sil: Int?
        let silType: String?
        let gva: Int?
        let sda: Int?

        // Message stats
        let messages: Int?
        let seen: Double?
        let rssi: Double?

        // Relative position
        let dst: Double?
        let dir: Double?

        // Source flags
        let mlat: [String]?
        let tisb: [String]?

        // Database flags
        let dbFlags: Int?

        enum CodingKeys: String, CodingKey {
            case hex, type, flight, r, t
            case lat, lon
            case seenPos = "seen_pos"
            case altBaro = "alt_baro"
            case altGeom = "alt_geom"
            case gs, ias, tas, mach
            case track
            case trackRate = "track_rate"
            case magHeading = "mag_heading"
            case trueHeading = "true_heading"
            case roll
            case baroRate = "baro_rate"
            case geomRate = "geom_rate"
            case squawk, emergency, category, alert, spi
            case navQnh = "nav_qnh"
            case navAltitudeMcp = "nav_altitude_mcp"
            case navAltitudeFms = "nav_altitude_fms"
            case navHeading = "nav_heading"
            case nic, rc, version
            case nicBaro = "nic_baro"
            case nacP = "nac_p"
            case nacV = "nac_v"
            case sil
            case silType = "sil_type"
            case gva, sda
            case messages, seen, rssi
            case dst, dir
            case mlat, tisb
            case dbFlags = "dbFlags"
        }
    }
}
