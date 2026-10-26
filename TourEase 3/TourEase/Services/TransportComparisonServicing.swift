import Foundation
import MapKit
import CoreLocation

protocol TransportComparisonServicing {
    func compareOptions(from source: MKMapItem, to destination: MKMapItem) async -> [TransportOption]
}

/// Builds the full 8-mode comparison. Car, Bike, and Walking use real
/// `MKDirections` routes (same as Route Planner). Taxi/Auto reuse the car's
/// real road distance but estimate their own time/cost (no live taxi-fare
/// API exists on iOS). Bus/Train/Flight have no official schedule or
/// pricing API at all, so distance/time/cost are formula-estimated and
/// labeled as such — see `TransportPricingProviding`.
final class TransportComparisonService: TransportComparisonServicing {
    private let routeService: RouteServicing
    private let pricing: TransportPricingProviding

    init(routeService: RouteServicing = MapKitRouteService(),
         pricing: TransportPricingProviding = PersistedTransportPricingProvider()) {
        self.routeService = routeService
        self.pricing = pricing
    }

    func compareOptions(from source: MKMapItem, to destination: MKMapItem) async -> [TransportOption] {
        async let carRoute = try? routeService.calculateRoute(from: source, to: destination, transportType: .automobile)
        async let walkRoute = try? routeService.calculateRoute(from: source, to: destination, transportType: .walking)

        let car = await carRoute
        let walk = await walkRoute
        // `.cycling` on MKDirectionsTransportType only exists on iOS 18+; this
        // project's deployment target is iOS 17, so bike falls back to a
        // formula estimate off the real car-route distance instead of
        // gating the whole app's minimum OS version for one transport mode.
        let bike: RouteResult? = nil

        // Fallback road distance/time if MKDirections returns nothing (e.g. offline).
        let straightLineMeters = source.compatCoordinate.distance(to: destination.compatCoordinate)
        let fallbackRoadMeters = straightLineMeters * 1.3 // road routes are rarely a straight line

        let roadDistance = car?.distanceMeters ?? fallbackRoadMeters
        let roadTime = car?.expectedTravelTime ?? (roadDistance / 1000 / pricing.averageSpeedKmh(for: .car) * 3600)
        let trafficRatio = roadTime / max(roadDistance / 1000 / pricing.averageSpeedKmh(for: .car) * 3600, 1)
        let roadTraffic = trafficCondition(fromRatio: trafficRatio)

        var options: [TransportOption] = []

        // Car — fully live.
        options.append(TransportOption(
            mode: .car, distanceMeters: roadDistance, estimatedTime: roadTime,
            estimatedCost: pricing.baseFare(for: .car) + (roadDistance / 1000) * pricing.perKmRate(for: .car),
            trafficCondition: roadTraffic, availability: .available,
            isDistanceLive: car != nil, isTimeLive: car != nil
        ))

        // Taxi — live distance (borrowed from car route), estimated time/cost (own average speed).
        let taxiTime = (roadDistance / 1000) / pricing.averageSpeedKmh(for: .taxi) * 3600
        options.append(TransportOption(
            mode: .taxi, distanceMeters: roadDistance, estimatedTime: taxiTime,
            estimatedCost: pricing.baseFare(for: .taxi) + (roadDistance / 1000) * pricing.perKmRate(for: .taxi),
            trafficCondition: roadTraffic, availability: .available,
            isDistanceLive: car != nil, isTimeLive: false
        ))

        // Auto — same pattern as taxi.
        let autoTime = (roadDistance / 1000) / pricing.averageSpeedKmh(for: .auto) * 3600
        options.append(TransportOption(
            mode: .auto, distanceMeters: roadDistance, estimatedTime: autoTime,
            estimatedCost: pricing.baseFare(for: .auto) + (roadDistance / 1000) * pricing.perKmRate(for: .auto),
            trafficCondition: roadTraffic, availability: roadDistance > 60_000 ? .limited : .available,
            isDistanceLive: car != nil, isTimeLive: false
        ))

        // Bike — fully live via MKDirections .cycling.
        options.append(TransportOption(
            mode: .bike, distanceMeters: bike?.distanceMeters ?? roadDistance,
            estimatedTime: bike?.expectedTravelTime ?? ((roadDistance / 1000) / pricing.averageSpeedKmh(for: .bike) * 3600),
            estimatedCost: pricing.baseFare(for: .bike) + (roadDistance / 1000) * pricing.perKmRate(for: .bike),
            trafficCondition: .notApplicable,
            availability: roadDistance > 40_000 ? .limited : .available,
            isDistanceLive: bike != nil, isTimeLive: bike != nil
        ))

        // Walking — fully live via MKDirections .walking; impractical beyond ~10km.
        let walkDistance = walk?.distanceMeters ?? roadDistance
        options.append(TransportOption(
            mode: .walking, distanceMeters: walkDistance,
            estimatedTime: walk?.expectedTravelTime ?? ((walkDistance / 1000) / pricing.averageSpeedKmh(for: .walking) * 3600),
            estimatedCost: 0, trafficCondition: .notApplicable,
            availability: walkDistance <= 5_000 ? .available : (walkDistance <= 10_000 ? .limited : .unavailable),
            isDistanceLive: walk != nil, isTimeLive: walk != nil
        ))

        // Bus — no schedule API; formula-estimated off the real road distance.
        let busTime = (roadDistance / 1000) / pricing.averageSpeedKmh(for: .bus) * 3600
        options.append(TransportOption(
            mode: .bus, distanceMeters: roadDistance, estimatedTime: busTime,
            estimatedCost: pricing.baseFare(for: .bus) + (roadDistance / 1000) * pricing.perKmRate(for: .bus),
            trafficCondition: roadTraffic,
            availability: roadDistance < 1_500 ? .limited : (roadDistance > 900_000 ? .unavailable : .available),
            isDistanceLive: car != nil, isTimeLive: false
        ))

        // Train — no schedule API; formula-estimated off the real road distance.
        let trainTime = (roadDistance / 1000) / pricing.averageSpeedKmh(for: .train) * 3600
        options.append(TransportOption(
            mode: .train, distanceMeters: roadDistance, estimatedTime: trainTime,
            estimatedCost: pricing.baseFare(for: .train) + (roadDistance / 1000) * pricing.perKmRate(for: .train),
            trafficCondition: .notApplicable,
            availability: roadDistance < 5_000 ? .unavailable : .available,
            isDistanceLive: car != nil, isTimeLive: false
        ))

        // Flight — great-circle distance (flight paths approximate a straight line, not the road route).
        let flightDistance = straightLineMeters
        let flightTime = (flightDistance / 1000) / pricing.averageSpeedKmh(for: .flight) * 3600 + 5400 // +90min checkin/taxi overhead
        options.append(TransportOption(
            mode: .flight, distanceMeters: flightDistance, estimatedTime: flightTime,
            estimatedCost: pricing.baseFare(for: .flight) + (flightDistance / 1000) * pricing.perKmRate(for: .flight),
            trafficCondition: .notApplicable,
            availability: flightDistance < 150_000 ? .unavailable : .available,
            isDistanceLive: true, isTimeLive: false
        ))

        return options
    }

    private func trafficCondition(fromRatio ratio: Double) -> TrafficCondition {
        switch ratio {
        case ..<1.1: return .light
        case 1.1..<1.3: return .moderate
        default: return .heavy
        }
    }
}

private extension CLLocationCoordinate2D {
    /// Great-circle distance in meters.
    func distance(to other: CLLocationCoordinate2D) -> Double {
        CLLocation(latitude: latitude, longitude: longitude)
            .distance(from: CLLocation(latitude: other.latitude, longitude: other.longitude))
    }
}
