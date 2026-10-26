import Foundation
import MapKit

/// What the user fills in on the Route Planner form. Kept separate from
/// `RouteResult` so it can later be persisted as-is by the History module
/// (Part 9) without dragging MapKit types along.
struct TripPlanInput: Hashable {
    var sourceName: String = ""
    var destinationName: String = ""
    var travelDate: Date = .now
    var tripDays: Int = 1
    var peopleCount: Int = 1
}

/// Result of a real MKDirections calculation between two resolved map items.
struct RouteResult {
    var sourceName: String
    var destinationName: String
    var sourceCoordinate: CLLocationCoordinate2D
    var destinationCoordinate: CLLocationCoordinate2D
    var distanceMeters: Double
    var expectedTravelTime: TimeInterval
    var polyline: MKPolyline
    var transportType: MKDirectionsTransportType

    var distanceText: String {
        let km = distanceMeters / 1000
        return km < 1 ? "\(Int(distanceMeters)) m" : String(format: "%.1f km", km)
    }

    var etaText: String {
        let minutes = Int(expectedTravelTime / 60)
        if minutes < 60 { return "\(minutes) min" }
        let hours = minutes / 60
        let remMinutes = minutes % 60
        return remMinutes == 0 ? "\(hours) hr" : "\(hours) hr \(remMinutes) min"
    }
}

/// A resolved, tappable search suggestion — wraps `MKLocalSearchCompletion`
/// so views don't depend on MapKit completion internals directly.
nonisolated struct PlaceSuggestion: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let subtitle: String
    fileprivate let completion: MKLocalSearchCompletion

    static func == (lhs: PlaceSuggestion, rhs: PlaceSuggestion) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
}

extension PlaceSuggestion {
    nonisolated init(completion: MKLocalSearchCompletion) {
        self.title = completion.title
        self.subtitle = completion.subtitle
        self.completion = completion
    }

    var underlyingCompletion: MKLocalSearchCompletion { completion }
}
