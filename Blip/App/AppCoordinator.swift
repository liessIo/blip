import CoreLocation

@Observable
final class AppCoordinator {
    private let fusionActor = TargetFusionActor()
    private let adsbProvider = ADSBProvider()
    private var pollingTask: Task<Void, Never>?

    var isPolling: Bool = false

    func start(store: TargetStore, mapState: MapInteractionState) async {
        await fusionActor.setDeltaHandler { @Sendable [weak store] delta in
            Task { @MainActor in
                store?.applyDelta(delta)
            }
        }

        let center = mapState.visibleCenter ?? CLLocationCoordinate2D(latitude: 50.0, longitude: 10.0)
        startPolling(center: center, radiusNM: mapState.visibleRadiusNM, store: store)
    }

    func startPolling(center: CLLocationCoordinate2D, radiusNM: Double, store: TargetStore) {
        pollingTask?.cancel()
        isPolling = true
        store.isLoading = true

        pollingTask = Task {
            do {
                try await adsbProvider.startPolling(
                    center: center,
                    radiusNM: radiusNM
                ) { @Sendable [fusionActor] targets in
                    Task {
                        await fusionActor.ingest(targets, from: "adsb.lol")
                    }
                }
            } catch {
                if !Task.isCancelled {
                    await MainActor.run {
                        store.setError(error.localizedDescription)
                    }
                }
            }
            await MainActor.run {
                store.isLoading = false
                isPolling = false
            }
        }
    }

    func updateRegion(center: CLLocationCoordinate2D, radiusNM: Double, store: TargetStore) {
        startPolling(center: center, radiusNM: radiusNM, store: store)
    }
}
