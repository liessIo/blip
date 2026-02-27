import SwiftUI

@main
struct BlipApp: App {
    @State private var targetStore = TargetStore()
    @State private var mapState = MapInteractionState()
    @State private var coordinator = AppCoordinator()
    @State private var locationManager = LocationManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(targetStore)
                .environment(mapState)
                .environment(coordinator)
                .environment(locationManager)
                .task {
                    locationManager.requestPermission()
                    await coordinator.start(store: targetStore, mapState: mapState)
                }
        }
    }
}
