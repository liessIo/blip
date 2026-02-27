import SwiftUI
import MapKit

struct TrackingMapView: View {
    @Environment(TargetStore.self) var store
    @Environment(MapInteractionState.self) var mapState
    @Environment(AppCoordinator.self) var coordinator

    var body: some View {
        @Bindable var mapState = mapState

        Map(position: $mapState.cameraPosition) {
            UserAnnotation()

            ForEach(displayTargets) { target in
                if let coord = target.coordinate {
                    Annotation(
                        target.displayName,
                        coordinate: coord
                    ) {
                        TargetAnnotationView(target: target)
                            .onTapGesture {
                                store.selectedTargetID = target.id
                            }
                    }
                    .annotationTitles(.hidden)
                }
            }
        }
        .mapStyle(.standard(elevation: .realistic))
        .mapControls {
            MapCompass()
            MapScaleView()
        }
        .onMapCameraChange(frequency: .onEnd) { context in
            mapState.onCameraChange(context) { center, radius in
                coordinator.updateRegion(center: center, radiusNM: radius, store: store)
            }
        }
        .sheet(item: Binding(
            get: { store.selectedTarget },
            set: { _ in store.selectedTargetID = nil }
        )) { target in
            TargetDetailView(target: target)
                .presentationDetents([.medium, .large])
        }
    }

    private var displayTargets: [Target] {
        let visible = store.visibleTargets.filter { $0.coordinate != nil }
        if visible.count <= AppConstants.maxAnnotations {
            return visible
        }
        guard let center = mapState.visibleCenter else {
            return Array(visible.prefix(AppConstants.maxAnnotations))
        }
        let centerLoc = CLLocation(latitude: center.latitude, longitude: center.longitude)
        return Array(
            visible
                .sorted { t1, t2 in
                    let d1 = CLLocation(latitude: t1.coordinate!.latitude, longitude: t1.coordinate!.longitude)
                        .distance(from: centerLoc)
                    let d2 = CLLocation(latitude: t2.coordinate!.latitude, longitude: t2.coordinate!.longitude)
                        .distance(from: centerLoc)
                    return d1 < d2
                }
                .prefix(AppConstants.maxAnnotations)
        )
    }
}
