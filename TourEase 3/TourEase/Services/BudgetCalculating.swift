import Foundation

protocol BudgetCalculating {
    func calculate(_ input: BudgetInput) -> BudgetBreakdown
}

/// Pure calculation, no I/O — easy to unit test and safe to call on every
/// keystroke/slider change without debouncing.
final class DefaultBudgetCalculator: BudgetCalculating {
    private let pricing: BudgetPricingProviding

    init(pricing: BudgetPricingProviding = PersistedBudgetPricingProvider()) {
        self.pricing = pricing
    }

    func calculate(_ input: BudgetInput) -> BudgetBreakdown {
        let days = Double(max(input.tripDays, 1))

        let hotelCost = pricing.hotelRatePerNight(input.hotelCategory) * days
        let foodCost = pricing.foodRatePerDay(input.foodPreference) * days

        let dailyTransport =
            pricing.usesPerDay(input.taxiUsage) * pricing.transportRatePerUse(.taxi) +
            pricing.usesPerDay(input.autoUsage) * pricing.transportRatePerUse(.auto) +
            pricing.usesPerDay(input.metroUsage) * pricing.transportRatePerUse(.metro)
        let transportCost = dailyTransport * days

        let shoppingCost = max(input.shoppingBudget, 0)
        let activitiesCost = max(input.activitiesBudget, 0)

        let subtotal = hotelCost + foodCost + transportCost + shoppingCost + activitiesCost
        let miscCost = subtotal * (max(input.emergencyBufferPercent, 0) / 100)

        return BudgetBreakdown(
            hotelCost: hotelCost,
            foodCost: foodCost,
            transportCost: transportCost,
            shoppingCost: shoppingCost,
            activitiesCost: activitiesCost,
            miscCost: miscCost
        )
    }
}
