import SwiftUI

/// Central design palette. Deep navy → teal, matching a premium travel-app mood board.
extension Color {
    nonisolated static let touroNavyDeep   = Color(red: 0.04, green: 0.08, blue: 0.16) // #0A1429
    nonisolated static let touroNavy       = Color(red: 0.07, green: 0.13, blue: 0.24) // #12213D
    nonisolated static let touroTeal       = Color(red: 0.10, green: 0.62, blue: 0.62) // #1A9E9E
    nonisolated static let touroTealLight  = Color(red: 0.24, green: 0.85, blue: 0.78) // #3EDAC7
    nonisolated static let touroSunset     = Color(red: 0.98, green: 0.55, blue: 0.35) // #FA8C59 (accent, CTAs)
    nonisolated static let touroSand       = Color(red: 0.96, green: 0.93, blue: 0.86) // light-mode surface
    nonisolated static let touroTextPrimary = Color.white
    nonisolated static let touroTextMuted   = Color.white.opacity(0.65)

    nonisolated static let touroGlassStroke = Color.white.opacity(0.18)
}

extension LinearGradient {
    /// The signature background gradient used behind every full-screen view.
    nonisolated static let touroBackground = LinearGradient(
        colors: [.touroNavyDeep, .touroNavy, Color(red: 0.05, green: 0.22, blue: 0.28)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    nonisolated static let touroCTA = LinearGradient(
        colors: [.touroTeal, .touroTealLight],
        startPoint: .leading,
        endPoint: .trailing
    )

    nonisolated static let touroAccentCTA = LinearGradient(
        colors: [.touroSunset, Color(red: 0.98, green: 0.72, blue: 0.35)],
        startPoint: .leading,
        endPoint: .trailing
    )
}
