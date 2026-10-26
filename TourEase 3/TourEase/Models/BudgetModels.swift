import SwiftUI
import SwiftData

/// Conformed by every enum driven through `PillSegmentedControl` — one small
/// shared contract instead of duplicating picker UI per enum.
protocol LabeledOption: Hashable, CaseIterable, Identifiable {
    var displayName: String { get }
}

enum HotelCategory: String, LabeledOption {
    case budget, standard, premium, luxury
    var id: String { rawValue }
    var displayName: String {
        switch self {
        case .budget: return "Budget"
        case .standard: return "Standard"
        case .premium: return "Premium"
        case .luxury: return "Luxury"
        }
    }
}

enum FoodPreference: String, LabeledOption {
    case streetFood, budgetDining, standardDining, fineDining
    var id: String { rawValue }
    var displayName: String {
        switch self {
        case .streetFood: return "Street Food"
        case .budgetDining: return "Budget Dining"
        case .standardDining: return "Standard Dining"
        case .fineDining: return "Fine Dining"
        }
    }
}

enum UsageLevel: String, LabeledOption {
    case none, low, medium, high
    var id: String { rawValue }
    var displayName: String {
        switch self {
        case .none: return "None"
        case .low: return "Low"
        case .medium: return "Medium"
        case .high: return "High"
        }
    }
}

enum BudgetTransportMode: String {
    case taxi, auto, metro
}

/// Everything the user picks on the Budget Planner form.
struct BudgetInput: Hashable {
    var tripDays: Int = 3
    var hotelCategory: HotelCategory = .standard
    var foodPreference: FoodPreference = .standardDining
    var shoppingBudget: Double = 2000
    var taxiUsage: UsageLevel = .low
    var autoUsage: UsageLevel = .medium
    var metroUsage: UsageLevel = .none
    var activitiesBudget: Double = 1500
    var emergencyBufferPercent: Double = 10
}

struct BudgetSlice: Identifiable {
    let id = UUID()
    let label: String
    let amount: Double
    let color: Color
}

/// Result of running a `BudgetInput` through `BudgetCalculating`.
struct BudgetBreakdown {
    let hotelCost: Double
    let foodCost: Double
    let transportCost: Double
    let shoppingCost: Double
    let activitiesCost: Double
    let miscCost: Double
    var totalCost: Double { hotelCost + foodCost + transportCost + shoppingCost + activitiesCost + miscCost }

    var slices: [BudgetSlice] {
        [
            BudgetSlice(label: "Hotel", amount: hotelCost, color: .touroTeal),
            BudgetSlice(label: "Food", amount: foodCost, color: .touroTealLight),
            BudgetSlice(label: "Transport", amount: transportCost, color: .touroSunset),
            BudgetSlice(label: "Shopping", amount: shoppingCost, color: Color(red: 0.55, green: 0.65, blue: 1.0)),
            BudgetSlice(label: "Activities", amount: activitiesCost, color: Color(red: 0.85, green: 0.35, blue: 0.55)),
            BudgetSlice(label: "Buffer", amount: miscCost, color: Color.touroTextMuted),
        ]
        .filter { $0.amount > 0 }
    }
}

/// Persisted locally via SwiftData when the user taps "Save Budget" — read
/// back later by the History module (Part 9) without needing this file
/// touched again.
@Model
final class BudgetRecord {
    @Attribute(.unique) var id: String
    var tripLabel: String
    var tripDays: Int
    var hotelCategoryRaw: String
    var foodPreferenceRaw: String
    var shoppingBudget: Double
    var taxiUsageRaw: String
    var autoUsageRaw: String
    var metroUsageRaw: String
    var activitiesBudget: Double
    var emergencyBufferPercent: Double
    var hotelCost: Double
    var foodCost: Double
    var transportCost: Double
    var shoppingCost: Double
    var activitiesCost: Double
    var miscCost: Double
    var totalCost: Double
    var createdDate: Date

    init(tripLabel: String, input: BudgetInput, breakdown: BudgetBreakdown) {
        self.id = UUID().uuidString
        self.tripLabel = tripLabel.isEmpty ? "Untitled Trip" : tripLabel
        self.tripDays = input.tripDays
        self.hotelCategoryRaw = input.hotelCategory.rawValue
        self.foodPreferenceRaw = input.foodPreference.rawValue
        self.shoppingBudget = input.shoppingBudget
        self.taxiUsageRaw = input.taxiUsage.rawValue
        self.autoUsageRaw = input.autoUsage.rawValue
        self.metroUsageRaw = input.metroUsage.rawValue
        self.activitiesBudget = input.activitiesBudget
        self.emergencyBufferPercent = input.emergencyBufferPercent
        self.hotelCost = breakdown.hotelCost
        self.foodCost = breakdown.foodCost
        self.transportCost = breakdown.transportCost
        self.shoppingCost = breakdown.shoppingCost
        self.activitiesCost = breakdown.activitiesCost
        self.miscCost = breakdown.miscCost
        self.totalCost = breakdown.totalCost
        self.createdDate = .now
    }
}
