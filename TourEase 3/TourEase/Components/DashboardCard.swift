import SwiftUI

/// A single tappable card in the Home Dashboard grid. Reuses the app's glass
/// styling (`glassCardStyle`) rather than introducing a new visual language.
/// Handles its own press-down scale feedback and a staggered fade/slide-in
/// entrance driven by `appearIndex`.
struct DashboardCard: View {
    let destination: DashboardDestination
    var appearIndex: Int = 0

    @State private var isPressed = false
    @State private var hasAppeared = false

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            ZStack {
                Circle()
                    .fill(destination.accentGradient)
                    .frame(width: 44, height: 44)
                    .shadow(color: .black.opacity(0.25), radius: 8, x: 0, y: 4)
                Image(systemName: destination.systemImage)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(.white)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(destination.title)
                    .font(.system(size: 14.5, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color.touroTextPrimary)
                    .lineLimit(1)
                Text(destination.subtitle)
                    .font(.system(size: 11.5, design: .rounded))
                    .foregroundStyle(Color.touroTextMuted)
                    .lineLimit(1)
            }

            Spacer(minLength: 0)
        }
        .padding(16)
        .frame(height: 128, alignment: .top)
        .frame(maxWidth: .infinity)
        .glassCardStyle(cornerRadius: 20)
        .scaleEffect(isPressed ? 0.95 : 1)
        .opacity(hasAppeared ? 1 : 0)
        .offset(y: hasAppeared ? 0 : 16)
        .accessibilityElement(children: .combine)
        .animation(.spring(response: 0.35, dampingFraction: 0.7), value: isPressed)
        .onAppear {
            withAnimation(.easeOut(duration: 0.45).delay(Double(appearIndex) * 0.05)) {
                hasAppeared = true
            }
        }
        .onLongPressGesture(minimumDuration: .infinity, maximumDistance: .infinity) {
        } onPressingChanged: { pressing in
            isPressed = pressing
        }
    }
}

#Preview {
    ZStack {
        AnimatedBackground()
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 14) {
            ForEach(Array(DashboardDestination.allCases.enumerated()), id: \.element) { index, dest in
                DashboardCard(destination: dest, appearIndex: index)
            }
        }
        .padding(20)
    }
}
