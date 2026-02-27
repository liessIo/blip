import SwiftUI

struct ContentView: View {
    @Environment(TargetStore.self) var store

    var body: some View {
        TabView {
            Tab("Map", systemImage: "map") {
                MapTab()
            }

            Tab("List", systemImage: "list.bullet") {
                ListTab()
            }

            Tab("Dashboard", systemImage: "chart.bar") {
                DashboardTab()
            }

            Tab("Settings", systemImage: "gear") {
                SettingsTab()
            }
        }
    }
}

// MARK: - Map Tab

struct MapTab: View {
    @Environment(TargetStore.self) var store
    @Environment(MapInteractionState.self) var mapState
    @Environment(AppCoordinator.self) var coordinator

    var body: some View {
        ZStack {
            TrackingMapView()

            VStack {
                StatusBarView()
                    .padding(.horizontal)
                    .padding(.top, 8)

                Spacer()

                FilterPillsView()
                    .padding(.bottom, 16)
            }
        }
    }
}

// MARK: - List Tab (stub)

struct ListTab: View {
    @Environment(TargetStore.self) var store

    var body: some View {
        NavigationStack {
            List(store.visibleTargets) { target in
                NavigationLink {
                    TargetDetailView(target: target)
                } label: {
                    TargetRowView(target: target)
                }
            }
            .navigationTitle("Targets")
            .overlay {
                if store.visibleTargets.isEmpty {
                    ContentUnavailableView(
                        "No Targets",
                        systemImage: "airplane.slash",
                        description: Text("Targets will appear when data is available.")
                    )
                }
            }
        }
    }
}

struct TargetRowView: View {
    let target: Target

    var body: some View {
        HStack {
            Image(systemName: target.category == .air ? "airplane" : "ferry")
                .foregroundStyle(target.classification.color)
                .rotationEffect(.degrees(target.heading ?? 0))
                .frame(width: 30)

            VStack(alignment: .leading) {
                Text(target.displayName)
                    .font(.headline)
                HStack(spacing: 8) {
                    if let alt = target.altitudeFeet {
                        Text("\(alt) ft")
                    }
                    if let speed = target.groundSpeedKnots {
                        Text("\(Int(speed)) kts")
                    }
                    if let type = target.typeDesignator {
                        Text(type)
                            .foregroundStyle(.secondary)
                    }
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }

            Spacer()

            if target.classification == .military {
                Image(systemName: "shield.fill")
                    .foregroundStyle(.red)
                    .font(.caption)
            }
        }
        .opacity(target.opacity)
    }
}

// MARK: - Dashboard Tab (placeholder)

struct DashboardTab: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Image(systemName: "chart.bar.xaxis.ascending")
                    .font(.system(size: 60))
                    .foregroundStyle(.secondary)
                Text("Dashboard coming soon")
                    .font(.title2)
                Text("Stats, insights & more")
                    .foregroundStyle(.secondary)
            }
            .navigationTitle("Dashboard")
        }
    }
}

// MARK: - Settings Tab (stub)

struct SettingsTab: View {
    @Environment(TargetStore.self) var store
    @Environment(AppCoordinator.self) var coordinator

    var body: some View {
        NavigationStack {
            List {
                Section("Sources") {
                    HStack {
                        Text("adsb.lol")
                        Spacer()
                        Image(systemName: coordinator.isPolling ? "circle.fill" : "circle")
                            .foregroundStyle(coordinator.isPolling ? .green : .red)
                            .font(.caption)
                        Text(coordinator.isPolling ? "Live" : "Offline")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                Section("Display") {
                    LabeledContent("Targets in memory", value: "\(store.targetCount)")
                    if let lastUpdate = store.lastUpdateTime {
                        LabeledContent("Last update", value: lastUpdate.formatted(.dateTime.hour().minute().second()))
                    }
                }

                Section("About") {
                    LabeledContent("Version", value: "1.0.0")
                    Text("Data provided as-is from publicly broadcast ADS-B and AIS signals. No guarantee of accuracy or completeness.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Settings")
        }
    }
}
