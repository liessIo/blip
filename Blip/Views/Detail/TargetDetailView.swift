import SwiftUI
import MapKit

struct TargetDetailView: View {
    let target: Target

    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack {
                        Image(systemName: target.category == .air ? "airplane" : "ferry")
                            .font(.title)
                            .foregroundStyle(target.classification.color)
                        VStack(alignment: .leading) {
                            Text(target.displayName)
                                .font(.title2.bold())
                            if let type = target.typeDesignator {
                                Text(type)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        Spacer()
                        DataAgeBadge(age: target.age)
                    }
                }

                Section("Identity") {
                    LabeledContent("ICAO Hex", value: target.id.uppercased())
                    if let callsign = target.callsign {
                        LabeledContent("Callsign", value: callsign)
                    }
                    if let reg = target.registration {
                        LabeledContent("Registration", value: reg)
                    }
                    LabeledContent("Classification", value: target.classification.rawValue.capitalized)
                    LabeledContent("Source", value: target.source)
                }

                Section("Position") {
                    if let alt = target.altitudeFeet {
                        LabeledContent("Altitude", value: "\(alt) ft")
                    }
                    if let speed = target.groundSpeedKnots {
                        LabeledContent("Ground Speed", value: "\(Int(speed)) kts")
                    }
                    if let heading = target.heading {
                        LabeledContent("Heading", value: "\(Int(heading))\u{00B0}")
                    }
                    if let vr = target.verticalRateFPM {
                        LabeledContent("Vertical Rate", value: "\(vr) fpm")
                    }
                    if target.isOnGround {
                        Label("On Ground", systemImage: "arrow.down.to.line")
                    }
                }

                if let squawk = target.squawk {
                    Section("Squawk") {
                        LabeledContent("Code", value: squawk)
                        if let meaning = squawkMeaning(squawk) {
                            Text(meaning)
                                .foregroundStyle(squawkIsEmergency(squawk) ? .red : .secondary)
                                .font(.caption)
                        }
                    }
                }

                if let coord = target.coordinate {
                    Section("Map") {
                        Map {
                            Marker(target.displayName, coordinate: coord)
                                .tint(target.classification.color)
                        }
                        .frame(height: 200)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .listRowInsets(EdgeInsets())
                    }
                }
            }
            .navigationTitle(target.displayName)
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
        }
    }

    private func squawkMeaning(_ code: String) -> String? {
        switch code {
        case "7700": "EMERGENCY — General emergency"
        case "7600": "RADIO FAILURE — Lost communications"
        case "7500": "HIJACK — Unlawful interference"
        case "7400": "UNMANNED — Drone lost link"
        default: nil
        }
    }

    private func squawkIsEmergency(_ code: String) -> Bool {
        ["7700", "7600", "7500"].contains(code)
    }
}

struct DataAgeBadge: View {
    let age: TimeInterval

    var body: some View {
        Text(ageText)
            .font(.caption2.bold())
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(ageColor.opacity(0.2), in: Capsule())
            .foregroundStyle(ageColor)
    }

    private var ageText: String {
        if age < 5 { return "LIVE" }
        if age < 60 { return "\(Int(age))s ago" }
        return "\(Int(age / 60))m ago"
    }

    private var ageColor: Color {
        if age < 15 { return .green }
        if age < 60 { return .yellow }
        return .red
    }
}
