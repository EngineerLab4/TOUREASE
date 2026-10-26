import SwiftUI

/// Shown for any `DashboardDestination` whose real screen hasn't been built
/// yet (`isImplemented == false`). Keeps every card in the dashboard fully
/// tappable and navigable from day one instead of dead-ending, and gets
/// swapped out one destination at a time as each module lands — no changes
/// needed here or in `DashboardView` when that happens beyond adding the
/// new case to the `navigationDestination` switch.
struct ComingSoonView: View {
    let destination: DashboardDestination

    var body: some View {
        ZStack {
            AnimatedBackground()
            VStack(spacing: 18) {
                ZStack {
                    Circle()
                        .fill(destination.accentGradient)
                        .frame(width: 72, height: 72)
                        .shadow(color: .black.opacity(0.3), radius: 14, x: 0, y: 6)
                    Image(systemName: destination.systemImage)
                        .font(.system(size: 28, weight: .semibold))
                        .foregroundStyle(.white)
                }

                Text(destination.title)
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)

                Text("This module is coming up next in the build. The card, navigation, and screen shell are already wired — only the feature logic is left.")
                    .font(.system(size: 13.5, design: .rounded))
                    .foregroundStyle(Color.touroTextMuted)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 44)
            }
            .padding(.vertical, 40)
        }
        .navigationTitle(destination.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
        .preferredColorScheme(.dark)
    }
}

#Preview {
    NavigationStack {
        ComingSoonView(destination: .budgetPlanner)
    }
}
