import SwiftUI

struct FilterPillsView: View {
    @Environment(TargetStore.self) var store

    var body: some View {
        HStack(spacing: 12) {
            ForEach(FilterMode.allCases, id: \.self) { mode in
                FilterPill(mode: mode, isSelected: store.filterMode == mode) {
                    withAnimation(.spring(duration: 0.3)) {
                        store.filterMode = mode
                    }
                }
            }
        }
    }
}

private struct FilterPill: View {
    let mode: FilterMode
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Label(mode.rawValue, systemImage: mode.icon)
                .font(.subheadline.weight(.medium))
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
        }
        .buttonStyle(.plain)
        .background(pillBackground, in: Capsule())
        .overlay(Capsule().strokeBorder(isSelected ? .blue : .clear, lineWidth: 1))
    }

    private var pillBackground: some ShapeStyle {
        isSelected ? AnyShapeStyle(.blue.opacity(0.3)) : AnyShapeStyle(.ultraThinMaterial)
    }
}
