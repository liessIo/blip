import Testing
import CoreLocation
@testable import Blip

private actor DeltaCapture {
    var value: TargetDelta?

    func capture(_ delta: TargetDelta) {
        value = delta
    }
}

@Suite("Target Fusion Actor")
struct TargetFusionActorTests {

    private func makeTarget(id: String, lat: Double = 50.0, lon: Double = 8.0) -> Target {
        Target(
            id: id,
            callsign: "TEST",
            registration: nil,
            typeDesignator: nil,
            category: .air,
            classification: .unknown,
            coordinate: CLLocationCoordinate2D(latitude: lat, longitude: lon),
            altitudeFeet: 10000,
            isOnGround: false,
            heading: 90,
            groundSpeedKnots: 400,
            verticalRateFPM: 0,
            previousCoordinate: nil,
            lastPositionTime: nil,
            squawk: nil,
            signalStrength: nil,
            lastSeen: .now,
            source: "test"
        )
    }

    @Test("Ingests new targets and reports them as added")
    func ingestsNewTargets() async {
        let fusionActor = TargetFusionActor()
        let capture = DeltaCapture()

        await fusionActor.setDeltaHandler { delta in
            Task { await capture.capture(delta) }
        }

        let targets = [makeTarget(id: "aaa"), makeTarget(id: "bbb")]
        await fusionActor.ingest(targets, from: "test")

        // Give the Task a moment to complete
        try? await Task.sleep(for: .milliseconds(50))

        let delta = await capture.value
        #expect(delta?.added.count == 2)
        #expect(delta?.updated.isEmpty == true)
        #expect(delta?.removed.isEmpty == true)
        #expect(await fusionActor.count() == 2)
    }

    @Test("Updates existing targets and reports them as updated")
    func updatesExistingTargets() async {
        let fusionActor = TargetFusionActor()
        let capture = DeltaCapture()

        await fusionActor.setDeltaHandler { delta in
            Task { await capture.capture(delta) }
        }

        await fusionActor.ingest([makeTarget(id: "aaa")], from: "test")

        var updated = makeTarget(id: "aaa", lat: 51.0)
        updated.altitudeFeet = 20000
        await fusionActor.ingest([updated], from: "test")

        try? await Task.sleep(for: .milliseconds(50))

        let delta = await capture.value
        #expect(delta?.updated.count == 1)
        #expect(delta?.added.isEmpty == true)
    }

    @Test("Preserves previous coordinate on update")
    func preservesPreviousCoordinate() async {
        let fusionActor = TargetFusionActor()
        let capture = DeltaCapture()

        await fusionActor.setDeltaHandler { delta in
            Task { await capture.capture(delta) }
        }

        await fusionActor.ingest([makeTarget(id: "aaa", lat: 50.0, lon: 8.0)], from: "test")
        await fusionActor.ingest([makeTarget(id: "aaa", lat: 51.0, lon: 9.0)], from: "test")

        try? await Task.sleep(for: .milliseconds(50))

        let delta = await capture.value
        let updatedTarget = delta?.updated.first
        #expect(updatedTarget?.previousCoordinate?.latitude == 50.0)
        #expect(updatedTarget?.previousCoordinate?.longitude == 8.0)
    }

    @Test("Reports correct total count")
    func reportsCorrectCount() async {
        let fusionActor = TargetFusionActor()
        await fusionActor.setDeltaHandler { _ in }

        await fusionActor.ingest([makeTarget(id: "a"), makeTarget(id: "b"), makeTarget(id: "c")], from: "test")
        #expect(await fusionActor.count() == 3)

        await fusionActor.ingest([makeTarget(id: "d")], from: "test")
        #expect(await fusionActor.count() == 4)
    }
}
