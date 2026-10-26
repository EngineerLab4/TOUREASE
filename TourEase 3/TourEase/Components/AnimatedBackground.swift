import SwiftUI
import Combine

/// Full-screen animated backdrop: a slowly-morphing gradient plus (optionally)
/// a soft-cycling stack of travel photos with a dark blur overlay for legibility —
/// the same "jump between dialog boxes with a moving photo backdrop" effect
/// from the reference mood board, built with local/blurred assets so it's fast
/// and works offline.
///
/// Drop your own royalty-free travel photos into Resources/Backgrounds and list
/// their asset names in `imageNames` (leave empty to use gradient-only mode).
struct AnimatedBackground: View {
    var imageNames: [String] = [] // e.g. ["bg_mountains", "bg_beach", "bg_city"]
    @State private var animateGradient = false
    @State private var currentImageIndex = 0

    private let cycleTimer = Timer.publish(every: 6, on: .main, in: .common).autoconnect()

    var body: some View {
        ZStack {
            if !imageNames.isEmpty, UIImage(named: imageNames[safe: currentImageIndex] ?? "") != nil {
                Image(imageNames[currentImageIndex])
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                    .transition(.opacity.animation(.easeInOut(duration: 1.4)))
                    .id(currentImageIndex)
                    .blur(radius: 2)
                    .overlay(Color.touroNavyDeep.opacity(0.55))
            }

            LinearGradient(
                colors: [
                    Color.touroNavyDeep.opacity(0.9),
                    Color.touroNavy.opacity(animateGradient ? 0.75 : 0.55),
                    Color.touroTeal.opacity(animateGradient ? 0.35 : 0.2)
                ],
                startPoint: animateGradient ? .topLeading : .bottomTrailing,
                endPoint: animateGradient ? .bottomTrailing : .topLeading
            )
            .ignoresSafeArea()
            .animation(.easeInOut(duration: 6).repeatForever(autoreverses: true), value: animateGradient)

            // Floating soft blobs for extra depth/premium feel.
            GeometryReader { geo in
                Circle()
                    .fill(Color.touroTealLight.opacity(0.18))
                    .frame(width: geo.size.width * 0.7)
                    .blur(radius: 80)
                    .offset(x: animateGradient ? -60 : 40, y: animateGradient ? -40 : 60)
                    .animation(.easeInOut(duration: 8).repeatForever(autoreverses: true), value: animateGradient)

                Circle()
                    .fill(Color.touroSunset.opacity(0.12))
                    .frame(width: geo.size.width * 0.5)
                    .blur(radius: 90)
                    .offset(x: geo.size.width * 0.6, y: geo.size.height * 0.7)
            }
            .ignoresSafeArea()
        }
        .onAppear { animateGradient = true }
        .onReceive(cycleTimer) { _ in
            guard !imageNames.isEmpty else { return }
            withAnimation { currentImageIndex = (currentImageIndex + 1) % imageNames.count }
        }
    }
}

private extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
