import Foundation

/// No free, official average-meal-cost API exists on iOS — same situation
/// as hotel pricing. Documented mock, designed for the Admin Portal's
/// future "Manage Food Pricing" screen (Part 11) to override without
/// touching `FoodViewModel` or any view.
protocol FoodPricingProviding {
    func averageCost(_ category: FoodCategory) -> Double
}

struct DefaultFoodPricingProvider: FoodPricingProviding {
    func averageCost(_ category: FoodCategory) -> Double {
        switch category {
        case .breakfast: return 150
        case .lunch: return 350
        case .dinner: return 450
        case .streetFood: return 120
        case .restaurant: return 500
        case .cafe: return 250
        }
    }
}
