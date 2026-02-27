import Testing
import CoreLocation
@testable import Blip

@Suite("Target Store")
struct TargetStoreTests {

    private func makeTarget(id: String, category: TargetCategory = .air) -> Target {
        Target(
            id: id,
            callsign: "TEST",
            registration: nil,
            typeDesignator: nil,
            category: category,
            classification: .unknown,
            coordinate: CLLocationCoordinate2D(latitude: 50.0, longitude: 8.0),
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

    @Test("Applies added targets from delta")
    @MainActor
    func appliesAddedTargets() {
        let store = TargetStore()
        let delta = TargetDelta(
            added: [makeTarget(id: "aaa"), makeTarget(id: "bbb")],
            updated: [],
            removed: [],
            timestamp: .now
        )

        store.applyDelta(delta)
        #expect(store.targetCount == 2)
        #expect(store.targets["aaa"] != nil)
        #expect(store.targets["bbb"] != nil)
    }

    @Test("Applies updated targets from delta")
    @MainActor
    func appliesUpdatedTargets() {
        let store = TargetStore()

        // Add first
        store.applyDelta(TargetDelta(
            added: [makeTarget(id: "aaa")],
            updated: [],
            removed: [],
            timestamp: .now
        ))

        // Update
        var updated = makeTarget(id: "aaa")
        updated.altitudeFeet = 20000
        store.applyDelta(TargetDelta(
            added: [],
            updated: [updated],
            removed: [],
            timestamp: .now
        ))

        #expect(store.targetCount == 1)
    }

    @Test("Removes targets from delta")
    @MainActor
    func removesTargets() {
        let store = TargetStore()

        store.applyDelta(TargetDelta(
            added: [makeTarget(id: "aaa"), makeTarget(id: "bbb")],
            updated: [],
            removed: [],
            timestamp: .now
        ))

        store.applyDelta(TargetDelta(
            added: [],
            updated: [],
            removed: ["aaa"],
            timestamp: .now
        ))

        #expect(store.targetCount == 1)
        #expect(store.targets["aaa"] == nil)
        #expect(store.targets["bbb"] != nil)
    }

    @Test("Clears selected target when removed")
    @MainActor
    func clearsSelectedOnRemove() {
        let store = TargetStore()
        store.applyDelta(TargetDelta(
            added: [makeTarget(id: "aaa")],
            updated: [],
            removed: [],
            timestamp: .now
        ))
        store.selectedTargetID = "aaa"

        store.applyDelta(TargetDelta(
            added: [],
            updated: [],
            removed: ["aaa"],
            timestamp: .now
        ))

        #expect(store.selectedTargetID == nil)
    }

    @Test("Filters by category")
    @MainActor
    func filtersByCategory() {
        let store = TargetStore()
        store.applyDelta(TargetDelta(
            added: [
                makeTarget(id: "plane1", category: .air),
                makeTarget(id: "plane2", category: .air),
                makeTarget(id: "ship1", category: .sea),
            ],
            updated: [],
            removed: [],
            timestamp: .now
        ))

        store.filterMode = .air
        #expect(store.visibleTargets.count == 2)

        store.filterMode = .sea
        #expect(store.visibleTargets.count == 1)

        store.filterMode = .all
        #expect(store.visibleTargets.count == 3)
    }
}
