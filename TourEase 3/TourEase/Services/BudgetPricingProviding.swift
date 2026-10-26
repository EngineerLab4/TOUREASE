import Foundation

/// Per-category rates behind the Budget Planner. No live pricing API exists
/// for Indian hotel/food/local-transport averages on iOS, so — same pattern
/// as `TransportPricingProviding` — this is a documented mock provider,
/// designed to be swapped for a Firestore-backed one edited from the Admin
/// Portal's "Manage Hotel Pricing" / "Manage Food Pricing" / "Manage
/// Transport Pricing" screens (Part 11) without touching
/// `BudgetCalculating` or any view.
protocol BudgetPricingProviding {
    func hotelRatePerNight(_ category: HotelCategory) -> Double
    func foodRatePerDay(_ preference: FoodPreference) -> Double
    func transportRatePerUse(_ mode: BudgetTransportMode) -> Double
    func usesPerDay(_ level: UsageLevel) -> Double
}

struct DefaultBudgetPricingProvider: BudgetPricingProviding {
    func hotelRatePerNight(_ category: HotelCategory) -> Double {
        switch category {
        case .budget: return 900
        case .standard: return 2200
        case .premium: return 4500
        case .luxury: return 9000
        }
    }

    func foodRatePerDay(_ preference: FoodPreference) -> Double {
        switch preference {
        case .streetFood: return 300
        case .budgetDining: return 600
        case .standardDining: return 1100
        case .fineDining: return 2200
        }
    }

    func transportRatePerUse(_ mode: BudgetTransportMode) -> Double {
        switch mode {
        case .taxi: return 150
        case .auto: return 70
        case .metro: return 25
        }
    }

    /// Average number of rides per day at each usage level.
    func usesPerDay(_ level: UsageLevel) -> Double {
        switch level {
        case .none: return 0
        case .low: return 1
        case .medium: return 3
        case .high: return 6
        }
    }
}
