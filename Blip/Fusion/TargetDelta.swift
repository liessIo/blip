import Foundation

nonisolated struct TargetDelta: Sendable {
    let added: [Target]
    let updated: [Target]
    let removed: Set<String>
    let timestamp: Date

    var isEmpty: Bool {
        added.isEmpty && updated.isEmpty && removed.isEmpty
    }
}
