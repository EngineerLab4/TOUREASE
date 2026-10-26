import Foundation

/// Assigns a price tier, price, and rating to a hotel MapKit can't tell us
/// the price tier or star rating of. Deterministic (seeded by the hotel's
/// name+address) so the same place always gets the same category/price/
/// rating across searches, rather than re-randomizing every launch.
protocol HotelEstimating {
    func estimate(name: String, address: String) -> (category: HotelCategory, price: Double, rating: Double)
}

struct DefaultHotelEstimator: HotelEstimating {
    private let pricing: BudgetPricingProviding

    init(pricing: BudgetPricingProviding = PersistedBudgetPricingProvider()) {
        self.pricing = pricing
    }

    func estimate(name: String, address: String) -> (category: HotelCategory, price: Double, rating: Double) {
        var hasher = Hasher()
        hasher.combine(name)
        hasher.combine(address)
        let seed = abs(hasher.finalize())

        let categories = HotelCategory.allCases
        let category = categories[seed % categories.count]

        // ±15% jitter around the category's base nightly rate so a results
        // list of the same category isn't all identically priced.
        let baseRate = pricing.hotelRatePerNight(category)
        let jitterPercent = Double(seed % 31) - 15 // -15...+15
        let price = baseRate * (1 + jitterPercent / 100)

        // Rating in a plausible 3.4–4.9 band.
        let rating = 3.4 + Double(seed % 16) / 10.0

        return (category, price.rounded(), min(rating, 4.9))
    }
}
