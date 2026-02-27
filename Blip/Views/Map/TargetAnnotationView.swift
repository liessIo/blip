import SwiftUI

struct TargetAnnotationView: View {
    let target: Target

    var body: some View {
        VStack(spacing: 2) {
            Image(systemName: iconName)
                .font(.system(size: 20))
                .foregroundStyle(target.classification.color)
                .rotationEffect(.degrees(target.heading ?? 0))
                .opacity(target.opacity)

            if target.callsign != nil {
                Text(target.displayName)
                    .font(.caption2)
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                    .opacity(target.opacity)
            }
        }
    }

    private var iconName: String {
        switch target.category {
        case .air:
            target.isOnGround ? "airplane.circle" : "airplane"
        case .sea:
            "ferry"
        }
    }
}
