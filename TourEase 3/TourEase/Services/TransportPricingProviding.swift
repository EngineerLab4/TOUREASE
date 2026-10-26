import Foundation

/// Fare/speed formulas per transport mode. No official free API exists on
/// iOS for bus/train schedules, taxi fares, or flight pricing, so this is a
/// documented mock provider — exactly the "clean service abstraction with
/// mock providers" the spec calls for. Swap `DefaultTransportPricingProvider`
/// for a real one (e.g. backed by Firestore, edited from the Admin Portal's
/// "Manage Transport Pricing" screen in Part 11) without touching
/// `TransportComparisonService` or any view — same protocol-swap pattern as
/// `AuthServicing`/`RouteServicing`.
///
/// Rates are illustrative INR estimates for a typical Indian city/intercity
/// context (matches the ₹ used elsewhere in the app) and are clearly labeled
/// "Estimated" in the UI — never presented as live pricing.
protocol TransportPricingProviding {
    func baseFare(for mode: TransportMode) -> Double
    func perKmRate(for mode: TransportMode) -> Double
    /// Used only for modes where a real MKDirections time isn't fetched.
    func averageSpeedKmh(for mode: TransportMode) -> Double
}

struct DefaultTransportPricingProvider: TransportPricingProviding {
    func baseFare(for mode: TransportMode) -> Double {
        switch mode {
        case .car: return 0
        case .taxi: return 60
        case .auto: return 30
        case .bike: return 0
        case .bus: return 20
        case .train: return 40
        case .flight: return 1500
        case .walking: return 0
        }
    }

    func perKmRate(for mode: TransportMode) -> Double {
        switch mode {
        case .car: return 8      // fuel-equivalent cost estimate
        case .taxi: return 16
        case .auto: return 12
        case .bike: return 3
        case .bus: return 1.5
        case .train: return 1.2
        case .flight: return 6.5
        case .walking: return 0
        }
    }

    func averageSpeedKmh(for mode: TransportMode) -> Double {
        switch mode {
        case .car: return 40
        case .taxi: return 35
        case .auto: return 28
        case .bike: return 18
        case .bus: return 30
        case .train: return 55
        case .flight: return 480
        case .walking: return 4.5
        }
    }
}
