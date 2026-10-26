import SwiftUI

struct ShakeEffect: GeometryEffect {
    var amount: CGFloat = 8
    var shakesPerUnit = 3
    var animatableData: CGFloat

    func effectValue(size: CGSize) -> ProjectionTransform {
        let translation = amount * sin(animatableData * .pi * CGFloat(shakesPerUnit))
        return ProjectionTransform(CGAffineTransform(translationX: translation, y: 0))
    }
}

extension View {
    /// Standard floating glass card styling used across the app.
    func glassCardStyle(cornerRadius: CGFloat = 24) -> some View {
        self
            .background(.ultraThinMaterial)
            .background(Color.white.opacity(0.04))
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(Color.touroGlassStroke, lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.25), radius: 20, x: 0, y: 10)
    }

    func shake(_ trigger: CGFloat) -> some View {
        modifier(ShakeEffect(animatableData: trigger))
    }
}
