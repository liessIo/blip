import Foundation

actor TargetFusionActor {
    private var targets: [String: Target] = [:]
    private var onDelta: (@Sendable (TargetDelta) -> Void)?

    func setDeltaHandler(_ handler: @escaping @Sendable (TargetDelta) -> Void) {
        self.onDelta = handler
    }

    func ingest(_ incoming: [Target], from providerID: String) {
        var added: [Target] = []
        var updated: [Target] = []

        for var target in incoming {
            if let existing = targets[target.id] {
                target.previousCoordinate = existing.coordinate
                target.lastPositionTime = Date.now
                updated.append(target)
            } else {
                target.lastPositionTime = Date.now
                added.append(target)
            }
            targets[target.id] = target
        }

        // Prune stale targets
        let now = Date.now
        let staleIDs = targets.filter {
            now.timeIntervalSince($0.value.lastSeen) > AppConstants.staleThresholdSeconds
        }.map(\.key)
        let removed = Set(staleIDs)
        for id in staleIDs {
            targets.removeValue(forKey: id)
        }

        // Enforce max target limit (evict oldest first)
        if targets.count > AppConstants.maxTargetsInMemory {
            let sorted = targets.values.sorted { $0.lastSeen < $1.lastSeen }
            let excessCount = targets.count - AppConstants.maxTargetsInMemory
            for target in sorted.prefix(excessCount) {
                targets.removeValue(forKey: target.id)
            }
        }

        let delta = TargetDelta(
            added: added,
            updated: updated,
            removed: removed,
            timestamp: now
        )

        if !delta.isEmpty {
            onDelta?(delta)
        }
    }

    func allTargets() -> [Target] {
        Array(targets.values)
    }

    func count() -> Int {
        targets.count
    }
}
