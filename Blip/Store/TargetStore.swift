import SwiftUI
import Observation

nonisolated enum FilterMode: String, CaseIterable, Sendable {
    case all = "All"
    case air = "Air"
    case sea = "Sea"

    var icon: String {
        switch self {
        case .all: "shuffle"
        case .air: "airplane"
        case .sea: "ferry"
        }
    }
}

@Observable
final class TargetStore {
    private(set) var targets: [String: Target] = [:]
    var filterMode: FilterMode = .air
    var selectedTargetID: String?
    var isLoading: Bool = false
    var lastError: String?
    var lastUpdateTime: Date?

    var visibleTargets: [Target] {
        let values = targets.values
        switch filterMode {
        case .all: return Array(values)
        case .air: return values.filter { $0.category == .air }
        case .sea: return values.filter { $0.category == .sea }
        }
    }

    var targetCount: Int { targets.count }

    var selectedTarget: Target? {
        guard let id = selectedTargetID else { return nil }
        return targets[id]
    }

    func applyDelta(_ delta: TargetDelta) {
        for target in delta.added {
            targets[target.id] = target
        }
        for target in delta.updated {
            targets[target.id] = target
        }
        for id in delta.removed {
            targets.removeValue(forKey: id)
            if selectedTargetID == id {
                selectedTargetID = nil
            }
        }
        lastUpdateTime = delta.timestamp
        lastError = nil
        isLoading = false
    }

    func setError(_ message: String) {
        lastError = message
        isLoading = false
    }
}
