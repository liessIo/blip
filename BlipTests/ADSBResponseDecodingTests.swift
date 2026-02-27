import Foundation
import Testing
@testable import Blip

@Suite("ADS-B Response Decoding")
struct ADSBResponseDecodingTests {

    @Test("Decodes typical aircraft with all fields")
    func decodesFullAircraft() throws {
        let json = """
        {
            "ac": [{
                "hex": "3c6752",
                "type": "adsb_icao",
                "flight": "DLH1A  ",
                "r": "D-AIMA",
                "t": "A388",
                "lat": 50.11,
                "lon": 8.68,
                "seen_pos": 0.4,
                "alt_baro": 35000,
                "alt_geom": 35200,
                "gs": 480.2,
                "track": 270.5,
                "baro_rate": -64,
                "squawk": "1000",
                "emergency": "none",
                "category": "A5",
                "messages": 1234,
                "seen": 0.2,
                "rssi": -3.5,
                "dst": 12.5,
                "dir": 180.0
            }],
            "msg": "No error",
            "now": 1700000000000,
            "total": 1,
            "ctime": 1700000000000,
            "ptime": 5
        }
        """.data(using: .utf8)!

        let response = try JSONDecoder().decode(ADSBResponse.self, from: json)
        #expect(response.ac?.count == 1)

        let ac = try #require(response.ac?.first)
        #expect(ac.hex == "3c6752")
        #expect(ac.flight == "DLH1A  ")
        #expect(ac.r == "D-AIMA")
        #expect(ac.t == "A388")
        #expect(ac.lat == 50.11)
        #expect(ac.lon == 8.68)
        #expect(ac.altBaro == .altitude(35000))
        #expect(ac.gs == 480.2)
        #expect(ac.track == 270.5)
        #expect(ac.squawk == "1000")
    }

    @Test("Decodes alt_baro as 'ground'")
    func decodesGroundAltitude() throws {
        let json = """
        {
            "ac": [{
                "hex": "abc123",
                "alt_baro": "ground",
                "messages": 10,
                "seen": 1.0,
                "rssi": -10.0
            }],
            "msg": "No error",
            "now": 1700000000000,
            "total": 1,
            "ctime": 1700000000000,
            "ptime": 1
        }
        """.data(using: .utf8)!

        let response = try JSONDecoder().decode(ADSBResponse.self, from: json)
        let ac = try #require(response.ac?.first)
        #expect(ac.altBaro == .ground)
    }

    @Test("Handles missing optional fields gracefully")
    func handlesMissingOptionalFields() throws {
        let json = """
        {
            "ac": [{
                "hex": "def456"
            }]
        }
        """.data(using: .utf8)!

        let response = try JSONDecoder().decode(ADSBResponse.self, from: json)
        let ac = try #require(response.ac?.first)
        #expect(ac.hex == "def456")
        #expect(ac.flight == nil)
        #expect(ac.lat == nil)
        #expect(ac.altBaro == nil)
        #expect(ac.squawk == nil)
    }

    @Test("Decodes empty aircraft array")
    func decodesEmptyArray() throws {
        let json = """
        {
            "ac": [],
            "msg": "No error",
            "now": 1700000000000,
            "total": 0,
            "ctime": 1700000000000,
            "ptime": 0
        }
        """.data(using: .utf8)!

        let response = try JSONDecoder().decode(ADSBResponse.self, from: json)
        #expect(response.ac?.isEmpty == true)
        #expect(response.total == 0)
    }
}
