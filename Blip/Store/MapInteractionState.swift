import SwiftUI
import MapKit

@Observable
final class MapInteractionState {
    var cameraPosition: MapCameraPosition = .userLocation(
        fallback: .region(MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 50.0, longitude: 10.0),
            span: MKCoordinateSpan(latitudeDelta: 2.0, longitudeDelta: 2.0)
        ))
    )

    var visibleCenter: CLLocationCoordinate2D?
    var visibleRadiusNM: Double = AppConstants.defaultRadiusNM

    private var debounceTask: Task<Void, Never>?

    func onCameraChange(
        _ context: MapCameraUpdateContext,
        onStable: @escaping (CLLocationCoordinate2D, Double) -> Void
    ) {
        debounceTask?.cancel()
        debounceTask = Task {
            try? await Task.sleep(for: .milliseconds(AppConstants.debounceMilliseconds))
            guard !Task.isCancelled else { return }

            let center = context.region.center
            let spanDeg = max(context.region.span.latitudeDelta, context.region.span.longitudeDelta)
            let radiusNM = min(spanDeg * 60.0 / 2.0, 250)

            self.visibleCenter = center
            self.visibleRadiusNM = radiusNM
            onStable(center, radiusNM)
        }
    }
}
