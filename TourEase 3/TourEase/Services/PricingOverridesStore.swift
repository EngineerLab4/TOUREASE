import Foundation

/// Backs the Admin Portal's pricing edits. `UserDefaults` rather than
/// SwiftData deliberately — `BudgetPricingProviding`/`TransportPricingProviding`/
/// `FoodPricingProviding` are constructed as plain-struct default parameters
/// (`= DefaultBudgetPricingProvider()`) at points where no `ModelContext` is
/// available (e.g. `@State private var vm = FoodViewModel()`), so a
/// synchronous, always-available store is the right tool — same category of
/// local storage as "Settings" in Part 13, just keyed differently from the
/// `@Model` records used everywhere else in the app.
final class PricingOverridesStore {
    static let shared = PricingOverridesStore()
    private let defaults = UserDefaults.standard
    private let prefix = "pricing."

    private init() {}

    func value(for key: String) -> Double? {
        let fullKey = prefix + key
        guard defaults.object(forKey: fullKey) != nil else { return nil }
        return defaults.double(forKey: fullKey)
    }

    func setValue(_ value: Double, for key: String) {
        defaults.set(value, forKey: prefix + key)
    }

    /// Clears every override, reverting all pricing to the built-in
    /// `Default*Provider` values.
    func resetAll() {
        for (key, _) in defaults.dictionaryRepresentation() where key.hasPrefix(prefix) {
            defaults.removeObject(forKey: key)
        }
    }
}

/// Reads hotel-rate overrides if the admin has set any, otherwise falls
/// back to `DefaultBudgetPricingProvider`'s values. This is the same
/// `hotelRatePerNight` used by both the Hotels module's estimator and the
/// Budget Planner, so one edit here updates both instantly.
struct PersistedBudgetPricingProvider: BudgetPricingProviding {
    private let fallback = DefaultBudgetPricingProvider()
    private let store = PricingOverridesStore.shared

    func hotelRatePerNight(_ category: HotelCategory) -> Double {
        store.value(for: "hotel.\(category.rawValue)") ?? fallback.hotelRatePerNight(category)
    }

    // Budget Planner's food-preference-tier rate and per-ride transport
    // rate are a coarser, trip-level estimate distinct from the Food
    // module's per-category pricing and Transport module's per-mode
    // pricing below — not exposed to admin editing in this pass, so they
    // stay on the built-in defaults.
    func foodRatePerDay(_ preference: FoodPreference) -> Double { fallback.foodRatePerDay(preference) }
    func transportRatePerUse(_ mode: BudgetTransportMode) -> Double { fallback.transportRatePerUse(mode) }
    func usesPerDay(_ level: UsageLevel) -> Double { fallback.usesPerDay(level) }
}

/// Reads food-category overrides (Breakfast/Lunch/Dinner/Street Food/
/// Restaurant/Cafe — the Food module's cost cards) if set, else falls back
/// to `DefaultFoodPricingProvider`.
struct PersistedFoodPricingProvider: FoodPricingProviding {
    private let fallback = DefaultFoodPricingProvider()
    private let store = PricingOverridesStore.shared

    func averageCost(_ category: FoodCategory) -> Double {
        store.value(for: "food.\(category.rawValue)") ?? fallback.averageCost(category)
    }
}

/// Reads per-mode transport-fare overrides if set, else falls back to
/// `DefaultTransportPricingProvider`. `averageSpeedKmh` isn't admin-editable
/// — it's a physical estimate, not a price.
struct PersistedTransportPricingProvider: TransportPricingProviding {
    private let fallback = DefaultTransportPricingProvider()
    private let store = PricingOverridesStore.shared

    func baseFare(for mode: TransportMode) -> Double {
        store.value(for: "transport.base.\(mode.rawValue)") ?? fallback.baseFare(for: mode)
    }

    func perKmRate(for mode: TransportMode) -> Double {
        store.value(for: "transport.perKm.\(mode.rawValue)") ?? fallback.perKmRate(for: mode)
    }

    func averageSpeedKmh(for mode: TransportMode) -> Double {
        fallback.averageSpeedKmh(for: mode)
    }
}
