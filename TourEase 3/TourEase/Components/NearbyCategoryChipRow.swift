import SwiftUI

/// For option sets too large to lay out evenly across the screen width
/// (9 categories here vs. `PillSegmentedControl`'s 2–4). Horizontally
/// scrolling capsule chips instead of a fixed-width grid.
struct NearbyCategoryChipRow: View {
    let selection: NearbyCategory
    let onSelect: (NearbyCategory) -> Void
    @Namespace private var selectionNamespace

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(NearbyCategory.allCases) { category in
                    Button {
                        onSelect(category)
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: category.systemImage)
                                .font(.system(size: 11.5))
                            Text(category.displayName)
                                .font(.system(size: 12.5, weight: .semibold, design: .rounded))
                        }
                        .foregroundStyle(selection == category ? .white : Color.touroTextMuted)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 9)
                        .background {
                            if selection == category {
                                Capsule()
                                    .fill(LinearGradient.touroCTA)
                                    .matchedGeometryEffect(id: "chip", in: selectionNamespace)
                            } else {
                                Capsule()
                                    .fill(Color.white.opacity(0.06))
                                    .overlay(Capsule().stroke(Color.touroGlassStroke, lineWidth: 1))
                            }
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 20)
        }
        .animation(.spring(response: 0.32, dampingFraction: 0.8), value: selection)
    }
}
