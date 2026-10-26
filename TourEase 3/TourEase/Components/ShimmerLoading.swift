import SwiftUI

/// Animated diagonal-sweep highlight over a placeholder shape — the
/// "Shimmer Effects" requirement. Applied to `SkeletonBlock` rather than
/// real content.
private struct ShimmerModifier: ViewModifier {
    @State private var phase: CGFloat = -1.4

    func body(content: Content) -> some View {
        content
            .overlay(
                GeometryReader { geo in
                    LinearGradient(
                        colors: [.clear, Color.white.opacity(0.35), .clear],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .frame(width: geo.size.width * 0.6)
                    .offset(x: phase * geo.size.width)
                }
                .mask(content)
            )
            .onAppear {
                withAnimation(.linear(duration: 1.3).repeatForever(autoreverses: false)) {
                    phase = 1.4
                }
            }
    }
}

extension View {
    func shimmering() -> some View { modifier(ShimmerModifier()) }
}

/// One shimmering placeholder rectangle — the base unit "Loading Skeletons"
/// are built from.
struct SkeletonBlock: View {
    var cornerRadius: CGFloat = 8
    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .fill(Color.white.opacity(0.08))
            .shimmering()
    }
}

/// Skeleton standing in for a result row shaped like `HotelCard`/
/// `FoodPlaceCard`/`NearbyPlaceCard`/`TransportOptionCard` while their
/// real data is loading — replaces a bare `ProgressView()` spinner with a
/// preview of the content's shape, matching the glass-card language used
/// everywhere else.
struct SkeletonResultCard: View {
    var body: some View {
        HStack(spacing: 14) {
            SkeletonBlock(cornerRadius: 12).frame(width: 46, height: 46)
            VStack(alignment: .leading, spacing: 8) {
                SkeletonBlock().frame(height: 13).frame(maxWidth: 160)
                SkeletonBlock().frame(height: 11).frame(maxWidth: 110)
            }
            Spacer()
        }
        .padding(14)
        .glassCardStyle(cornerRadius: 18)
    }
}

/// A short stack of `SkeletonResultCard`s — drop-in replacement for a
/// loading spinner on any search-results screen.
struct SkeletonResultList: View {
    var count: Int = 3
    var body: some View {
        VStack(spacing: 12) {
            ForEach(0..<count, id: \.self) { _ in
                SkeletonResultCard()
            }
        }
    }
}
