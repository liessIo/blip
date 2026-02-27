import SwiftUI

nonisolated enum TargetClassification: String, Sendable, CaseIterable {
    case civilian
    case military
    case government
    case unknown

    var color: Color {
        switch self {
        case .civilian: .blue
        case .military: .red
        case .government: .orange
        case .unknown: .gray
        }
    }
}
