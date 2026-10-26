import SwiftUI

enum TransportMode: String, CaseIterable, Identifiable, Hashable {
    case car, taxi, auto, bike, bus, train, flight, walking

    var id: String { rawValue }

    var title: String {
        switch self {
        case .car: return "Car"
        case .taxi: return "Taxi"
        case .auto: return "Auto"
        case .bike: return "Bike"
        case .bus: return "Bus"
        case .train: return "Train"
        case .flight: return "Flight"
        case .walking: return "Walking"
        }
    }

    var systemImage: String {
        switch self {
        case .car: return "car.fill"
        case .taxi: return "car.side.fill"
        case .auto: return "figure.wave.circle.fill"
        case .bike: return "bicycle"
        case .bus: return "bus.fill"
        case .train: return "tram.fill"
        case .flight: return "airplane"
        case .walking: return "figure.walk"
        }
    }

    var tint: Color {
        switch self {
        case .car: return .touroTeal
        case .taxi: return .touroSunset
        case .auto: return Color(red: 0.98, green: 0.72, blue: 0.35)
        case .bike: return Color(red: 0.35, green: 0.45, blue: 0.95)
        case .bus: return Color(red: 0.55, green: 0.65, blue: 1.0)
        case .train: return Color(red: 0.85, green: 0.35, blue: 0.55)
        case .flight: return Color(red: 0.98, green: 0.55, blue: 0.65)
        case .walking: return .touroTealLight
        }
    }
}

enum TrafficCondition: String {
    case light = "Light", moderate = "Moderate", heavy = "Heavy", notApplicable = "N/A"

    var color: Color {
        switch self {
        case .light: return .green
        case .moderate: return .yellow
        case .heavy: return .red
        case .notApplicable: return .touroTextMuted
        }
    }
}

enum AvailabilityStatus: String {
    case available = "Available", limited = "Limited", unavailable = "Unavailable"

    var color: Color {
        switch self {
        case .available: return .green
        case .limited: return .yellow
        case .unavailable: return .red
        }
    }
}

enum ComparisonSort: String, CaseIterable, Identifiable {
    case cheapest = "Cheapest", fastest = "Fastest", balanced = "Balanced"
    var id: String { rawValue }
}

/// One transport mode's comparison row. `isDistanceLive`/`isTimeLive` are
/// surfaced in the UI so the app is honest about what came from a real
/// MKDirections route vs. a documented formula estimate — never presented
/// as live when it isn't.
struct TransportOption: Identifiable, Hashable {
    let mode: TransportMode
    let distanceMeters: Double
    let estimatedTime: TimeInterval
    let estimatedCost: Double
    let trafficCondition: TrafficCondition
    let availability: AvailabilityStatus
    let isDistanceLive: Bool
    let isTimeLive: Bool

    var id: TransportMode { mode }

    var distanceText: String {
        let km = distanceMeters / 1000
        return km < 1 ? "\(Int(distanceMeters)) m" : String(format: "%.0f km", km)
    }

    var etaText: String {
        let minutes = Int(estimatedTime / 60)
        if minutes < 60 { return "\(minutes) min" }
        let hours = minutes / 60
        let rem = minutes % 60
        return rem == 0 ? "\(hours) hr" : "\(hours) hr \(rem)m"
    }

    var costText: String {
        estimatedCost < 1 ? "Free" : "₹\(Int(estimatedCost.rounded()))"
    }

    var dataSourceLabel: String {
        switch (isDistanceLive, isTimeLive) {
        case (true, true): return "Live route data"
        case (true, false): return "Live distance · estimated time"
        default: return "Estimated"
        }
    }
}
